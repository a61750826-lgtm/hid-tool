# DESIGN.md — HID Tool Design System
*(Authored in accordance with Google Stitch Design Specification & Material You Guidelines)*

## 1. Atmosphere & Brand Identity
* **Philosophy**: "Google System Tool / Pixel Hardware Utility"
* **Style**: Google Material 3 (Material You) Expressive. Clean, purposeful, and ergonomic.
* **Atmospheric Rules**:
  * **No pitch-black OLED / AI neon glow**: Avoid harsh #000000 backgrounds and cybernetic neon-purple gradients.
  * **Tonal Hierarchy**: Depth is communicated via Material 3 tonal elevation and surface container color shifts (`surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`), never high-contrast harsh shadows.
  * **Google Apps Cleanliness**: Generous whitespace, soft 20dp–28dp rounded container corners, expressive pill badges, and fluid Android 12+ spring curves.

---

## 2. Color Palette & Semantic Tokens

### Dynamic M3 Palette (Dark Mode Base)
* **Background (`surface`)**: `#121316` (Refined deep charcoal)
* **Surface Dim**: `#0E0F12`
* **Surface Container Low**: `#1A1B1F`
* **Surface Container**: `#212328`
* **Surface Container High**: `#2B2D33`
* **Surface Container Highest**: `#36383E`
* **Outline / Border**: `#44474E`
* **Outline Variant**: `#2E3036`

### Semantic Accents (Google Tonal Harmony)
* **Primary (Google Blue)**: `#8AB4F8` (Foreground/Icon), `#1A73E8` (Container/Brand)
* **Success / Live (Google Green)**: `#81C995` (Text), `#137333` (Container)
* **Warning / Armed (Google Amber)**: `#FDD663` (Text), `#B06000` (Container)
* **Alert / Disconnect (Google Red)**: `#F28B82` (Text), `#C5221F` (Container)
* **On-Surface (Primary Text)**: `#E3E3E3`
* **On-Surface-Variant (Muted Text)**: `#C4C7C5`

---

## 3. Typography Hierarchy
* **Display / Hero Titles**: Google Sans / Inter (Clean geometric sans-serif, bold weight, optical kerning).
* **Body / Subtitles**: Roboto / Inter Regular, high legibility at 14sp–16sp.
* **Code / USB Descriptors / Scancodes**: JetBrains Mono / Roboto Mono (Tabular numbers, monospaced alignment for byte outputs).

---

## 4. Component Standards

### 4.1 Telemetry Header (Google Settings Style)
* Top floating rounded pill card showing:
  * USB Controller status (`USB High-Speed 480Mbps`)
  * Kernel Gadget state (`ConfigFS /dev/hidg0`)
  * Root access indicator (`Magisk Root Active`)
* Micro-status dot: Soft breathing Google Green indicator.

### 4.2 Main Navigation Cards
* 24dp rounded corner containers (`SurfaceContainerHigh`).
* Left-anchored Google-style filled tonal icon pill (e.g. `Usb`, `Bluetooth`, `PowerSettingsNew`).
* Title in `titleLarge` with subtle trailing chevron.

### 4.3 Virtual USB Keyboard (Gboard Inspired)
* **Layout**: Authentic physical keyboard experience.
* **Keycaps**: Rounded rectangular keys (`8dp` radius) with subtle top highlight and soft bottom edge bevel simulating key travel.
* **Active Press**: Key pops up with magnification bubble and triggers `HapticFeedback.lightImpact()`.
* **Modifier Bar**: Dedicated pill chips for `Ctrl`, `Alt`, `GUI (Win)`, `Shift`, `Esc`, `Tab` with active indicator dots.
* **Landscape Mode**: Expands seamlessly into full desktop-grade 100% keyboard layout.

### 4.4 Virtual USB Trackpad (Canvas Style)
* Frosted surface with tactile perimeter guide.
* Multi-touch support: 1-finger drag (pointer), 1-finger tap (left click), 2-finger tap (right click), 2-finger slide (wheel).
* Tactile bottom buttons: Dual split pill containers for Left and Right clicks.
* Sensitivity Pill: Floating segmented button (0.5x, 1x, 2x, 4x).

### 4.5 Payloads Studio (DuckyScript / BadUSB)
* Monospace editor with syntax highlighting for keywords (`DELAY`, `STRING`, `ENTER`, `GUI`, `REM`).
* One-tap payload library chips at the top.
* Floating "Execute" and "Abort" pill buttons with live countdown timer.

---

## 5. Anti-Patterns & Guardrails
* ❌ NO harsh pure `#000000` background with glowing saturated neon lines.
* ❌ NO AI generic placeholder text or empty dummy containers.
* ❌ NO tiny un-tappable buttons (All tap targets >= 48dp).
* ❌ NO non-responsive hardcoded pixel widths.
