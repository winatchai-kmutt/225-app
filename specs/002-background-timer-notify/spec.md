# Feature Specification: Background Timer & Notification Permission

**Feature Branch**: `002-background-timer-notify`  
**Created**: November 3, 2025  
**Status**: Draft  
**Input**: User description: "[US 2.3: Background Timer & Notify] — Goal: As a user, I want to grant notification permissions during onboarding, and I expect the timer to continue running and notify me when a session ends, even if the app is in the background or my screen is locked."

## Clarifications

### Session 2025-11-03

- Q: Should timer completion notifications include sound and/or vibration to alert users? → A: Sound and vibration follow device notification settings (recommended for most apps)
- Q: Should timer state be preserved when the user normally closes the app (swipes away from app switcher)? → A: Preserve timer state (user can resume where they left off)
- Q: Should timer completion notifications include action buttons for quick interactions? → A: No action buttons (tap notification to open app only)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Notification Permission Onboarding (Priority: P1)

During first-time app setup, the user encounters a dedicated screen (Onboarding S5) that requests notification permissions. The screen clearly explains why notifications are needed: to alert users when a timer session completes, even when the app is in the background. The user taps a single "Allow Notifications" button, which triggers the native OS permission dialog. After responding to the dialog (either Allow or Deny), the user is automatically navigated to the next onboarding step (Paywall Screen).

**Why this priority**: This is P1 because notification permissions are essential for the core timer functionality to work when the app is backgrounded. Without this permission request flow, users may not understand why they need notifications, and the background timer feature becomes less valuable. This is a one-time setup that enables the entire background timer feature.

**Independent Test**: Can be fully tested by launching the app for the first time, proceeding through onboarding to the notification permission screen, and verifying that: (1) the screen renders correctly with proper explanation text, (2) tapping the button triggers the OS permission dialog, (3) the button provides proper haptic and audio feedback, and (4) navigation proceeds to the Paywall Screen regardless of the user's permission choice.

**Acceptance Scenarios**:

