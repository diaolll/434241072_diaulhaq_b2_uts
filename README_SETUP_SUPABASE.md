# Panduan Setup Database Supabase
# E-Ticketing Helpdesk Application

## 📋 Langkah Setup Database

### 1. Buat Storage Buckets

Di Supabase Dashboard → **Storage** → **New bucket**:

#### Bucket 1: `ticket-images`
- **Name**: `ticket-images`
- **Public**: ✅ Enable
- **File size limit**: 5MB
- **Allowed MIME types**: `image/jpeg`, `image/png`, `image/gif`

#### Bucket 2: `ticket-files`
- **Name**: `ticket-files`
- **Public**: ✅ Enable
- **File size limit**: 10MB
- **Allowed MIME types**: `application/pdf`, `image/*`

---

### 2. Jalankan SQL Script

Buka **Supabase Dashboard** → **SQL Editor** → jalankan script berikut secara berurutan:

#### File 1: `1_create_tables.sql`
- Membuat tabel: users, tickets, comments, ticket_attachments, ticket_history, notifications, user_profiles
- Setup triggers, indexes, RLS policies
- Insert sample users (admin, helpdesk, user)

#### File 2: `2_create_views.sql`
- Membuat views: vw_tickets_details, vw_ticket_stats, vw_user_ticket_stats, dll.

#### File 3: `4_helper_functions.sql`
- Membuat fungsi helper untuk update status, assign ticket, dll.
- Setup trigger notifikasi otomatis

---

### 3. Enable Email Auth

**Supabase Dashboard** → **Authentication** → **Providers**:

1. Klik **Email**
2. Klik **Enable**
3. Atur **Email Confirmation**:
   - **Confirm email**: Double opt-in (false) untuk testing
   - **Secure email change**: Enable
4. Klik **Save**

---

### 4. Atur Permissions

**RLS Policies sudah di-setup secara otomatis** di script:
- Users bisa lihat/ubah profile sendiri
- Admin bisa lihat semua tiket
- Helpdesk bisa update tiket
- User hanya bisa buat/update tiket miliknya

---

## 📊 Struktur Tabel

### `users`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | UUID | Primary key |
| email | VARCHAR | Unique, untuk login |
| password_hash | VARCHAR | Hash password (bukan plain text!) |
| name | VARCHAR | Nama lengkap |
| role | VARCHAR | 'admin', 'helpdesk', 'user' |
| avatar_url | TEXT | URL foto profil |
| is_active | BOOLEAN | Status akun |

### `tickets`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | UUID | Primary key |
| ticket_no | VARCHAR | Auto: TKT-YYYYMMDD-XXXX |
| title | VARCHAR | Judul tiket |
| description | TEXT | Deskripsi masalah |
| category | VARCHAR | Kategori: Hardware, Software, dll |
| priority | VARCHAR | low, medium, high, critical |
| status | VARCHAR | open, in_progress, resolved, closed |
| user_id | UUID | FK ke users (pembuat tiket) |
| assigned_to | UUID | FK ke users (helpdesk yg menangani) |
| created_at | TIMESTAMP | Waktu dibuat |
| updated_at | TIMESTAMP | Waktu diupdate |

### `comments`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | UUID | Primary key |
| ticket_id | UUID | FK ke tickets |
| user_id | UUID | FK ke users |
| content | TEXT | Isi komentar |
| is_internal | BOOLEAN | true = hanya admin/helpdesk |

### `ticket_attachments`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | UUID | Primary key |
| ticket_id | UUID | FK ke tickets |
| file_url | TEXT | URL file di Supabase Storage |
| file_name | VARCHAR | Nama asli file |
| file_type | VARCHAR | MIME type |
| file_size | BIGINT | Ukuran file dalam bytes |
| uploaded_by | UUID | FK ke users |

### `ticket_history`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | UUID | Primary key |
| ticket_id | UUID | FK ke tickets |
| changed_by | UUID | FK ke users (yg mengubah status) |
| old_status | VARCHAR | Status sebelumnya |
| new_status | VARCHAR | Status baru |
| note | TEXT | Catatan perubahan |

### `notifications`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | UUID | Primary key |
| user_id | UUID | FK ke users (penerima notif) |
| ticket_id | UUID | FK ke tickets |
| title | VARCHAR | Judul notifikasi |
| body | TEXT | Isi notifikasi |
| type | VARCHAR | status_update, comment, assigned |
| is_read | BOOLEAN | Sudah dibaca atau belum |
| created_at | TIMESTAMP | Waktu dibuat |

---

## 🔐 Sample Users untuk Testing

Password untuk semua sample user: `admin123` (ganti dengan hash yang aman di production)

| Role | Email | Nama |
|------|-------|------|
| Admin | admin@eticketing.com | Administrator |
| Helpdesk | helpdesk1@eticketing.com | Helpdesk 1 |
| Helpdesk | helpdesk2@eticketing.com | Helpdesk 2 |
| User | user@eticketing.com | Regular User |

---

## 📝 Catatan Penting

1. **Password Hashing** - Di production, JANGAN simpan password plain text. Gunakan bcrypt atau argon2 untuk hashing.

2. **RLS Policies** - Row Level Security sudah di-setup untuk membatasi akses berdasarkan role.

3. **Ticket Number** - Auto-generated dengan format: `TKT-YYYYMMDD-XXXX`

4. **Notifications** - Otomatis dibuat ketika:
   - Status tiket berubah
   - Tiket di-assign ke helpdesk
   - Ada komentar baru

5. **Real-time** - Supabase Realtime bisa di-enable untuk update langsung ke client.

---

## 🚀 Setelah Setup

Setelah menjalankan semua SQL:

1. Test register dengan user baru di aplikasi
2. Login sebagai admin/helpdesk/user
3. Buat tiket baru
4. Test update status tiket
5. Test assign tiket
6. Test komentar

---

## 🔗 Hubungkan ke Flutter App

Pastikan file `.env` di Flutter project berisi:

```env
SUPABASE_URL=https://twpcgwlmlydmnlxymhrg.supabase.co
SUPABASE_ANON_KEY=anon_key_anda_dari_supabase_dashboard
API_BASE_URL=http://localhost:8080/api
```

Run aplikasi:
```bash
flutter pub get
flutter run
```
