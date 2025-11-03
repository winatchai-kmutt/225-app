# Feature Specification: Main Timer UI & Controls

**Feature Branch**: `001-main-timer-ui`  
**Created**: November 3, 2025  
**Status**: Draft  
**Input**: User description: "[US 2.1: Main Timer UI & Controls] — Goal: As a user, I want to see a clear, themed timer, know my current session type (WORK/BREAK), and be able to start, pause, reset, and skip the timer using tactile, responsive controls."

## Clarifications

### Session 2025-11-03

- Q: When the user returns to the app after navigating away (lock screen, app switch), should the timer display show the elapsed time or should it show the time when they left? → A: Show elapsed time if timer was running (timer continues in background)
- Q: Should the feature work gracefully on devices that don't support haptic feedback (some Android devices, older phones)? → A: Silently degrade (no haptics, but audio/visual feedback still works)
- Q: What is the acceptable drift tolerance for timer accuracy over a 25-minute session? → A: Negligible drift (±2 seconds over 25 minutes)
- Q: Should FR-043 (quick-adjust controls) be fully implemented or just have layout space reserved? → A: Reserve layout space only (empty placeholder container) - actual quick-adjust functionality will be implemented in a future US. This satisfies layout consistency without blocking this feature.
- Q: Where should the completion flow navigate to (FR-020 "break screen")? → A: Create a simple placeholder break screen with "Break Time!" text for now. Full break screen with timer and controls will be implemented in US 3.1.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete Focus Session with Timer Controls (Priority: P1)

A user opens the app and wants to start a focused work session. They see the timer display showing 25:00, tap the play button to start the timer, watch it count down with visual progress, and when finished, see a celebratory completion animation before transitioning to their break.

**Why this priority**: This is the core value proposition of a Pomodoro timer app - the ability to track focused work time. Without this, the app has no primary function.

**Independent Test**: Can be fully tested by launching the app, tapping play, waiting for the timer to complete (or fast-forwarding in test mode), and verifying the completion animation and transition occurs. This delivers the complete core timer experience.

**Acceptance Scenarios**:

1. **Given** the Timer Screen is displayed with timer at 25:00 and play button visible, **When** user taps the play button, **Then** the timer begins counting down, the progress ring animates, and the button changes to show a pause icon
2. **Given** the timer is running and showing 15:30 remaining, **When** user taps the pause button, **Then** the countdown stops at the current time and the button changes back to show a play icon
3. **Given** the timer has been running or paused at any time value, **When** user taps the reset button, **Then** the timer stops (if running) and resets to display 25:00 with progress ring at full
4. **Given** the timer shows 00:00, **When** countdown completes, **Then** the timer display is hidden, an animated checkmark appears, a success sound plays, and after 800ms the app navigates to the break screen

---

### User Story 2 - Skip Current Session (Priority: P2)

A user is in the middle of a focus session but needs to stop early. They tap the skip button to immediately end the current session, trigger the completion celebration, and move to their break.

**Why this priority**: This provides flexibility for users who need to adapt their schedule or finish early, enhancing the user experience without blocking core functionality.

**Independent Test**: Can be tested by starting any timer session and tapping the skip button at various time points. Verifies that the skip action properly triggers completion flow regardless of remaining time.

**Acceptance Scenarios**:

1. **Given** the timer is running at 18:23 remaining, **When** user taps the skip button, **Then** the timer immediately stops, the completion animation plays, the success sound plays, and navigation to break screen occurs after 800ms
2. **Given** the timer is paused at 10:45 remaining, **When** user taps the skip button, **Then** the same completion flow occurs as if the timer naturally finished
3. **Given** the timer hasn't been started and shows 25:00, **When** user taps the skip button, **Then** the completion flow still executes, treating it as an immediate skip to break

---

### User Story 3 - Visual and Tactile Feedback on Interactions (Priority: P2)

Every time a user interacts with any button (play, pause, reset, skip, or adjustment buttons), they experience immediate tactile haptic feedback, hear a subtle click sound, and see a satisfying shadow animation that makes the button feel like it's being physically pressed into the screen.

**Why this priority**: This creates the distinctive "alive" and "tactile" feel that defines the Neo-Brutalist design language, making the app feel premium and responsive. While important for user satisfaction, the core timer functionality works without it.

**Independent Test**: Can be tested by tapping each button type and verifying haptics fire, sound plays, and shadow animation occurs. This can be validated independently of timer logic.

**Acceptance Scenarios**:

