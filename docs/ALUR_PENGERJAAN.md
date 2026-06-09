# 🛠️ Alur Pengerjaan Project E-Ticketing Helpdesk

## Tahap 1: Persiapan & Setup

### 1.1 Inisialisasi Project
```bash
flutter create e_ticketing_helpdesk
cd e_ticketing_helpdesk
```

### 1.2 Setup Dependencies
Tambahkan ke `pubspec.yaml`:
- **State Management**: flutter_riverpod, riverpod_annotation
- **Navigation**: go_router
- **API**: dio, supabase_flutter
- **Storage**: flutter_secure_storage, shared_preferences
- **UI**: google_fonts, fl_chart, shimmer, cached_network_image
- **Utils**: image_picker, file_picker, intl, uuid

```bash
flutter pub get
```

### 1.3 Setup Supabase
1. Buat project di [supabase.com](https://supabase.com)
2. Buat database schema:
   - Tabel `users` (id, email, name, role, created_at)
   - Tabel `tickets` (id, user_id, title, description, category, priority, status, ticket_no, created_at)
   - Tabel `comments` (id, ticket_id, user_id, content, created_at)
   - Tabel `notifications` (id, user_id, ticket_id, message, is_read, created_at)
3. Setup RLS policies
4. Buat storage bucket `ticket-attachments`

### 1.4 Setup Environment
Buat file `.env`:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
API_BASE_URL=http://localhost:8080/api/v1
```

---

## Tahap 2: Struktur Project & Core

### 2.1 Buat Struktur Folder
```
lib/
├── core/
│   ├── config/
│   ├── theme/
│   ├── router/
│   └── services/
├── data/
│   ├── models/
│   ├── repositories/
│   ├── providers/
│   └── datasources/
└── presentation/
    └── screens/
```

### 2.2 Setup Theme (lib/core/theme/)
Buat `app_theme.dart`:
- Color palette (primary, secondary, surface, text)
- Status colors (open, in_progress, resolved, closed)
- Priority colors (low, medium, high, critical)
- Light & Dark theme

### 2.3 Setup Supabase Service (lib/core/services/)
Buat `supabase_service.dart`:
- Initialize Supabase client
- Helper methods untuk file upload

### 2.4 Setup Environment Config
Buat `env_config.dart` untuk load environment variables

---

## Tahap 3: Data Layer

### 3.1 Buat Models (lib/data/models/)
- `user_model.dart` → User (id, name, email, role, createdAt)
- `ticket_model.dart` → Ticket (id, ticketNo, title, description, category, priority, status, createdAt)
- `comment_model.dart` → Comment (id, ticketId, userId, content, createdAt)
- `auth_response_model.dart` → AuthResponse (token, user)

### 3.2 Buat Repositories (lib/data/repositories/)

**auth_repository.dart**:
- `login(email, password)` → Supabase Auth
- `register(name, email, password)` → Supabase Auth + upsert ke tabel users
- `resetPassword(email)` → Kirim email reset
- `logout()` → Clear session & local storage
- Helper: getCurrentUser, getToken, getRole, dll

**ticket_repository.dart**:
- `getTickets()` → Fetch semua tiket user
- `getTicketById(id)` → Detail tiket
- `createTicket(...)` → Insert tiket baru
- `updateStatus(id, status)` → Update status tiket
- `addComment(ticketId, content)` → Tambah komentar
- `getDashboardStats()` → Hitung statistik
- `getNotifications()` → Fetch notifikasi
- `uploadFile(...)` → Upload ke Supabase Storage

### 3.3 Setup API Client (lib/data/datasources/)
Buat `api_client.dart` dengan Dio untuk HTTP requests (kalau perlu custom API)

---

## Tahap 4: State Management (Riverpod)

### 4.1 Buat Providers (lib/data/providers/providers.dart)

**Auth Providers**:
- `authRepoProvider` → Repository instance
- `authNotifierProvider` → StateNotifier untuk auth state
- `AuthState` → authenticated, unauthenticated, loading, error

**Ticket Providers**:
- `ticketsProvider` → StateNotifier untuk tickets list
- `TicketsState` → tickets list, stats, loading, error
- `filteredTicketsProvider` → Filter by status

**Notification Providers**:
- `notificationNotifierProvider` → Unread count

**Other Providers**:
- `themeModeProvider` → Theme mode
- `selectedTabProvider` → Bottom nav selection

---

## Tahap 5: UI Implementation

### 5.1 Authentication Screens

**splash_screen.dart**:
- Check login status
- Redirect ke login atau dashboard

**login_screen.dart**:
- Email & password form
- Validation
- Call auth login
- Navigate ke dashboard jika sukses

**register_screen.dart**:
- Name, email, password form
- Call auth register
- Navigate ke login

**reset_password_screen.dart**:
- Email input
- Kirim link reset

### 5.2 Dashboard (dashboard/dashboard_screen.dart)
- Header dengan greeting & notification bell
- Stats cards (Total, Open, In Progress, Resolved)
- Pie chart (fl_chart)
- Recent tickets list
- Bottom navigation bar

### 5.3 Ticket Screens

**tickets/ticket_list_screen.dart**:
- List semua tiket
- Filter by status
- Search functionality
- Pull to refresh

**tickets/ticket_detail_screen.dart**:
- Detail tiket
- Status update (kalau admin)
- Comments list
- Add comment form

**tickets/create_ticket_screen.dart**:
- Form: judul, deskripsi, kategori, prioritas
- File attachment (kamera, galeri, file picker)
- Upload ke Supabase Storage

### 5.4 Other Screens

**profile_screen.dart**:
- User info
- Logout button

**settings_screen.dart**:
- Theme toggle
- Language (opsional)

**notification_screen.dart**:
- List notifikasi
- Mark as read

---

## Tahap 6: Routing & Navigation

### 6.1 Setup Router (lib/core/router/app_router.dart)
Gunakan `go_router`:
- Redirect logic based on auth status
- Role-based access control
- Route definitions:
  - `/` → Splash
  - `/login` → Login
  - `/register` → Register
  - `/dashboard` → Dashboard
  - `/tickets` → Ticket List
  - `/tickets/:id` → Ticket Detail
  - `/tickets/create` → Create Ticket
  - `/profile` → Profile
  - `/settings` → Settings
  - `/notifications` → Notifications

---

## Tahap 7: Main Entry Point

### 7.1 Setup main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(...);
  await ThemeService().init();
  runApp(ProviderScope(child: MyApp()));
}
```

---

## Tahap 8: Testing & Debugging

### 8.1 Test Flow
1. Register user baru
2. Login dengan user tersebut
3. Cek dashboard (stats, chart)
4. Create ticket baru
5. Cek ticket muncul di list
6. Buka detail ticket
7. Add comment
8. Cek notification
9. Logout

### 8.2 Debug Common Issues
- Auth token tidak tersimpan → cek SharedPreferences
- RLS policies → cek Supabase dashboard
- Upload file gagal → cek bucket permissions
- Role tidak berfungsi → cek value di tabel users

---

## Tahap 9: Finalisasi

### 9.1 Build untuk Android/iOS
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### 9.2 Documentation
- Update README.md
- Tambah screenshot
- Document API endpoints (kalau ada)

---

## 📊 Timeline Saran

| Hari | Task |
|------|------|
| 1-2 | Setup, dependencies, Supabase schema |
| 3-4 | Data layer (models, repositories) |
| 5-6 | State management (providers) |
| 7-10 | Auth screens |
| 11-14 | Dashboard & Ticket screens |
| 15-16 | Other screens, navigation |
| 17-18 | Testing & bug fixes |
| 19-20 | Finalisasi & dokumentasi |

---

## 🔑 Key Points untuk Responsi

1. **Arsitektur Clean Architecture**: Presentation → Business Logic → Data
2. **State Management**: Riverpod untuk reactive state
3. **Auth**: Supabase Auth + RLS policies
4. **Real-time**: Belum, bisa pakai Supabase Realtime
5. **Scalability**: Modular structure, mudah tambah fitur