# MindLess — Development Logbook

This logbook documents all architecture choices, UI implementations, refactorings, and modifications performed on the MindLess digital wellbeing application.

---

## 1. Project Overview & Design System

**MindLess** is an intentional living and digital wellness Flutter application designed with an organic, calm, and minimalist aesthetic.

### Visual Identity Tokens
- **Background Palette**: Warm oat milk / cream tone (`#FAF7F2`)
- **Primary Accent**: Deep forest pine green (`#132F21`, `#163223`)
- **Secondary Accents**: Sage / mint green (`#7CE2A5`, `#D7EBDC`, `#CDE8D4`), warm stone (`#F4F0E8`, `#F5F2EA`), and warning coral/amber (`#C73D2C`, `#E09F5E`)
- **Typography**: Refined high-contrast serif headlines paired with crisp, clean sans-serif body and technical labels.
- **Brand Emblem**: Vector botanical 3-petal lotus/sprout symbol.

---

## 2. Comprehensive Changelog

### Phase 1: Home Screen Implementation (`lib/pages/home.dart`)
- **Top Header**:
  - Implemented custom vector `_MindlessLogo` using `CustomPainter`.
  - Added stylized brand title `MindLess` (`Mind` upright serif, `Less` italic serif).
- **Date & Sync Indicator**:
  - `"TUE, 9 SEP 2026"` uppercase date stamp.
  - Active status pill with pulsing indicator (`🟢 Synced just now`).
- **Hero Title**:
  - Prominent serif headline: `"Focus on\n"` + italicized `"what matters."`
- **Interactive Calendar Strip**:
  - Horizontal selector with 5 day cards: `Mon 07`, `Tue 08`, `Wed 09`, `Thu 10`, `Fri 11`.
  - Active selection highlighting `Wed 09` with deep pine background and mint indicator dot.
- **Weekly Average Card**:
  - Deep forest green curved container with subtle organic overlay shape.
  - Subheader with `"WEEKLY AVERAGE"` and comparison chip (`↘ 12% vs last week`).
  - Metric display: `"2h 15m / day"`.
  - 3-day comparative bar chart (`M`, `T`, `W`) featuring a glowing mint green gradient on active day `W`.
  - Target tracking footer: `"Target: < 2h 30m"` & `"5 of 7 days on track"`.
- **Streak Intact Card**:
  - Custom circular ring progress painter (`5 DAYS`).
  - Status display: `"Streak Intact 🔥"` with ceiling description.
  - Interactive `"Limits"` slider pill button.
- **Most Used Apps Section**:
  - Section header with `"Today"` badge and `"See All >"` action.
  - **Instagram**: Camera gradient squircle, warning chip `▲ +25m over`, limit time, and coral progress bar.
  - **TikTok**: Dark circular glyph, `+12m over` warning chip, and amber progress bar.
  - **Messages**: Sage squircle, `✓ Safe` mindful zone chip, and 35% dark green mindful progress bar.
- **Midday Pause Insight Card**:
  - Lightbulb header with uppercase label.
  - Zen garden thumbnail image with offline botanical fallback widget.
  - Formatted reflection highlighting a 34% drop in morning unlocks.
- **Daily Quote**:
  - Circular `"99"` quotation mark badge.
  - *“A better you is a series of small choices.”* in italic serif typography.

---

### Phase 2: Navigation Bar Component (`lib/navigation/navbar.dart`)
- Created a dedicated, reusable navigation bar widget.
- **Initial Implementation**: Built custom vector painters for House, Pulse Trend Line, and Profile User.
- **Simplification Refactor**: Refactored to Flutter's native, lightweight `BottomNavigationBar`:
  - `BottomNavigationBarItem` for **Home** (`Icons.home_outlined` / `Icons.home`).
  - `BottomNavigationBarItem` for **Progress** (`Icons.show_chart_rounded`).
  - `BottomNavigationBarItem` for **Profile** (`Icons.person_outline_rounded` / `Icons.person_rounded`).
  - Fixed background color (`#FAF7F2`) with subtle top border (`#EBE6DC`).
  - Dark forest green active/inactive typography (`#16221A`).
  - Aliased as `MindlessNavBar`, `CustomNavBar`, `NavBar`, and `SimpleBottomNavBar`.

---

### Phase 3: Wellbeing Impact & Progress Screen (`lib/pages/progress.dart`)
- **Top Header**:
  - Unified MindLess botanical emblem and centered serif typography.
- **Wellbeing Impact Card**:
  - Rounded deep forest green container (`#132F21`).
  - Header with health shield icon, `"Wellbeing Impact"`, and `"🟢 Live Tracker"` pill badge.
  - **Time Reclaimed Sub-Card**:
    - Metric: `"+1h 45m today"`.
    - `"Doomscrolling Blocked: 42 triggers"` alongside `"78% Goal"`.
    - 78% mint glowing progress bar.
    - Circular stopwatch icon badge.
  - **Optic Fatigue & Eye Health Sub-Card**:
    - Metric: `"+38% Strain Reduced"` with `"Optimal"` badge.
    - Detail row: `"-2.4h Blue-light"` and `"✓ Blink rate steady"`.
    - Circular eye outline badge.