1. **Given** any button on the Timer Screen is visible, **When** user presses down on the button, **Then** a light haptic vibration fires, a click sound plays, and the button's shadow visually shrinks from offset (3,3) to (1,1) over 100ms
2. **Given** any button is in pressed state with reduced shadow, **When** user releases the button, **Then** the shadow animates back to offset (3,3) over 100ms, creating a spring-back effect
3. **Given** user taps multiple buttons rapidly in sequence, **When** each tap occurs, **Then** each button independently animates its shadow and triggers haptics without interference between buttons

---

### User Story 4 - Session Type Awareness (Priority: P3)

A user looks at the Timer Screen and immediately knows whether they're in a "WORK" session or "BREAK" session by seeing a clear label at the top of the screen.

**Why this priority**: This provides contextual awareness but is less critical than the core timer controls. Users can infer session type from timer duration, making this a nice-to-have for clarity.

**Independent Test**: Can be tested by verifying the session type indicator displays "WORK" when on the Timer Screen. (Future stories will test "BREAK" display on the break screen.)

**Acceptance Scenarios**:

1. **Given** the Timer Screen loads for a work session, **When** the screen renders, **Then** the text "WORK" is displayed at the top center of the screen in a bold, visible style
2. **Given** the session type indicator is showing "WORK", **When** the screen remains visible during any timer state (stopped, running, paused), **Then** the indicator continues to display "WORK" consistently

---

### Edge Cases

- What happens when the user navigates away from the app while the timer is running (e.g., locks phone, switches apps)?
  - **Expected**: If the timer was in RUNNING state, it continues counting down in the background. When the user returns to the app, the display shows the current elapsed time (e.g., if they left at 18:00 and return 5 minutes later, timer shows 13:00). If the timer was in PAUSED or STOPPED state, it remains at the same time value when they return.

- What happens if the user taps play/pause repeatedly in quick succession?
  - **Expected**: Each tap registers, toggling between play and pause states. The animation and haptics fire for each tap, but the timer state updates correctly based on the final state.

- What happens if audio files (`ui_click_neo.mp3`, `success_chime.mp3`) fail to load or play?
  - **Expected**: The visual and haptic feedback still works. Audio failure is logged but doesn't block the user experience. A graceful fallback is assumed (silent operation).

- What happens on devices that don't support haptic feedback?
  - **Expected**: The feature gracefully degrades - audio and visual feedback (shadow animations) still work normally. No error messages are shown. The app remains fully functional without haptics.

- What happens when the completion animation is playing and the user tries to interact with the timer?
  - **Expected**: During the 800ms completion animation window, timer controls are disabled to prevent interruption. After navigation to break screen, normal interaction resumes.

- What happens when timer is at 00:01 and user taps pause?
  - **Expected**: Timer pauses at 00:01. User can resume to let it finish naturally, reset it, or skip it.

## Requirements *(mandatory)*

### Functional Requirements

#### Timer Display & State Management

- **FR-001**: System MUST display a timer screen showing the current countdown time in MM:SS format (e.g., "25:00", "18:23", "00:45")
- **FR-002**: System MUST display the current session type ("WORK" or "BREAK") at the top center of the timer screen
- **FR-003**: System MUST render a circular progress indicator that visually represents the remaining time as a percentage of the total session duration
- **FR-004**: System MUST update the countdown display every second when the timer is in running state
- **FR-005**: System MUST maintain timer accuracy within ±2 seconds over a full 25-minute session
- **FR-006**: System MUST update the circular progress ring animation smoothly as time decreases
- **FR-007**: System MUST persist timer state (remaining time, running/paused/stopped state) when the app is backgrounded or user navigates away
- **FR-008**: System MUST continue countdown in background when timer is in RUNNING state
- **FR-009**: System MUST display accurate elapsed time when user returns to app if timer was running in background

#### Timer Control Actions

- **FR-010**: System MUST provide a primary action button that toggles between "play" and "pause" states
- **FR-011**: System MUST display a "play" icon when the timer is stopped or paused
- **FR-012**: System MUST display a "pause" icon when the timer is actively running
- **FR-013**: When the play button is tapped in stopped/paused state, system MUST start the countdown from the current displayed time
- **FR-014**: When the pause button is tapped in running state, system MUST stop the countdown at the current time
- **FR-015**: System MUST provide a reset button that stops any running countdown and returns the timer display to its initial starting time (25:00 for work sessions)
- **FR-016**: System MUST provide a skip button that immediately ends the current session regardless of remaining time

#### Completion Flow

