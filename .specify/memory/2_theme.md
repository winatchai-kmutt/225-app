## Theme (App-Wide): Neo-Brutalist Fintech

### 1. Manifest & Brand Voice

- **Brand Voice:** Modern, Playful, but also Clear & Trustworthy.
    
- **Design Style:** Neo-Brutalism (Soft Style). This style is defined by:
    
    - Using an Off-white or Beige background.
        
    - Using floating white Cards.
        
    - **Thick, clear borders** (usually black) on all elements.
        
    - **Hard shadows** (no blur) with a distinct offset (usually black).
        
    - Using bright colors as accents and for buttons.
        
    - Using thick, clear Sans-serif typography.
        

### 2. Color System (Semantic Tokens)

This is the color system analyzed from the reference image (HEX values are estimates):

**Core Palette:**

- `background`: `#FAF8F1` (Beige/Off-white app background)
    
- `surface`: `#FFFFFF` (White for Cards, Bottom Bar, and Keypad)
    
- `surfaceDisabled`: `#E0E0E0` (Light gray for disabled backgrounds)
    
- `textPrimary`: `#000000` (Main Text, Headers, Numbers)
    
- `textSecondary`: `#8A8A8E` (Gray for secondary text, e.g., 'Your balance', Subtitles)
    
- `border`: `#000000` (Border color **CRITICAL**)
    
- `borderDisabled`: `#BDBDBD` (Gray for disabled borders)
    
- `shadow`: `#000000` (Shadow color **CRITICAL**)
    

**Action Colors (CTA):**

- `primary`: `#FDEE8A` (Creamy Yellow for main buttons 'Get started', 'Transfer Now')
    
- `onPrimary`: `#000000` (Text/Icon color on `primary` buttons)
    
- `secondary`: `#F0E4FF` (Light Purple for secondary button 'Request')
    
- `onSecondary`: `#000000` (Text/Icon color on `secondary` buttons)
    

**Accent & Sticker Colors:**

- `accentPink`: `#FFD6F5`
    
- `accentGreen`: `#D3FFAE`
    
- `accentPurple`: `#E4D6FF` (Purple for 'Import' sticker)
    

**Semantic Colors (Tonal):**

- `success`: `#4CAF50` (Or a slightly darker green for `+ $11.50`)
    
- `error`: `#F44336` (Or a red/pink for `- $25.00`)
    

**Dark Mode Mapping (Guidelines):**

- Swap `background` and `surface`.
    
- `textPrimary` becomes `#FFFFFF`.
    
- `textSecondary` becomes a lighter gray.
    
- `border` and `shadow` may need to become a dark gray (e.g., `#333333`) to remain visible.
    

### 3. Typography (Fonts and Type Roles)

- **Font Families:** `Inter` (for English/Numbers), `Noto Sans Thai` (for Thai)
    
- **Roles:**
    
    - `Display:` (e.g., "Set up your wallet") - `FontWeight.w700` (Bold), `fontSize: 28`
        
    - `Title (Large):` (e.g., "$8,320.50", "$250.00") - `FontWeight.w700` (Bold), `fontSize: 26`
        
    - `Title (Medium):` (e.g., "Hello, Teja", "Transfer") - `FontWeight.w600` (SemiBold), `fontSize: 20`
        
    - `Body (Large):` (e.g., "Get started", "Alex Messidoro", "Nathania Queen") - `FontWeight.w600` (SemiBold), `fontSize: 16`
        
    - `Body (Small):` (e.g., "Your balance") - `FontWeight.w400` (Regular), `fontSize: 14`
        
    - `Caption:` (e.g., "Oct 28 2023...") - `FontWeight.w400` (Regular), `fontSize: 12`
        
    - `Keypad:` (e.g., "1", "2", "3") - `FontWeight.w600` (SemiBold), `fontSize: 22`
        

### 4. Shape, Density & Style

These are the core components of this Neo-Brutalism style.

