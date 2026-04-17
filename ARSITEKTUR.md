# Arsitektur E-Ticketing Helpdesk

## Gambaran Besar

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                              │
│                    (Mobile SMT4 - UI)                           │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    PRESENTATION LAYER                     │  │
│  │  Screens → Widgets → (Consumer widgets via Riverpod)      │  │
│  └────────────────────────┬──────────────────────────────────┘  │
│                           │                                       │
│  ┌────────────────────────┴──────────────────────────────────┐  │
│  │                   STATE MANAGEMENT (Riverpod)             │  │
│  │  - Providers (authNotifierProvider, ticketsProvider, etc) │  │
│  │  - StateNotifiers (AuthNotifier, TicketsNotifier)         │  │
│  │  - StateProviders (authStateProvider, themeModeProvider)  │  │
│  └────────────────────────┬──────────────────────────────────┘  │
└───────────────────────────┼──────────────────────────────────────┘
                            │
                    ┌───────┴────────┐
                    │                │
            AUTH (Supabase Auth)  DATA (Supabase DB)
                    │                │
                    └────────┬───────┘
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

## State Management: Riverpod

**Library**: `flutter_riverpod` ^2.4.9

### Provider Types Used

| Type | Provider | Usage |
|------|----------|-------|
| **StateNotifierProvider** | `authNotifierProvider` | Auth state management (login, logout, register) |
| **StateNotifierProvider** | `ticketsProvider` | Ticket CRUD operations & filtering |
| **StateNotifierProvider** | `notificationNotifierProvider` | Unread notification count |
| **StateProvider** | `authStateProvider` | Simple auth boolean state |
| **StateProvider** | `searchQueryProvider` | Search query string |
| **StateProvider** | `themeModeProvider` | Light/dark theme mode |
| **StateProvider** | `selectedTabProvider` | Bottom navigation index |
| **StateProvider** | `unreadCountProvider` | Unread notification counter |
| **FutureProvider** | `currentUserProvider` | Async current user data |
| **Provider** | `ticketRepoProvider`, `authRepoProvider` | Repository instances |
| **Provider.family** | `filteredTicketsProvider` | Filter tickets by status |

### Key State Classes

```dart
// Auth State
class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;
}

// Tickets State
class TicketsState {
  final List<TicketModel> tickets;
  final Map<String, int> stats;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
}
```

### Usage Example

```dart
// Watch state in widget
final authState = ref.watch(authNotifierProvider);
final tickets = ref.watch(ticketListProvider);

// Call actions
ref.read(authNotifierProvider.notifier).login(email, password);
ref.read(ticketsProvider.notifier).refresh();
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

## Struktur Project (Clean Architecture)

```
lib/
├── core/                    # Shared utilities & configs
│   ├── config/
│   │   └── env_config.dart         # Environment variables
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── api_constants.dart      # API endpoints
│   ├── services/
│   │   ├── supabase_service.dart   # Supabase client
│   │   └── theme_service.dart      # Theme management
│   ├── theme/
│   │   ├── app_theme.dart          # Light/dark themes
│   │   ├── modern_theme.dart       # Modern theme variant
│   │   └── elegant_theme.dart      # Elegant theme variant
│   └── utils/
│       ├── validators.dart         # Input validators
│       └── date_utils.dart         # Date formatting
│
├── data/                    # Data layer (repositories, models, datasources)
│   ├── datasources/
│   │   └── api_client.dart         # HTTP client wrapper
│   ├── models/
│   │   ├── user_model.dart         # User data model
│   │   ├── ticket_model.dart       # Ticket data model
│   │   ├── comment_model.dart      # Comment data model
│   │   └── auth_response_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart    # Auth data operations
│   │   └── ticket_repository.dart  # Ticket data operations
│   └── providers/
│       └── providers.dart          # Riverpod providers (all state)
│
├── domain/                  # Domain layer (entities, usecases)
│   ├── entities/
│   │   ├── user_entity.dart        # User domain entity
│   │   ├── ticket_entity.dart      # Ticket domain entity
│   │   └── comment_entity.dart     # Comment domain entity
│   └── usecases/
│       ├── login_usecase.dart      # Login business logic
│       ├── logout_usecase.dart     # Logout business logic
│       ├── get_tickets_usecase.dart
│       └── create_ticket_usecase.dart
│
├── presentation/            # UI layer
│   ├── screens/
│   │   ├── splash_screen.dart      # Launch screen
│   │   ├── login_screen.dart       # Login page
│   │   ├── login_elegant.dart      # Elegant login variant
│   │   ├── register_screen.dart    # Registration
│   │   ├── reset_password_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart      # Main dashboard
│   │   ├── tickets/
│   │   │   ├── ticket_list_screen.dart    # Ticket list
│   │   │   ├── ticket_detail_screen.dart  # Ticket details
│   │   │   └── create_ticket_screen.dart  # Create ticket
│   │   ├── notification_screen.dart
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── common/                 # Reusable widgets
│   │   │   ├── app_button.dart
│   │   │   ├── app_input.dart
│   │   │   ├── app_card.dart
│   │   │   ├── status_badge.dart
│   │   │   ├── empty_state.dart
│   │   │   └── loading_shimmer.dart
│   │   └── elegant/                # Elegant theme widgets
│   │       └── elegant_widgets.dart
│   └── router/
│       └── app_router.dart         # GoRouter configuration
│
└── main.dart                # App entry point (ProviderScope wrapper)
```

## Navigation: Go Router

**Library**: `go_router` ^12.1.1

| Route | Screen |
|-------|--------|
| `/` | Splash → redirect based on auth |
| `/login` | Login Screen |
| `/register` | Register Screen |
| `/dashboard` | Main Dashboard |
| `/tickets` | Ticket List |
| `/tickets/:id` | Ticket Detail |
| `/tickets/create` | Create Ticket |
| `/notifications` | Notifications |
| `/profile` | Profile |
| `/settings` | Settings |

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