- **FR-017**: When the countdown reaches 00:00, system MUST hide the circular timer display
- **FR-018**: When the countdown reaches 00:00, system MUST display an animated checkmark icon in place of the timer
- **FR-019**: When the countdown reaches 00:00, system MUST play a success sound effect
- **FR-020**: When the countdown reaches 00:00, system MUST automatically navigate to the break screen after an 800ms delay
- **FR-021**: When the skip button is tapped, system MUST trigger the same completion flow as natural timer completion (FR-017 through FR-020)

#### Interactive Feedback

- **FR-022**: System MUST trigger a light haptic vibration when any button (play, pause, reset, skip) is tapped, if device supports haptic feedback
- **FR-023**: System MUST gracefully handle absence of haptic capability without displaying errors or blocking functionality
- **FR-024**: System MUST play a click sound effect when any button is tapped
- **FR-025**: System MUST animate the button shadow from offset (3, 3) to offset (1, 1) over 100ms when a button is pressed down
- **FR-026**: System MUST animate the button shadow back to offset (3, 3) over 100ms when a button is released
- **FR-027**: All button press animations MUST use an ease-out timing curve

#### Visual Design Requirements

- **FR-028**: Timer screen MUST use a cream/off-white background color (#FAF8F1)
- **FR-029**: Circular progress indicator MUST have a track width of 20 pixels with a thick, bold appearance
- **FR-030**: Circular progress indicator MUST have a diameter of 280 pixels
- **FR-031**: Progress ring MUST use rounded stroke caps for the progress arc
- **FR-032**: All buttons MUST have hard-edged shadows (not blurred) consistent with Neo-Brutalist design
- **FR-033**: All buttons MUST have visible borders (typically 2-3px black strokes)
- **FR-034**: Primary action button (play/pause) MUST be yellow colored with pill-shaped border radius (horizontally elongated oval)
- **FR-035**: Secondary action buttons (reset, skip) MUST be white/cream colored and circular
- **FR-036**: Completion checkmark animation MUST use a stroke width of 20 pixels matching the timer ring style
- **FR-037**: Completion checkmark animation MUST draw over 400ms using an ease-out timing curve

#### Screen Layout

- **FR-038**: Timer screen MUST include an app bar at the top with the app title "App 25:5"
- **FR-039**: App bar MUST have zero elevation (flat, blended with background)
- **FR-040**: Session type indicator MUST be positioned at top-center below the app bar
- **FR-041**: Circular timer MUST be positioned in the vertical center of the available space
- **FR-042**: Control buttons (reset, play/pause, skip) MUST be positioned near the bottom of the screen in a horizontal row with equal spacing
- **FR-043**: Layout MUST include space for quick-adjust controls (displayed but non-functional in this US) positioned between the timer and control buttons

### Key Entities

- **Timer Session**: Represents an active focus or break period with attributes: session type (WORK/BREAK), duration (in seconds), remaining time (in seconds), state (stopped/running/paused), start time (timestamp)

- **Session Type**: Enumeration representing whether the current session is a focused work period (WORK) or a break period (BREAK)

- **Timer State**: Enumeration representing the current operational state of the timer (STOPPED, RUNNING, PAUSED, COMPLETED)

- **Visual Feedback State**: Represents the current interaction state for tactile feedback: button identifier, press state (pressed/released), shadow offset, animation progress

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can identify the current session type (WORK/BREAK) within 1 second of viewing the Timer Screen by reading the top indicator
- **SC-002**: Users can start a timer countdown within 2 taps maximum (tap play) from app launch
- **SC-003**: Timer countdown updates visually every second with no perceptible lag or jank (maintains 60fps animation)
- **SC-004**: Timer maintains accuracy within ±2 seconds over a full 25-minute work session
- **SC-005**: Users receive tactile and audio feedback within 50ms of tapping any button
- **SC-006**: Button press animations complete within 100ms of user interaction (press or release)
- **SC-007**: Completion animation sequence (hide timer, show checkmark, play sound, navigate) completes within 1.2 seconds total (400ms animation + 800ms delay)
- **SC-008**: Users can successfully pause, resume, reset, and skip the timer with 100% reliability (no failed interactions)
- **SC-009**: Visual progress ring accurately reflects remaining time percentage with a maximum 1-second update delay
- **SC-010**: Session skip immediately triggers completion flow, with total time from skip tap to break screen under 1.2 seconds
- **SC-011**: All custom visual elements (circular timer, buttons, checkmark) render clearly without pixelation or visual artifacts at standard mobile screen densities (2x, 3x)
