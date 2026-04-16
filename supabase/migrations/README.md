# Supabase Migrations

Folder ini berisi SQL script untuk setup database di Supabase.

## 🚀 Cara Pakai

1. Buka Supabase SQL Editor:
   ```
   https://supabase.com/dashboard/project/mpkcasgkzthrmkilsabf/sql/new
   ```

2. Copy isi file `01_create_tables.sql`

3. Paste ke SQL Editor

4. Klik **Run** ( atau tekan `Ctrl + Enter`)

---

## 📁 File List

| File | Deskripsi |
|------|-----------|
| `01_create_tables.sql` | Create tabel: users, tickets, comments, notifications |
| `02_rls_policies.sql` | Row Level Security untuk keamanan data |

---

## ⚠️ Urutan Jalan

1. **Jalanin dulu**: `01_create_tables.sql`
2. **Baru jalanin**: `02_rls_policies.sql` (opsional, untuk keamanan)

---

## 📊 Schema

```
users (user, helpdesk, admin)
  ├── tickets (user membuat tiket)
  │     └── comments (diskusi tiket)
  └── notifications (notifikasi untuk user)
```

---

## 👤 Sample Users

Setelah run SQL, akan ada 2 user sample:
- `admin@eticketing.com` (role: admin)
- `helpdesk@eticketing.com` (role: helpdesk)

Password perlu di-hash dulu pakai bcrypt.
