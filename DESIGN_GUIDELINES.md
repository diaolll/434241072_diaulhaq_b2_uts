# 🎨 UI Design Guidelines - E-Ticketing Helpdesk

> **Clean iOS Style • No Gradients • Monochrome Contrast**

> **Version:** 1.0.0
> **Last Updated:** 2026-04-17
> **Design System:** Flutter Material 3 with iOS-inspired aesthetics

---

## 📐 Core Principles

1. **NO GRADIENTS** - Solid colors only
2. **iOS Minimalist** - Clean, lots of whitespace
3. **High Contrast** - Black/White for primary actions
4. **Subtle Borders** - 0.5px for depth
5. **Consistent Radius** - 12-14px for cards/buttons
6. **Dark Mode Native** - Full theme support
7. **Accessibility First** - WCAG AA compliance

---

## 🎨 Colors

### Always use `AppTheme` from `core/theme/app_theme.dart`

```dart
import '../../../core/theme/app_theme.dart';
```

### Dark Mode Detection
```dart
final isDark = context.isDark;
```

### Color Palette Reference

| Usage | Light Mode (Hex) | Dark Mode (Hex) | Variable |
|-------|-----------------|-----------------|----------|
| **Background** | `#F2F2F7` | `#000000` | surface1 / dark0 |
| **Card** | `#FFFFFF` | `#1C1C1E` | surface0 / dark1 |
| **Input** | `#FFFFFF` | `#2C2C2E` | surface0 / dark2 |
| **Border** | `#E5E5EA` | `#3A3A3C` | surface2 / dark3 |
| **Border (subtle)** | `#D1D1D6` | `#48484A` | surface3 / dark4 |
| **Primary Text** | `#000000` | `#FFFFFF` | black / white |
| **Secondary Text** | `#6E6E73` | `#8E8E93` | textSecondary / textSecondaryDark |
| **Tertiary Text** | `#AEAEB2` | `#636366` | textTertiary / textTertiaryDark |

### Status Colors

| Status | Color (Hex) | Background Light | Background Dark |
|--------|-------------|------------------|-----------------|
| **Open** | `#3478F6` (Blue) | `#EBF2FF` | `#0A2550` |
| **In Progress** | `#FF9500` (Orange) | `#FFF4E6` | `#3D2400` |
| **Resolved** | `#34C759` (Green) | `#E8F9ED` | `#0A3018` |
| **Closed** | `#8E8E93` (Gray) | `#F2F2F7` | `#2C2C2E` |

### Priority Colors

| Priority | Color (Hex) | Background Light | Background Dark |
|----------|-------------|------------------|-----------------|
| **Low** | `#34C759` (Green) | `#E8F9ED` | `#0A3018` |
| **Medium** | `#FF9500` (Orange) | `#FFF4E6` | `#3D2400` |
| **High** | `#FF3B30` (Red) | `#FFEBEB` | `#3D0A0A` |
| **Critical** | `#FF2D55` (Pink) | `#FFEBEF` | `#3D0A14` |

### Notification Badge Colors

| Element | Color (Hex) |
|---------|-------------|
| **Badge Background** | `#FF0000` (Red) |
| **Badge Text** | `#FFFFFF` (White) |

### Helper Methods

```dart
// Status helpers
AppTheme.statusLabel('open')              // 'Open'
AppTheme.statusColor('in_progress')      // Color
AppTheme.statusBgColor('resolved', isDark: true)  // Color

// Priority helpers
AppTheme.priorityLabel('high')           // 'High'
AppTheme.priorityColor('critical')       // Color
AppTheme.priorityBgColor('medium', isDark: false)  // Color
```

---

## 📝 Typography

### Font Family

```dart
fontFamily: 'SF Pro Display'
```
> Falls back to system font if SF Pro not available

### Typography Scale