- **Radii (Corner Radius):**
    
    - `Large (l):` `20.0` (For Cards, Bottom Bar, Keypad Container)
        
    - `Medium (m):` `16.0` (For CTA Buttons)
        
    - `Circle (xl):` `99.0` (For Avatars, 'New' icon, Close button)
        
    - `Small (s):` `8.0` (For Page Indicator dots)
        
- **Borders:**
    
    - `borderWidth`: `1.5`
        
    - `borderColor`: `ColorSystem.border` (Black)
        
- **Shadows:**
    
    - `blurRadius`: `0.0` (No blur)
        
    - `shadowColor`: `ColorSystem.shadow` (Black)
        
    - `offset`: `Offset(3, 3)` (Drop shadow offset 3px right, 3px down)
        
    - `offsetPressed`: `Offset(1, 1)` (Reduced offset for "pressed" state)
        
- **Spacing:**
    
    - `Grid Unit:` `8.0`
        
    - `Page Padding:` `16.0` (Excluding full-bleed screens)
        
    - `Card Padding:` `20.0`
        
    - `List Item Padding:` `Vertical: 12.0`, `Horizontal: 16.0`
        

#### 4.1 Motion & Animation

- **Page Transitions (`go_router`):**
    
    - **Main Routes (e.g., Home -> Transfer):** `SlideTransition` (horizontal, `Offset(1, 0)` to `Offset(0, 0)`)
        
    - **Modal Routes (e.g., Tapping "Nathania Queen"):** `SlideTransition` (vertical, `Offset(0, 1)` to `Offset(0, 0)`)
        
- **Micro-interactions (Button Taps):**
    
    - **OnTapDown:** Animate `shadowOffset` from `Offset(3, 3)` to `Offset(1, 1)` (Pressed State). `Duration: 100ms`, `Curve: Curves.easeOut`.
        
    - **OnTapUp/Cancel:** Animate `shadowOffset` from `Offset(1, 1)` back to `Offset(3, 3)`. `Duration: 150ms`, `Curve: Curves.easeOutBack` (slight bounce).
        
- **Sticker Animation (Onboarding):**
    
    - (Optional) Gentle "floating" animation using `AnimatedContainer` or `Transform.translate` driven by a `Sine` wave.
        

### 5. Components Defaults (Key Component Styles)

The defining feature of this style is that most widgets (Button, Card) use the same structure: **Container + Border + Hard Shadow**

#### 5.1 Reusable Widget Concept: `NeoContainer`

Instead of using `Card` or `ElevatedButton` directly, we will create a reusable `NeoContainer` widget to wrap other elements and apply this style consistently. This container must handle different states (e.g., `isPressed`, `isDisabled`).

```
// This is the implementation concept (not final code)
Widget NeoContainer({
  Widget child,
  Color backgroundColor = ColorSystem.surface,
  double borderRadius = Radii.Medium,
  Offset shadowOffset = Offsets.Default,
  bool isDisabled = false,
  bool isPressed = false,
}) {
  final currentOffset = isPressed ? Shape.offsetPressed : (isDisabled ? Offset.zero : Shape.offset);
  final currentBg = isDisabled ? ColorSystem.surfaceDisabled : backgroundColor;
  final currentBorder = isDisabled ? ColorSystem.borderDisabled : ColorSystem.border;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    curve: Curves.easeOut,
    decoration: BoxDecoration(
      color: currentBg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: currentBorder,
        width: Shape.borderWidth,
      ),
      boxShadow: [
        if (!isDisabled) // No shadow when disabled
          BoxShadow(
            color: ColorSystem.shadow,
            blurRadius: 0.0,
            offset: currentOffset,
          ),
      ],
    ),
    child: child,
  );
}
```

#### 5.2 Component Styles (Static)

- **Buttons (Primary - Yellow):**
    
    - **Build:** From `InkWell` + `NeoContainer`
        
    - `backgroundColor`: `ColorSystem.primary`
        
    - `borderRadius`: `Radii.Medium (16.0)`
        
    - `Content:` `Text` (Style: `Typography.Body (Large)`, Color: `ColorSystem.onPrimary`)
        
