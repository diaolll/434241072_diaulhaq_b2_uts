# Arsitektur E-Ticketing Helpdesk

## Gambaran Besar

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                              │
│                    (Mobile SMT4 - UI)                           │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
            AUTH (Supabase Auth)   DATA (Supabase DB)
                    │                     │
                    └──────────┬──────────┘
                               │
                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                       SUPABASE (All-in-One)                     │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │   Supabase Auth  │  │   PostgreSQL     │  │    Storage    │ │
│  │                  │  │                  │  │               │ │
│  │ - Login/Register │  │ - users          │  │ - attachments │ │
│  │ - JWT Sessions   │  │ - tickets        │  │ - images/pdf  │ │
│  │ - RLS Policies   │  │ - comments       │  │               │ │
│  │                  │  │ - notifications  │  │               │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## Komponen & Fungsinya

### 1. SUPABASE

**URL**: https://mpkcasgkzthrmkilsabf.supabase.co

**Fungsi**: All-in-one Backend (Auth + Database + Storage)

#### A. Supabase Auth
| Fitur | Deskripsi |
|-------|-----------|
| **Login/Register** | Email & password authentication |
| **JWT Sessions** | Token management otomatis |
| **RLS Policies** | Row Level Security untuk data protection |
| **User Metadata** | Simpan name, role, dll |

#### B. PostgreSQL Database
| Tabel | Isi | Dipakai? |
|-------|-----|----------|
| `users` | id, email, name, role, avatar_url | ✅ YA |
| `tickets` | id, title, description, status, priority, user_id, assigned_to | ✅ YA |
| `comments` | id, ticket_id, user_id, content, created_at | ✅ YA |
| `notifications` | id, user_id, ticket_id, title, message, type, is_read | ✅ YA |
| `ticket_attachments` | id, ticket_id, file_url, file_name, file_type | ✅ YA |
| `ticket_history` | id, ticket_id, changed_by, old_status, new_status, note | ✅ YA |

#### C. Storage
| Bucket | Fungsi |
|--------|--------|
| `ticket-attachments` | Upload file lampiran (gambar/pdf) |

**Status**: ✅ **ACTIVE** - Semua fitur pakai Supabase

---

## Alur Data (Data Flow)

### Alur Login/Register

```
Flutter App                    Supabase Auth                 Supabase DB
    │                              │                              │
    ├─ signUp() ──────────────────▶│                              │
    │  {email, password, name}     │                              │
    │                              │                              │
    │                              ├─ Create user in auth.users  │
    │                              │                              │
    │                              ├─ Trigger: handle_new_user   │
    │                              │─────────────────────────────▶│
    │                              │                              │
    │                              │                              ├─ INSERT INTO users
    │                              │                              │
    │◀─ User + Session ────────────┤                              │
    │                              │                              │
    ├─ Simpan ke SharedPreferences│                              │
    │  - user_id                   │                              │
    │  - user_role                 │                              │
    │  - user_name                 │                              │
    │                              │                              │
```

### Alur Create Ticket

```
Flutter App                    Supabase DB                     Triggers
    │                              │                              │
    ├─ INSERT INTO tickets ──────▶│                              │
    │  {title, description,        │                              │
    │   category, priority,        │                              │
    │   user_id}                   │                              │
    │                              │                              │
    │                              ├─ Trigger: notify_on_new_ticket
    │                              │───────────────────────────────▶
    │                              │                              ├─ Create notifications
    │                              │                              │  for all admins
    │                              │                              │
    │◀─ ticket data ───────────────┤                              │
    │                              │                              │
```

### Alur Komentar

```
Flutter App                    Supabase DB                     Triggers
    │                              │                              │
    ├─ INSERT INTO comments ─────▶│                              │
    │  {ticket_id, user_id,        │                              │
    │   content}                   │                              │
    │                              │                              │
    │                              ├─ Trigger: notify_on_new_comment
    │                              │───────────────────────────────▶
    │                              │                              ├─ Notify ticket creator
    │                              │                              │  & assigned user
    │                              │                              │
    │◀─ success ───────────────────┤                              │
```

---

## Auto-Notifications (Triggers)

Notifikasi dibuat otomatis oleh PostgreSQL triggers:

| Event | Trigger | Penerima |
|-------|---------|----------|
| **Ticket baru dibuat** | `notify_on_new_ticket()` | Admin & Helpdesk |
| **Komentar ditambahkan** | `notify_on_new_comment()` | Ticket creator & assigned user |
| **Status berubah** | `notify_on_status_change()` | Ticket creator |
| **Ticket di-assign** | `notify_on_ticket_assign()` | Assigned user |

---

## Row Level Security (RLS)

RLS memastikan user hanya bisa akses data yang berhak:

| Tabel | Policy | Aturan |
|-------|--------|--------|
| `users` | View own profile | `auth.uid() = id` |
| `tickets` | View own tickets | `user_id = auth.uid()` |
| `tickets` | Create tickets | `user_id = auth.uid()` |
| `tickets` | Admin view all | `role IN ('admin', 'helpdesk')` |
| `comments` | View on own tickets | `ticket.user_id = auth.uid() OR ticket.assigned_to = auth.uid()` |
| `notifications` | View own notifications | `user_id = auth.uid()` |

---

## Konfigurasi

### Flutter (`.env`)
```env
SUPABASE_URL=https://mpkcasgkzthrmkilsabf.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
```

### Supabase Dashboard Settings
- **Authentication** → **Providers** → **Email** → Confirm email: **OFF**
- **Database** → **Replication** → **Realtime**: Enabled (opsional)

---

## Migration Files

Urutan jalankan migration di Supabase SQL Editor:

1. `01_create_tables.sql` - Create tabel users, tickets, comments, notifications
2. `02_rls_policies.sql` - Setup RLS policies
3. `03_notification_triggers.sql` - Auto-notification triggers
4. `04_fix_rls_policies.sql` - Fixed RLS untuk Supabase Auth
5. `05_disable_email_confirm.sql` - Auto-create user on signup
6. `06_create_test_admin.sql` - Setup admin user

---

## Summary

| Komponen | Dipakai Untuk | Status |
|----------|---------------|--------|
| **Supabase Auth** | Login/Register, JWT, RLS | ✅ Active |
| **Supabase DB** | Semua data (users, tickets, comments, notifications) | ✅ Active |
| **Supabase Storage** | File attachments | ✅ Active |
| ~~Golang Backend~~ | ❌ Deprecated | 🗑️ Dihapus |
| ~~MySQL (TablePlus)~~ | ❌ Deprecated | 🗑️ Dihapus |

---

## Arsitektur Lama (Deprecated)

❌ **Tidak dipakai lagi:**
- `e-ticketing-backend/` - Golang backend
- MySQL database via TablePlus
- JWT manual validation

Semua fungsi telah di-migrasi ke Supabase.