| Size | Weight | Letter Spacing | Usage |
|------|--------|----------------|-------|
| **28** | Bold | - | Large page titles |
| **26** | 700 (Bold) | -0.8 | Main headers ("Dashboard") |
| **17** | 700 (Bold) | -0.3 | Screen titles (AppBar) |
| **16** | 600 (SemiBold) | -0.2 | Primary buttons |
| **15** | 600 (SemiBold) | -0.2 | Secondary buttons, labels |
| **14** | 400-500 | - | Body text, content |
| **13** | 600 (SemiBold) | | Section headers, form labels |
| **12** | 500-600 | | Captions, metadata |
| **11** | 600-700 | | Badges, chips |
| **10** | 600 (SemiBold) | | Bottom nav labels |
| **9** | 500 (Medium) | | Small nav labels |
| **8** | 700 (Bold) | | Notification badge count |

### Common Text Styles

```dart
// AppBar Title
TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.3,
)

// Section Header
TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
)

// Form Label
TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
)

// Body Text
TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
)

// Caption / Metadata
TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
)

// Badge / Chip
TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
)
```

---

## 📐 Border Radius

### Radius Scale

| Size | Value | Usage |
|------|-------|-------|
| **xs** | 6px | Small badges, chips |
| **sm** | 8px | Small buttons, tags |
| **md** | 10px | Icon buttons, avatar containers |
| **lg** | 12px | Buttons, inputs, dialogs |
| **xl** | 14px | Cards, containers |
| **2xl** | 16px | Large cards, modals |
| **full** | 20px | Full dialogs, sheets |

### Common Patterns

```dart
// Cards, Containers
BorderRadius.circular(14)

// Buttons, Inputs
BorderRadius.circular(12)

// Icon containers
BorderRadius.circular(9-11)

// Small badges, chips
BorderRadius.circular(6-8)

// Avatar
BorderRadius.circular(10-12)

// FAB
BorderRadius.circular(16)
```

---

## 📏 Spacing

### 4px Grid System

All spacing follows a 4px base unit for consistency.

| Token | Value | Usage |
|-------|-------|-------|
| **xs** | 4px | Badge padding, tiny gaps |
| **sm** | 8px | Small gaps between elements |
| **md** | 12px | Icon + text spacing, list items |
| **lg** | 16px | Card padding, default spacing |
| **xl** | 20px | Page margins, section spacing |
| **2xl** | 24px | Button padding vertical, form screens |
| **3xl** | 32px | Section separators |
| **4xl** | 100px | Bottom padding for nav clearance |

### Common Spacing Patterns

```dart
// Page margins
EdgeInsets.fromLTRB(20, 20, 20, 0)

// Card padding
EdgeInsets.all(14)

// List item padding
EdgeInsets.symmetric(horizontal: 16, vertical: 12)

// Button padding
EdgeInsets.symmetric(horizontal: 24, vertical: 14)

// Input padding
EdgeInsets.symmetric(horizontal: 16, vertical: 14)

// Screen with bottom nav
EdgeInsets.fromLTRB(16, 8, 16, 100)
```

### Vertical Spacing

```dart
const SizedBox(height: 4)   // xs - tiny gap
const SizedBox(height: 8)   // sm - small gap
const SizedBox(height: 12)  // md - medium gap
const SizedBox(height: 16)  // lg - standard gap
const SizedBox(height: 24)  // xl - section separator
const SizedBox(height: 32)  // 2xl - large separator
```

---

## 🧩 Common Components

### 1. Scaffold Pattern

```dart
Scaffold(
  backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
  appBar: AppBar(
    backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_rounded, size: 18, 
                  color: isDark ? AppTheme.white : AppTheme.black),
      onPressed: () => context.pop(),
    ),
    title: Text('Screen Title', 
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, 
                              color: isDark ? AppTheme.white : AppTheme.black)),
  ),
  body: ...,
)
```

### 2. Card Pattern

```dart
Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: isDark ? AppTheme.dark1 : AppTheme.surface0,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: isDark ? AppTheme.dark3 : AppTheme.surface2,
      width: 0.5,  // Always 0.5 for subtle border
    ),
  ),
  child: ...,
)
```

### 3. Primary Button

```dart
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: isDark ? AppTheme.white : AppTheme.black,
      foregroundColor: isDark ? AppTheme.black : AppTheme.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: Text('Button Text', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
  ),
)
```

### 4. Secondary Button (Outline)