- **Buttons (Secondary - Purple):**
    
    - **Build:** `InkWell` + `NeoContainer`
        
    - `backgroundColor`: `ColorSystem.secondary`
        
    - `borderRadius`: `Radii.Medium (16.0)`
        
    - `Content:` `Text` (Style: `Typography.Body (Large)`, Color: `ColorSystem.onSecondary`)
        
- **"Decorative Stickers" (Onboarding):**
    
    - **Build:** `NeoContainer` (No `InkWell`)
        
    - `shape`: **Special** (Requires `CustomClipper` or `ShapeBorder`)
        
    - `backgroundColor`: `ColorSystem.accentPink`, `accentGreen`, `accentPurple`
        
    - `border`: `BorderSide(width: Shape.borderWidth, color: ColorSystem.border)`
        
- **Avatars (`CircleAvatar`):**
    
    - **Build:** Stacked `CircleAvatar` (2 layers)
        
    - **Outer:** `CircleAvatar(radius: 25.5, backgroundColor: ColorSystem.border)`
        
    - **Inner:** `CircleAvatar(radius: 24.0, backgroundImage: ...)`
        
- **Icons (Default - e.g., in Bottom Bar):**
    
    - `style`: **Filled** (e.g., `Icons.settings`)
        
    - `selectedColor`: `ColorSystem.textPrimary (Black)`
        
    - `unselectedColor`: `ColorSystem.textSecondary (Gray)`
        
- **Icon Buttons (Standard - White Close Button):**
    
    - **Build:** `InkWell` + `NeoContainer`
        
    - `backgroundColor`: `ColorSystem.surface (White)`
        
    - `borderRadius`: `Radii.Circle (99.0)`
        
    - `Content:` `Icon(Icons.close, color: ColorSystem.textPrimary)`
        
- **Icon Buttons (Special - "New" / "Home"):**
    
    - **"New" Button:** `InkWell` + `NeoContainer` (`backgroundColor: ColorSystem.textPrimary (Black)`, `borderRadius: Radii.Circle (99.0)`, `child: Icon(Icons.add, color: Colors.white)`)
        
    - **"Home" Button:** `InkWell` + `NeoContainer` (`backgroundColor: ColorSystem.primary (Yellow)`, `borderRadius: Radii.Medium (16.0)`, `child: Icon(Icons.home, color: ColorSystem.onPrimary (Black))`)
        
- **Bottom Navigation Bar (`BottomAppBar`):**
    
    - **Build:** `NeoContainer` as background for `BottomAppBar`.
        
    - `backgroundColor`: `ColorSystem.surface`
        
    - `borderRadius`: `Radii.Large (20.0)` (Top corners only)
        
    - `shadowOffset`: `Offset(0, -3)` (Shadow goes up)
        
    - `border`: `Border(top: BorderSide(width: Shape.borderWidth, color: ColorSystem.border))`
        
    - `Icons`: Use `Icons (Default - Filled)` style.
        
    - `Home Button (Special):` Implement using the `Icon Buttons (Special - "Home")` style.
        
- **Cards (Recent Transactions):**
    
    - **Build:** Standard `NeoContainer`.
        
    - `backgroundColor`: `ColorSystem.surface`
        
    - `borderRadius`: `Radii.Large (20.0)`
        
- **Cards (User Selector - Transfer Page):**
    
    - **Build:** `InkWell` + `NeoContainer`
        
    - `backgroundColor`: `ColorSystem.surface`
        
    - `borderRadius`: `Radii.Large (20.0)`
        
    - `Content:` `ListTile` (`leading`: `Avatar`, `title`: `Text`, `trailing`: `Icon(Icons.arrow_forward_ios)`)
        
- **ListTiles (ListTile - Transaction):**
    
    - `leading`: `Avatar` (using `Avatars` style)
        
    - `title`: `Typography.Body (Large)`
        
    - `subtitle`: `Typography.Caption`
        
    - `trailing`: `Text` (Style: `Typography.Body (Large)`, Color: `ColorSystem.success` or `ColorSystem.error`)
        