1. **Given** the user has never launched the app before, **When** the user completes the previous onboarding steps and reaches Onboarding S5 (Notification Permission screen), **Then** the screen displays a notification icon, title "Enable Notifications", explanatory text about why notifications are needed, and a yellow "Allow Notifications" button
2. **Given** the user is viewing the Notification Permission screen, **When** the user taps the "Allow Notifications" button, **Then** the native OS notification permission dialog appears
3. **Given** the user is viewing the Notification Permission screen, **When** the user taps the "Allow Notifications" button, **Then** haptic feedback (light impact) is triggered and the UI click sound (`ui_click_neo.mp3`) plays
4. **Given** the OS notification permission dialog is showing, **When** the user selects "Allow" or "Don't Allow", **Then** the app navigates to the Paywall Screen
5. **Given** the user has already granted or denied notification permissions, **When** the user reopens the app, **Then** the Notification Permission onboarding screen is never shown again (it's a one-time flow)

---

### User Story 2 - Background Timer Execution (Priority: P1)

A user starts a Pomodoro timer session from the Timer Screen, then backgrounds the app by pressing the home button, switching to another app, or locking the device screen. The timer continues to count down accurately in the background without requiring the app to remain in the foreground. The timer state is preserved through the backgrounding event and continues execution until completion.

**Why this priority**: This is P1 because it's the core value proposition of this feature. Users expect timers to work like alarms—they should run regardless of whether the app is actively visible. Without reliable background timer execution, the app becomes unusable for productivity workflows where users need to multitask while a timer runs.

**Independent Test**: Can be fully tested by starting a timer (e.g., 25-minute Pomodoro session), immediately backgrounding the app, waiting for the full duration, and verifying that: (1) the timer completes at the expected time, (2) timer state is preserved when returning to the app mid-session, and (3) timer accuracy is within acceptable tolerance (±2 seconds over 25 minutes).

**Acceptance Scenarios**:

1. **Given** a user has started a 25-minute Pomodoro timer on the Timer Screen, **When** the user presses the home button to background the app, **Then** the timer continues running in the background without interruption
2. **Given** a timer is running in the background, **When** the user waits 10 minutes and returns to the app, **Then** the Timer Screen displays the correct remaining time (approximately 15 minutes remaining)
3. **Given** a timer is running in the background, **When** the user locks their device screen, **Then** the timer continues running accurately
4. **Given** a timer is running in the background, **When** the timer completes, **Then** the timer state transitions to "completed" even if the user hasn't returned to the app
5. **Given** a timer is running in the background for 25 minutes, **When** the timer completes, **Then** the elapsed time is accurate within ±2 seconds of the expected duration

---

### User Story 3 - Background Completion Notification (Priority: P1)

When a timer session completes while the app is in the background or the device screen is locked, the system delivers a local notification to the user. The notification has a clear title ("Session Complete!") and informative body text (e.g., "Time for a 5-minute break."). This notification appears in the device's notification center and, depending on device settings, may also appear as a banner, play a sound, or trigger a vibration.

**Why this priority**: This is P1 because it's the user-facing payoff of the background timer feature. Without a notification, users have no way to know when their timer has completed unless they manually check the app. The notification is what makes the background timer truly useful—it enables users to focus on other tasks and be alerted when it's time to take a break or start a new session.

**Independent Test**: Can be fully tested by starting a short timer (e.g., 1 minute for testing purposes), backgrounding the app, waiting for the timer to complete, and verifying that: (1) a notification appears with the correct title and body text, (2) the notification is delivered even when the screen is locked, and (3) tapping the notification reopens the app to the Timer Screen.

**Acceptance Scenarios**:

1. **Given** a timer is running in the background and notification permissions have been granted, **When** the timer completes, **Then** a local notification appears with the title "Session Complete!"
2. **Given** a timer completes in the background, **When** the notification is delivered, **Then** the notification body displays "Time for a 5-minute break."
3. **Given** a timer completes while the device screen is locked, **When** the timer reaches zero, **Then** the notification still appears on the lock screen (subject to device notification settings)
4. **Given** a notification for a completed timer is displayed, **When** the user taps the notification, **Then** the app opens and navigates to the Timer Screen
5. **Given** notification permissions were denied during onboarding, **When** a timer completes in the background, **Then** no notification is delivered (but the timer still completes correctly)

---

### Edge Cases

- What happens when the user force-quits the app while a timer is running?
  - The timer should stop (this is expected behavior for force-quit scenarios). Users should be informed that force-quitting will stop the timer.
  
- What happens when the device runs out of battery or reboots while a timer is running?
  - The timer will not resume after reboot. This is acceptable standard behavior. Timer state should be cleared on app restart after device reboot. However, timer state IS preserved across normal app closures (swiping away from app switcher).
  
- What happens when the user starts multiple timers in quick succession?
  - Only one timer should be active at a time. Starting a new timer should cancel any currently running timer.
  
- What happens when the user denies notification permissions but still uses the background timer?
  - The timer continues to run accurately in the background, but no notification is delivered. The app should handle this gracefully without errors.
  
- What happens when system notification settings are changed after initial permission grant?
  - The app should respect the current system settings. If notifications are later disabled at the OS level, no notifications will be delivered, but timers continue to work.
  
- What happens when the user backgrounds the app, then immediately returns before the timer completes?
  - The Timer Screen should display the correct remaining time without any visible glitch or reset.
  
- What happens when multiple notification permission requests occur (e.g., user reinstalls the app)?
  - The OS will remember the previous permission decision. The app should check the current permission status and only show the permission dialog if it hasn't been determined yet.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display an Onboarding S5 (Notification Permission) screen during first-time app setup that includes:
  - A notification icon (`Icons.notifications_active_outlined`, size 48, color: textSecondary)
  - Title text: "Enable Notifications" (Typography: TitleMedium, center-aligned)
  - Explanatory body text: "We need this to alert you when a session ends, even if the app is in the background." (Typography: BodyLarge, color: textSecondary, center-aligned)
  - A primary NeoButton with text "Allow Notifications" (yellow/primary color)

- **FR-002**: System MUST trigger the native OS notification permission dialog when the user taps the "Allow Notifications" button on Onboarding S5

- **FR-003**: System MUST trigger haptic feedback (`HapticFeedback.lightImpact()`) on `onTapDown` when the user taps the "Allow Notifications" button

- **FR-004**: System MUST play the audio file `assets/sounds/ui_click_neo.mp3` on `onTapDown` when the user taps the "Allow Notifications" button

- **FR-005**: System MUST navigate to the Paywall Screen after the user responds to the OS notification permission dialog, regardless of whether they chose "Allow" or "Deny"

- **FR-006**: System MUST never show the Notification Permission onboarding screen again after the user has completed it once (one-time flow per app installation)

- **FR-007**: System MUST continue timer execution when the app is sent to the background (home button, app switcher, or screen lock)

- **FR-008**: System MUST maintain timer accuracy within ±2 seconds over a 25-minute period when running in the background

- **FR-009**: System MUST preserve timer state (current elapsed time, total duration, session type) when the app is backgrounded and restored

- **FR-009a**: System MUST preserve timer state across normal app closures (when user swipes away app from app switcher), allowing users to resume where they left off upon reopening

- **FR-010**: System MUST deliver a local notification when a timer completes while the app is in the background or the device screen is locked

- **FR-011**: System MUST include the following content in timer completion notifications:
  - Title: "Session Complete!"
  - Body: "Time for a 5-minute break."
  - Sound and vibration behavior: Follow device notification settings (respect user's system preferences for notification sounds and vibration)

- **FR-012**: System MUST only deliver timer completion notifications if notification permissions have been granted by the user

- **FR-013**: System MUST handle notification permission denial gracefully, allowing timers to continue running without notifications

- **FR-014**: System MUST navigate to the Timer Screen when the user taps a timer completion notification (no action buttons required; single tap interaction only)

- **FR-015**: System MUST stop the timer if the user force-quits the app (this is expected behavior and does not require recovery)

- **FR-016**: System MUST ensure only one timer can be active at a time (starting a new timer cancels any currently running timer)

- **FR-017**: System MUST conform to the UI design specifications in the Neo-Brutalist Fintech theme (as defined in `.specify/memory/2_theme.md`), including:
  - `Scaffold` background color: `ColorSystem.background`
  - `SafeArea` + `Padding(24.0)` + `Column(mainAxisAlignment: .center, crossAxisAlignment: .stretch)` layout
  - NeoButton component with primary color (yellow) and proper haptic/audio interaction
  - Proper spacing using `SizedBox` widgets (16.0 between icon and title, 32.0 between text and button)

- **FR-018**: System MUST conform to the architecture rules defined in `.specify/memory/1_appendix.md`, including proper layer separation (presentation, domain, data) and folder structure

### Key Entities

- **Timer Session**: Represents an active or completed Pomodoro timer session with attributes:
  - Session type (e.g., "Pomodoro", "Short Break", "Long Break")
  - Total duration (in seconds)
  - Elapsed time (in seconds)
  - Start timestamp
  - Completion timestamp (when finished)
  - Current state (running, paused, completed, cancelled)

- **Notification Permission State**: Represents the current notification permission status with attributes:
  - Permission status (not determined, granted, denied, provisional)
  - Timestamp of when permission was last requested
  - Onboarding completion flag (whether user has seen Onboarding S5)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The Notification Permission onboarding screen (Onboarding S5) renders with all required visual elements exactly as specified in the design blueprint (icon, title, body text, button) within 100ms of navigation

- **SC-002**: Tapping the "Allow Notifications" button triggers the native OS permission dialog 100% of the time on both iOS and Android platforms

- **SC-003**: Tapping the "Allow Notifications" button triggers both haptic feedback and audio playback with a combined latency of less than 50ms from tap detection

- **SC-004**: After responding to the OS permission dialog, the app navigates to the Paywall Screen within 500ms with no user-visible errors or crashes

- **SC-005**: Timers running in the background maintain accuracy within ±2 seconds over a 25-minute period in 95% of test cases across various device conditions (battery saver mode, low memory, etc.)

- **SC-006**: Timer state (elapsed time, remaining time) is correctly preserved and displayed when the user returns to the app after backgrounding, with a UI update latency of less than 200ms

- **SC-007**: Local notifications are delivered within 5 seconds of timer completion when the app is in the background, with 100% delivery rate when permissions are granted

- **SC-008**: Timer completion notifications display the correct title ("Session Complete!") and body ("Time for a 5-minute break.") in 100% of delivered notifications

- **SC-009**: Tapping a timer completion notification successfully reopens the app and navigates to the Timer Screen within 1 second, with no data loss or crashes

- **SC-010**: The app handles notification permission denial gracefully with zero crashes or errors, and timers continue to function correctly even without notification delivery capability

- **SC-011**: 90% of users who reach the Notification Permission screen successfully complete the interaction (tap the button and respond to the OS dialog) without backing out or force-quitting

- **SC-012**: Background timer functionality works reliably across both iOS and Android platforms with consistent behavior (timing accuracy, notification delivery, state preservation)
