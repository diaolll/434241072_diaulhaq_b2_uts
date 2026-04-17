# E-Ticketing Helpdesk Mobile App

Aplikasi mobile E-Ticketing Helpdesk berbasis Flutter untuk pelaporan, monitoring, dan penyelesaian tiket bantuan IT.

## 📋 SRS Compliance Checklist

### ✅ FR-001: Login
- [x] Username/password login
- [x] Supabase Authentication
- [x] Session management
- [x] All user roles (user, helpdesk, admin)

### ✅ FR-002: Logout
- [x] Logout functionality
- [x] Clear session
- [x] All user roles

### ✅ FR-003: Register
- [x] User registration (role: user only)
- [x] Auto-assign role 'user'
- [x] Name, email, password fields

### ✅ FR-004: Reset Password
- [x] Reset password screen
- [x] Email-based reset flow
- [x] All user roles

### ✅ FR-005: User - Manajemen Tiket
- [x] Create ticket with category & priority
- [x] Upload attachment (camera/gallery/file)
- [x] View own ticket list only
- [x] View ticket details
- [x] Add comments/replies
- [x] Track ticket status

### ✅ FR-006: Admin/Helpdesk - Manajemen Tiket
- [x] View ALL tickets (not just own)
- [x] Filter by status, priority, category
- [x] Update ticket status (admin/helpdesk only)
- [x] Assign ticket to helpdesk (backend ready)
- [x] Add comments
- [x] Cannot create tickets (user only)

### ✅ FR-007: Notifikasi
- [x] Notification screen
- [x] Real-time subscription (Supabase)
- [x] Navigation to related ticket

### ✅ FR-008: Dashboard
- [x] Total tickets
- [x] Status distribution
- [x] Role-based stats (user: own, admin/helpdesk: all)
- [x] Chart visualization
- [x] Quick actions

### ✅ FR-010: Riwayat Tiket
- [x] Timeline view with status badges
- [x] Status change history
- [x] Notes & timestamps
- [x] User who made changes displayed

### ✅ FR-011: Tracking Tiket
- [x] Real-time status updates
- [x] Progress visualization
- [x] Status badges on all screens

### ✅ Non-Functional Requirements
- [x] Lazy loading for lists
- [x] Responsive UI (Material 3)
- [x] Dark & Light mode
- [x] Clean Architecture
- [x] Role-Based Access Control (RBAC)

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Frontend | Flutter 3.x |
| State Management | BLoC Pattern |
| Authentication | Supabase Auth |
| Database | Supabase (PostgreSQL) |
| Real-time | Supabase Realtime |
| Storage | Supabase Storage |
| Backend API | Golang (separate repo) |
| Navigation | GoRouter |

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── env_config.dart          # Environment configuration
│   ├── constants/
│   │   ├── api_constants.dart       # API endpoints
│   │   └── app_constants.dart       # App constants
│   ├── router/
│   │   └── app_router.dart          # GoRouter configuration
│   ├── services/
│   │   └── supabase_service.dart    # Supabase client & realtime
│   ├── theme/
│   │   └── app_theme.dart           # App theme (light/dark)
│   └── utils/
│       ├── validators.dart          # Input validators
│       └── date_utils.dart          # Date utilities
├── data/
│   ├── datasources/
│   │   └── api_client.dart          # HTTP client (Dio)
│   ├── models/
│   │   ├── ticket_model.dart        # Ticket, Comment, Attachment models
│   │   ├── user_model.dart          # User model
│   │   └── auth_response_model.dart # Auth response model
│   └── repositories/
│       ├── ticket_repository.dart   # Ticket data repository
│       └── auth_repository.dart     # Auth data repository
├── domain/
│   ├── entities/
│   │   ├── ticket_entity.dart       # Ticket entity
│   │   ├── comment_entity.dart      # Comment entity
│   │   └── user_entity.dart         # User entity
│   └── usecases/
│       ├── login_usecase.dart       # Login use case
│       ├── logout_usecase.dart      # Logout use case
│       ├── get_tickets_usecase.dart # Get tickets use case
│       └── create_ticket_usecase.dart # Create ticket use case
└── presentation/
    ├── screens/
    │   ├── splash_screen.dart       # Splash screen
    │   ├── login_screen.dart        # Login screen
    │   ├── register_screen.dart     # Register screen
    │   ├── reset_password_screen.dart # Reset password screen
    │   ├── profile_screen.dart      # Profile screen
    │   ├── notification_screen.dart # Notification screen
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart # Dashboard
    │   └── tickets/
    │       ├── ticket_list_screen.dart    # Ticket list with filters
    │       ├── ticket_detail_screen.dart  # Ticket detail
    │       └── create_ticket_screen.dart  # Create ticket
    └── widgets/
        ├── ticket_card_widget.dart   # Ticket card widget
        ├── loading_widget.dart       # Loading indicator
        ├── empty_widget.dart         # Empty state
        └── error_widget.dart         # Error state
```

## 🚀 Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Environment Config

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Configure Environment

Edit `.env` file:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Backend API Configuration
API_BASE_URL=http://localhost:8080/api
```

### 4. Run the App

```bash
flutter run
```

## 👥 User Roles

| Role | Permissions |
|------|-------------|
| **User** | Create tickets, view own tickets, add comments, track status |
| **Helpdesk** | View all tickets, update status, add comments, assign tickets |
| **Admin** | All permissions including user management |

## 📱 Screens

1. **Splash Screen** - App initialization & auth check
2. **Login Screen** - Email/password login
3. **Register Screen** - New user registration
4. **Reset Password Screen** - Password reset flow
5. **Dashboard** - Ticket statistics & quick actions
6. **Ticket List** - All tickets with filters (for admin/helpdesk)
7. **Ticket Detail** - Full ticket info with history & comments
8. **Create Ticket** - New ticket form with attachments
9. **Profile** - User profile & settings
10. **Notifications** - Push notifications list

## 🎨 Theme Support

- Light mode (default)
- Dark mode
- System theme following

Toggle via: `MyApp.of(context).toggleTheme()`

## 🔄 Real-time Features

- Ticket status updates via Supabase Realtime
- New comment notifications
- Assignment notifications

## 📎 File Upload Support

- Images (JPG, PNG, GIF)
- Documents (PDF, DOC, DOCX, XLS, XLSX)
- Max file size: 10MB
- Storage: Supabase Storage bucket 'ticket-attachments'

## 🔧 Backend Integration

The app integrates with a Golang backend for:
- Ticket CRUD operations
- User management
- Authentication (via Supabase)
- Email notifications

Backend repo: (separate repository)

## 🐛 Known Issues

- File picker null safety needs runtime verification
- Some deprecated warnings for `value` in DropdownButtonFormField (will be fixed in next Flutter version)

## 📝 To-Do

- [ ] Add unit tests
- [ ] Add integration tests
- [ ] Implement offline mode
- [ ] Add push notifications (Firebase)
- [ ] Add chat support
- [ ] Implement ticket escalation
- [ ] Add SLA tracking
- [ ] Add reporting/analytics

## 📄 License

Proprietary - All rights reserved

## 👨‍💻 Development Team

- Frontend: Flutter/Dart
- Backend: Golang
- Database: Supabase (PostgreSQL)