```dart
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: isDark ? AppTheme.white : AppTheme.black,
    side: BorderSide(
      color: isDark ? AppTheme.dark3 : AppTheme.surface2,
      width: 1,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: Text('Button Text'),
)
```

### 5. Text Field / Input

```dart
TextFormField(
  style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black),
  decoration: InputDecoration(
    hintText: 'Placeholder',
    hintStyle: TextStyle(fontSize: 14, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
    filled: true,
    fillColor: isDark ? AppTheme.dark2 : AppTheme.surface0,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: isDark ? AppTheme.white : AppTheme.black, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppTheme.priorityHigh, width: 1),
    ),
  ),
)
```

### 6. Icon Container

```dart
Container(
  width: 36-44,
  height: 36-44,
  decoration: BoxDecoration(
    color: isDark ? AppTheme.dark2 : AppTheme.surface1,
    borderRadius: BorderRadius.circular(9-11),
  ),
  child: Icon(Icons.icon_name, size: 16-20, 
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
)
```

### 7. Badge / Chip

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 7-9, vertical: 3-5),
  decoration: BoxDecoration(
    color: bgColor,  // Use AppTheme.*BgColor methods for status/priority
    borderRadius: BorderRadius.circular(5-8),
  ),
  child: Text('Label', style: TextStyle(fontSize: 10-12, fontWeight: FontWeight.w700, color: labelColor)),
)
```

### 8. Loading Indicator

```dart
Center(
  child: CircularProgressIndicator(
    strokeWidth: 2,
    color: isDark ? AppTheme.white : AppTheme.black,
  ),
)
```

### 9. Empty State

```dart
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.inbox_outlined, size: 40, 
           color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
      const SizedBox(height: 12),
      Text('Empty Title', style: TextStyle(
           fontSize: 15, fontWeight: FontWeight.w600, 
           color: isDark ? AppTheme.white : AppTheme.black)),
      const SizedBox(height: 4),
      Text('Empty description', style: TextStyle(
           fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
    ],
  ),
)
```

### 10. List Item / Menu Item

```dart
GestureDetector(
  onTap: () {},
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.dark1 : AppTheme.surface0,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
    ),
    child: Row(
      children: [
        // Icon container
        Container(
          width: 32-36,
          height: 32-36,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.dark2 : AppTheme.surface1,
            borderRadius: BorderRadius.circular(8-9),
          ),
          child: Icon(Icons.menu, size: 16-18, 
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
        ),
        const SizedBox(width: 12),
        // Text
        Expanded(child: Text('Menu Item', style: TextStyle(
             fontSize: 14, fontWeight: FontWeight.w500, 
             color: isDark ? AppTheme.white : AppTheme.black))),
        // Arrow
        Icon(Icons.chevron_right_rounded, size: 18, 
             color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
      ],
    ),
  ),
)
```

---

## 🚫 DON'Ts

❌ **NEVER use gradients**
```dart
// BAD
gradient: LinearGradient(...)

// GOOD
color: isDark ? AppTheme.dark1 : AppTheme.surface0
```

❌ **NEVER use ModernTheme or ElegantTheme**
```dart
// BAD
import '../../../core/theme/modern_theme.dart';
color: ModernTheme.primary

// GOOD
import '../../../core/theme/app_theme.dart';
final isDark = context.isDark;
color: isDark ? AppTheme.white : AppTheme.black
```

❌ **NEVER use withOpacity** (deprecated)
```dart
// BAD
color: Colors.white.withOpacity(0.5)

// GOOD
color: Colors.white.withValues(alpha: 0.5)
```

❌ **DON'T use shadows/boxShadow for depth**
```dart
// BAD
boxShadow: [BoxShadow(...)]

// GOOD - use borders instead
border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5)
```

❌ **DON'T use heavy elevation**
```dart
// BAD
elevation: 4

