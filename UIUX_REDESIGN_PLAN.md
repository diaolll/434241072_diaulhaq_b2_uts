# UI/UX Redesign Plan - E-Ticketing App

## Problems Identified

### 1. AppTheme - Missing Helper Methods
- `statusColor(String status)` - Return color based on ticket status
- `priorityColor(String priority)` - Return color based on priority
- `statusLabel(String status)` - Return Indonesian label for status
- `priorityLabel(String priority)` - Return Indonesian label for priority
- `errorColor`, `warningColor`, `successColor`, `textSecondaryColor` - Used but not defined

### 2. Missing Common Widgets
- `TicketCard` - For displaying ticket in list
- `StatCard` - For dashboard statistics
- `StatCardShimmer` - Loading state for StatCard
- `AppDropdown` - Consistent dropdown input
- `InfoCard` - Information card with icon
- `ProfileCard` - User profile display
- `MenuItemCard` - List menu item
- `AppSwitch` - Custom switch widget
- `EmptyState` - Empty state display (partially exists)

### 3. Inconsistencies Across Screens
| Screen | Issues |
|--------|--------|
| Splash | Good - consistent |
| Login | Good - consistent |
| Dashboard | Uses SliverAppBar, good structure |
| TicketList | References non-existent widgets |
| TicketDetail | References non-existent widgets |
| CreateTicket | Uses non-existent AppDropdown |
| Profile | Good structure |
| Settings | Uses non-existent widgets |

### 4. SRS Compliance Check
| Requirement | Status |
|-------------|--------|
| Splash Screen | ✅ Complete |
| Login Screen | ✅ Complete |
| Dashboard | ✅ Complete with stats & chart |
| List Tiket | ⚠️ Needs widget fixes |
| Detail Tiket | ⚠️ Needs widget fixes |
| Create Tiket | ⚠️ Needs widget fixes |
| Profile | ✅ Complete |
| Dark/Light Mode | ✅ Complete via ThemeService |

## Solution Strategy

### Phase 1: Fix AppTheme (Foundation)
Add all missing helper methods and color constants

### Phase 2: Create Missing Common Widgets
Build reusable widgets in `lib/presentation/widgets/common/`

### Phase 3: Fix Screen Implementations
Update each screen to use consistent widgets and styling

### Phase 4: Verify SRS Compliance
Ensure all screens meet requirements

## Design Principles

1. **Consistent Spacing**: 8px base unit (8, 12, 16, 24, 32)
2. **Consistent Border Radius**: 8px (cards), 12px (buttons), 16px (dialogs)
3. **Consistent Colors**: Use AppTheme constants only
4. **Responsive**: Support all screen sizes
5. **Accessible**: Proper contrast ratios