- **Quick Action Grid (4 Actions)**:
  - **Focus**: Sprout icon in sage circle.
  - **Limits**: Hourglass icon in sage circle.
  - **Goals**: Sparkle/stars icon in sage circle.
  - **Pause**: Heart icon in sage circle.
- **Today's Intention Card**:
  - Warm stone container (`#F4F0E8`).
  - Circular quote badge with `"99"`.
  - Header: `"TODAY'S INTENTION"`.
  - *“A better you is a series of small, gentle choices.”* in italic serif.
  - Reading estimate: `"Daily Reflection  •  10 min read"`.
- **Navigation Integration**:
  - Integrated `MindlessNavBar` with `currentIndex: 1`.
  - Seamless bidirectional routing with `HomePage` and `ProfilePage`.

---

### Phase 4: Profile & Mindful Sanctuary Screen (`lib/pages/profile.dart`)
- **Top Header**:
  - Unified MindLess botanical emblem and centered serif typography.
- **Profile Hero Card**:
  - Circular portrait with white border and bottom-right dark green leaf badge.
  - `"Mindful Tier • Member since Sep 2025"` verified chip.
  - `"Aisha Morales"` serif title and `"@aisha.calm"` handle.
  - Action buttons: **Edit Profile** (with tune icon) and circular **Share** button.
- **3-Column Stats Strip**:
  - **Growth & Progress**: `"24d"` with sprout badge.
  - **Reclaimed**: `"42h"` with hourglass badge.
  - **Inner Peace**: `"89%"` with peach calm face badge.
- **Sanctuary Core Card**:
  - Deep green container with organic overlay curve.
  - Lotus icon, `"SANCTUARY CORE"`, and `"🟢 Protected"` pill badge.
  - `"Your Mindful Baseline"` with mindful engagement description.
  - **Daily Focus Ceiling**: Phone icon, `"2h 30m maximum"`, and `"Active"` status pill.
  - **Sleep Scheduled**: Moon icon, `"10:00 PM – 7:00 AM"`, and `"Every Night"` text.
- **Mindful Controls Section**:
  - Section header with `"Updated today"` timestamp.
  - **App Limits & Blockers**: Pause/shield icon, `"4 apps paused (Instagram, Snapchat)"`, and chevron.
  - **Notification Whispers**: Bell icon, `"Gentle haptic vibrations only"`, and interactive animated toggle switch.
- **Footer**:
  - Version info: `"MindLess v2.4.1 • Crafted for Intentional Living"`.
- **Navigation Integration**:
  - Integrated `MindlessNavBar` with `currentIndex: 2`.
  - Seamless bidirectional routing with `HomePage` and `ProgressPage`.

---

