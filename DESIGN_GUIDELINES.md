# 🎨 UI Design Guidelines - E-Ticketing Helpdesk

> **Clean iOS Style • No Gradients • Monochrome Contrast**

---

## 📐 Core Principles

1. **NO GRADIENTS** - Solid colors only
2. **iOS Minimalist** - Clean, lots of whitespace
3. **High Contrast** - Black/White for primary actions
4. **Subtle Borders** - 0.5px for depth
5. **Consistent Radius** - 12-14px for cards/buttons

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

### Color Palette

| Usage | Light Mode | Dark Mode |
|-------|-----------|-----------|
| Background | `AppTheme.surface1` | `AppTheme.dark0` |
| Card/Surface | `AppTheme.surface0` | `AppTheme.dark1` |
| Input Field | `AppTheme.surface0` | `AppTheme.dark2` |
| Border (subtle) | `AppTheme.surface2` | `AppTheme.dark3` |
| Border (very subtle) | `AppTheme.surface3` | `AppTheme.dark4` |
| Primary Text | `AppTheme.black` | `AppTheme.white` |
| Secondary Text | `AppTheme.textSecondary` | `AppTheme.textSecondaryDark` |
| Tertiary Text | `AppTheme.textTertiary` | `AppTheme.textTertiaryDark` |
| Primary Action BG | `AppTheme.black` | `AppTheme.white` |
| Primary Action FG | `AppTheme.white` | `AppTheme.black` |
| Error | `AppTheme.priorityHigh` | same |

---

## 📝 Typography

```dart
// AppBar Title
TextStyle(fontSize: 17, fontWeight: FontWeight.w700)

// Section Header
TextStyle(fontSize: 15, fontWeight: FontWeight.w700)

// Form Label
TextStyle(fontSize: 13, fontWeight: FontWeight.w600)

// Body Text
TextStyle(fontSize: 14, fontWeight: FontWeight.w400)

// Caption
TextStyle(fontSize: 11-12, fontWeight: FontWeight.w600)

// Small/Meta
TextStyle(fontSize: 10-11, fontWeight: FontWeight.w500)
```

---

## 📐 Border Radius

```dart
// Cards, Containers
BorderRadius.circular(14)

// Buttons, Inputs
BorderRadius.circular(12)

// Small elements (badges, chips)
BorderRadius.circular(6-8)

// Avatar
BorderRadius.circular(10-12)

// FAB
BorderRadius.circular(14)
```

---

## 📏 Spacing

```dart
const EdgeInsets.all(16)           // Default padding
const EdgeInsets.all(14)           // Card content
const EdgeInsets.symmetric(horizontal: 16, vertical: 12)  // List items
const EdgeInsets.fromLTRB(16, 8, 16, 100)  // Screen with FAB
const EdgeInsets.symmetric(horizontal: 24)  // Form screens
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
```

---

## 📊 Quick Reference

| Element | Size | Radius |
|---------|------|--------|
| AppBar Height | 56 | - |
| Button Height | 50 | 12 |
| Input Height | 50 | 12 |
| Card Padding | 14 | 14 |
| FAB Size | 56 | 14 |
| Icon Container | 36-44 | 9-11 |
| Border Width | - | 0.5 (subtle) |

---

## 🎯 Remember

> **"Less is More"** - Keep it clean, minimal, and consistent.
> **No gradients, no shadows, no fancy effects.**
> **Just solid colors, subtle borders, and good typography.**

---

*Last updated: 2025*