// GOOD
elevation: 0
```

---

## ✅ DOs

✅ **Always detect dark mode**
```dart
final isDark = context.isDark;
```

✅ **Use subtle borders for depth**
```dart
border: Border.all(color: ..., width: 0.5)
```

✅ **Use consistent spacing**
```dart
const SizedBox(height: 8)   // small
const SizedBox(height: 12)  // medium
const SizedBox(height: 16)  // standard
const SizedBox(height: 24)  // large
```

✅ **Use semantic color methods from AppTheme**
```dart
AppTheme.statusLabel(status)
AppTheme.statusColor(status)
AppTheme.statusBgColor(status, isDark: isDark)
AppTheme.priorityLabel(priority)
AppTheme.priorityColor(priority)
AppTheme.priorityBgColor(priority, isDark: isDark)
```

---

## 📱 Screen Template

Copy this for a new screen:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, 
                      color: isDark ? AppTheme.white : AppTheme.black),
          onPressed: () => context.pop(),
        ),
        title: Text('Screen Title', 
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, 
                                  color: isDark ? AppTheme.white : AppTheme.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Section Header
          Text(
            'Section Title',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.white : AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),

          // Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.dark1 : AppTheme.surface0,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppTheme.dark3 : AppTheme.surface2,
                width: 0.5,
              ),
            ),
            child: ...,
          ),
        ],
      ),
    );
  }
}
```

---

## 🔍 Icon Guidelines

Use **Material Icons** with `_rounded` suffix for iOS feel:

```dart
Icons.arrow_back_ios_rounded
Icons.home_rounded
Icons.settings_outlined
Icons.person_outline_rounded
Icons.chevron_right_rounded
Icons.close_rounded
Icons.add_rounded
Icons.notifications_outlined
Icons.search_rounded
Icons.refresh_rounded
Icons.confirmation_number_rounded    // Tickets
Icons.pending_rounded                 // In Progress
Icons.check_rounded                   // Resolved
Icons.lock_outline_rounded            // Closed
Icons.inbox_rounded                   // Open
```

### Icon Sizes

| Size | Usage |
|------|-------|
| **16px** | Small inline icons |
| **18px** | List icons, menu items, back button |
| **20px** | Button icons, header icons |
| **22px** | Bottom nav icons |
| **24px+** | FAB icons, empty states |

---

## 🔔 Notification Badge

### Specification

| Property | Value |
|----------|-------|
| Background Color | `#FF0000` (Red) |
| Text Color | `#FFFFFF` (White) |
| Shape | Circle |
| Padding | 3-4px all around |
| Font Size | 7-8px |
| Font Weight | Bold (700) |
| Position | Top-right offset (-2 to -4px) |
| Max Display | "9+" for counts > 9 |

### Implementation

```dart
// Notification icon with badge
Stack(
  clipBehavior: Clip.none,
  children: [
    Icon(
      Icons.notifications_outlined,
      size: 20,
      color: isDark ? AppTheme.white : AppTheme.black,
    ),
    if (unreadCount > 0)
      Positioned(
        right: -2,
        top: -2,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Text(
            unreadCount > 9 ? '9+' : unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
  ],
)
```

### Usage Locations

1. **Dashboard Header** - Top right notification button
2. **Bottom Navigation** - Notification icon
3. **Profile Menu** - Notification menu item

---

## 📊 Quick Reference

| Element | Size | Radius | Notes |
|---------|------|--------|-------|
| AppBar Height | 56 | - | No elevation |
| Button Height | 50 | 12 | Full width |
| Input Height | 50 | 12 | 16px h padding |
| Card Padding | 14 | 14 | 0.5px border |
| FAB Size | 56 | 16 | No elevation |
| Icon Container | 36-44 | 9-11 | Square |
| Badge/Chip | - | 6-8 | Status/priority |
| Border Width | - | 0.5 | Subtle depth |
| Page Margin | 20 | - | Left/right |

---

## 🎯 Remember

> **"Less is More"** - Keep it clean, minimal, and consistent.
> **No gradients, no shadows, no fancy effects.**
> **Just solid colors, subtle borders, and good typography.**

---

## 📚 File References

| File | Description |
|------|-------------|
| `lib/core/theme/app_theme.dart` | Complete theme definition |
| `lib/data/providers/providers.dart` | Notification provider with badge |

---

*Last updated: 2026-04-17*