### Phase 5: Header Avatar Removal Across All Pages
- **User Request**: *"remove avator from every pages"*.
- **Rationale**: Since the application now features dedicated bottom navigation with an explicit Profile tab, having a redundant user avatar in the top navigation bar across every screen was unnecessary and cluttered the interface.
- **Modifications**:
  1. [`lib/pages/home.dart`](file:///e:/mindless/lib/pages/home.dart): Removed top-bar profile avatar from `_buildTopBar`. Added balance spacer to maintain perfect optical centering.
  2. [`lib/pages/progress.dart`](file:///e:/mindless/lib/pages/progress.dart): Removed top-bar profile avatar from `_buildTopBar`. Added balance spacer.
  3. [`lib/pages/profile.dart`](file:///e:/mindless/lib/pages/profile.dart): Removed top-bar profile avatar from `_buildTopBar`, unifying the header across the entire application (`[Logo] ---- [MindLess] ---- [Spacer]`).

---

### Phase 6: Application Entry, Theming & Smoke Tests
- **`lib/main.dart`**:
  - Configured `MindlessApp` with custom Material 3 ThemeData.
  - Set scaffold background to `#FAF7F2` and primary seed color to `#163223`.
  - Designated `HomePage` as application root.
- **`test/widget_test.dart`**:
  - Updated unit and widget tests to mount `MindlessApp`.
  - Validates `HomePage`, `MindlessNavBar`, and tab labels (`Home`, `Progress`, `Profile`).
- **Static Analysis**:
  - Verified with Dart Analysis tools (`analyze_files`). Zero errors, zero warnings across all project files.

---

### Phase 7: Spacing & Selected Date Fine-Tuning (`lib/pages/home.dart`)
- **Spacing Adjustment**:
  - Reduced vertical spacing between `_buildDateAndSyncRow()` and `_buildMainHeadline()` from `10.0` to exactly `6.25`.
- **Selected Date Scaling**:
  - Elevated selected day pill dimensions: width increased to `66` (unselected `60`), height increased to `84` (unselected `76`).
  - Increased selected date numeral font size to `22.0` with `FontWeight.w800` (unselected `18.0` / `FontWeight.w700`).
  - Enhanced day name font size to `12.5` (unselected `11.5`) and indicator dot to `5.0`.
  - Added soft shadow (`blurRadius: 12`, `offset: Offset(0, 4)`) for a floating card effect on the active date.

---

### Phase 8: Horizontal Calendar Strip Spacing & Selected Date Expansion (`lib/pages/home.dart`)
- **Spacing Between Strip Cards**:
  - Configured exact `6.25` spacing between adjacent date pills inside `_buildCalendarStrip()`.
  - Implemented responsive `Expanded(flex: isSelected ? 6 : 5)` with symmetrical `3.125` half-gaps, ensuring exactly `6.25` pixel separation across all screen densities.
- **Vertical Spacing Above Calendar Strip**:
  - Reduced vertical spacing between `_buildMainHeadline()` and `_buildCalendarStrip()` from `22.0` to `6.25`.
- **Selected Date Scaling**:
  - Expanded selected card height to `86.0` (unselected `74.0`).
  - Increased active date numeral font size to `23.0` with `FontWeight.w800` (unselected `17.5` / `w700`).
  - Enhanced active card corner radius to `24.0` and elevated shadow (`blurRadius: 14`, `offset: Offset(0, 4)`).

---

### Phase 9: 7-Day Weekly Average Card Replacement in `_buildCalendarStrip` (`lib/pages/home.dart`)
- **Replacement of `_buildCalendarStrip()`**:
  - Replaced the date pill strip at line 52 with the complete 7-Day Weekly Average Chart card matching the newly provided design mockup.
  - Removed duplicate `_buildWeeklyAverageCard()` from the page layout for a streamlined, clutter-free vertical hierarchy.
- **7-Day Interactive Bar Chart**:
  - Displays all 7 days of the week: `M`, `T`, `W`, `T`, `F`, `S`, `S`.
  - Day 1 (`M`): `2h 40m` (height `74`).
  - Day 2 (`T`): `1h 55m` (height `52`).
  - Day 3 (`W` — Active/Selected): `1h 20m` (height `40`), highlighted with a luminous mint gradient (`[#A5F4C7, #55C786]`), glow shadow (`blurRadius: 14`), white numeral/label typography.
  - Day 4 (`T`): `2h 10m` (height `58`).
  - Day 5 (`F`): `3h 05m` (height `84`, weekly peak).
  - Day 6 (`S`): `1h 45m` (height `46`).
  - Day 7 (`S`): `1h 10m` (height `30`).
  - Made every bar interactive with animated state updates on tap.
- **Card Framing & Details**:
  - Subheaders: `"WEEKLY AVERAGE"` and `"12% vs last week"` pill chip.
  - Large serif metric: `"2h 15m / day"`.
  - Added subtle divider rules above and below the 7-bar chart.
  - Footer tracker: `"Target: < 2h 30m"` and `"5 of 7 days on track"`.

---

### Phase 10: Complete Navigation & Action Refactor (`Focus`, `Limits`, `Pause`)
- **Combined App Time Removal**:
  - Removed `_buildUsageLimitCard` from `lib/pages/home.dart` layout and cleaned up dead code.
- **Profile Page Removal**:
  - Deleted `lib/pages/profile.dart` completely.
  - Refactored `MindlessNavBar` (`lib/navigation/navbar.dart`) to 2 core tabs: `Home` and `Progress`.
  - Implemented `createMindlessPageRoute`: elegant animated page transitions (curved fade and slide) when switching between pages for a finished, polished feel.
- **Centered App Bar**:
  - Removed botanical logo icons from the app bar on all pages.
  - Centered simple, elegant `MindLess` serif title across all screens.
- **Action Grid Refactor in Progress Page**:
  - Removed the `"Goals"` card from `lib/pages/progress.dart`.
  - Balanced the row with 3 equally spaced, responsive `Expanded` action cards: **Focus**, **Limits**, and **Pause**.
- **Functional Action Implementations**:
  1. **Focus (`lib/pages/focus_timer.dart`)**:
     - Dedicated mindfulness Focus Timer screen.
     - Focus area selector for specific parts of the day ("Deep Work", "Study", "Reading", "Creative", "Mindful Pause").
     - Prominent duration suggestions: **25 minutes** (Pomodoro / Deep Focus) and **15 minutes** (Quick Sprint), plus custom +/- steppers.
     - Circular animated countdown timer with progress ring and live time display.
     - Start, pause, resume, reset controls, and mindful completion feedback.
  2. **Limits (`lib/widgets/usage_limit_sheet.dart`)**:
     - Interactive modal bottom sheet to configure daily screen time limits.
     - Clock dial time picker integration (`showTimePicker`) and hour/minute steppers.
     - Quick preset chips (2h, 3h 30m, 4h, 5h, 6h).
     - Live updating via `UsageLimitProvider.setDailyLimit(duration)`.
  3. **Pause (`lib/pages/minimal_launcher.dart`)**:
     - Manual toggle to open distraction-free Minimal Launcher.
     - Added prominent manual close and exit controls to return seamlessly to MindLess.