- **Keypad (Transfer Page):**
    
    - **Numeric Buttons:** `TextButton` (`foregroundColor: ColorSystem.textPrimary`, `shape: CircleBorder()`, `textStyle: Typography.Keypad`)
        
    - **Icon Button (Backspace):** `IconButton` (Style like Numeric, but `icon: Icon(Icons.backspace_outlined)`)
        
- **PageIndicator (Onboarding):**
    
    - **Build:** Use `smooth_page_indicator`.
        
    - `activeDotColor`: `ColorSystem.textPrimary (Black)`
        
    - `dotColor`: `ColorSystem.textSecondary.withOpacity(0.3)`
        
    - `dotHeight/Width`: `8.0`
        

#### 5.3 Component States (Interactive)

- **Buttons (Pressed State):**
    
    - **Rule:** All `NeoContainer`-based buttons (`Primary`, `Secondary`, `Icon`) MUST change their `shadowOffset` from `Offset(3, 3)` to `Shape.offsetPressed` (`Offset(1, 1)`) while being pressed.
        
    - **Implementation:** This is handled by the `isPressed` flag in the `NeoContainer` concept, driven by an `InkWell`'s `onTapDown` and `onTapUp`.
        
- **Buttons (Disabled State):**
    
    - **Rule:** When disabled (e.g., "Transfer Now" before amount is entered), the `NeoContainer` MUST change its style.
        
    - `backgroundColor`: `ColorSystem.surfaceDisabled` (Light gray)
        
    - `border`: `ColorSystem.borderDisabled` (Darker gray)
        
    - `shadow`: **None** (No shadow)
        
    - `Content:` `Text` color changes to `ColorSystem.textSecondary`
        
- **Text Inputs (Error State):**
    
    - **Rule:** When `TextFormField` has an error:
        
    - `border`: `OutlineInputBorder` `borderSide` color MUST change to `ColorSystem.error`.
        

#### 5.4 Ephemeral Components (Pop-ups)

- **Dialogs / Modals (e.g., "Confirm Transfer?"):**
    
    - **Build:** Must be built using `NeoContainer`.
        
    - `backgroundColor`: `ColorSystem.surface`
        
    - `borderRadius`: `Radii.Large (20.0)`
        
    - `shadowOffset`: `Offset(3, 3)`
        
    - **Content:** Should contain `Typography.TitleMedium`, `Typography.BodySmall`, and `Buttons (Primary/Secondary)` for actions.
        
- **SnackBars / Toasts (e.g., "Transfer Sent!"):**
    
    - **Build:** Must be built using `NeoContainer`.
        
    - `backgroundColor`: `ColorSystem.success` (or `ColorSystem.error`)
        
    - `borderRadius`: `Radii.Medium (16.0)`
        
    - `shadowOffset`: `Offset(3, 3)`
        
    - `Content:` `Icon(Icons.check_circle, color: Colors.white)` + `Text` (Style: `Typography.Body (Large)`, Color: `Colors.white`)
        

### 6. Flutter Mapping (ThemeData)

This is the guideline for setting up `ThemeData` (though most widgets will be custom-built using `NeoContainer`).

```
// In app.dart or theme_provider.dart

ThemeData get appTheme {
  return ThemeData(
    // 1. Colors
    scaffoldBackgroundColor: ColorSystem.background,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: ColorSystem.primary,
      onPrimary: ColorSystem.onPrimary,
      secondary: ColorSystem.secondary,
      onSecondary: ColorSystem.onSecondary,
      surface: ColorSystem.surface,
      onSurface: ColorSystem.textPrimary,
      background: ColorSystem.background,
      onBackground: ColorSystem.textPrimary,
      error: ColorSystem.error,
      onError: Colors.white,
      // ... etc.
    ),

    // 2. Typography
    textTheme: TextTheme(
      displayLarge: Typography.Display,
      titleLarge: Typography.TitleLarge,
      titleMedium: Typography.TitleMedium,
      bodyLarge: Typography.BodyLarge,
      bodyMedium: Typography.BodySmall, // Mapping BodySmall -> bodyMedium
      bodySmall: Typography.Caption,     // Mapping Caption -> bodySmall
      // ...
    ).apply(
      bodyColor: ColorSystem.textPrimary,
      displayColor: ColorSystem.textPrimary,
      fontFamily: 'Inter', // Or primary font
    ),

    // 3. Component Themes
    // **Warning: Most of this Neo-Brutalism style MUST be custom-built.**
    
    cardTheme: CardTheme(
      elevation: 0,
      color: ColorSystem.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.Large),
        side: BorderSide(color: ColorSystem.border, width: Shape.borderWidth),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: ColorSystem.primary,
        foregroundColor: ColorSystem.onPrimary,
        disabledBackgroundColor: ColorSystem.surfaceDisabled, // Disabled State
        disabledForegroundColor: ColorSystem.textSecondary,  // Disabled State
        textStyle: Typography.BodyLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.Medium),
          side: BorderSide(color: ColorSystem.border, width: Shape.borderWidth),
        ),
      ).copyWith(
        // Handle disabled border color
        side: MaterialStateProperty.resolveWith<BorderSide>((states) {
          if (states.contains(MaterialState.disabled)) {
            return BorderSide(color: ColorSystem.borderDisabled, width: Shape.borderWidth);
          }
          return BorderSide(color: ColorSystem.border, width: Shape.borderWidth);
        }),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorSystem.textPrimary,
        textStyle: Typography.BodyLarge.copyWith(fontWeight: FontWeight.w500),
        shape: CircleBorder(), 
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: ColorSystem.surface,
        foregroundColor: ColorSystem.textPrimary,
        shape: CircleBorder(
          side: BorderSide(color: ColorSystem.border, width: Shape.borderWidth),
        ),
        elevation: 0,
      ),
    ),

    bottomAppBarTheme: BottomAppBarTheme(
      color: ColorSystem.surface,
      elevation: 0,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: ColorSystem.primary,
      foregroundColor: ColorSystem.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.Medium),
        side: BorderSide(color: ColorSystem.border, width: Shape.borderWidth),
      ),
    ),
    
    listTileTheme: ListTileThemeData(
      titleTextStyle: Typography.BodyLarge,
      subtitleTextStyle: Typography.Caption.copyWith(color: ColorSystem.textSecondary),
      iconColor: ColorSystem.textSecondary,
    ),

    circleAvatarTheme: CircleAvatarThemeData(
      backgroundColor: ColorSystem.surface, 
    ),

    iconTheme: IconThemeData(
      color: ColorSystem.textSecondary,
      size: 24.0,
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: ColorSystem.textPrimary,
      unselectedItemColor: ColorSystem.textSecondary,
      selectedIconTheme: IconThemeData(color: ColorSystem.textPrimary),
      unselectedIconTheme: IconThemeData(color: ColorSystem.textSecondary),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorSystem.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.Medium),
        borderSide: BorderSide(color: ColorSystem.border, width: Shape.borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.Medium),
        borderSide: BorderSide(color: ColorSystem.border, width: Shape.borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.Medium),
        borderSide: BorderSide(color: ColorSystem.primary, width: Shape.borderWidth),
      ),
      // Error State
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.Medium),
        borderSide: BorderSide(color: ColorSystem.error, width: Shape.borderWidth),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.Medium),
        borderSide: BorderSide(color: ColorSystem.error, width: Shape.borderWidth),
      ),
      // Disabled State
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.Medium),
        borderSide: BorderSide(color: ColorSystem.borderDisabled, width: Shape.borderWidth),
      ),
    ),

    // Ephemeral Components
    snackBarTheme: SnackBarThemeData(
      elevation: 0,
      backgroundColor: Colors.transparent, // We use a custom NeoContainer
      contentTextStyle: Typography.BodyLarge.copyWith(color: Colors.white),
    ),

    dialogTheme: DialogTheme(
      elevation: 0,
      backgroundColor: ColorSystem.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.Large),
        side: BorderSide(color: ColorSystem.border, width: Shape.borderWidth),
      ),
    ),

  );
}
```