import 'dart:async';
import 'package:flutter/widgets.dart';
import '../features/storage/domain/entities/timer_session.dart';
import '../features/storage/domain/repos/timer_persistence_repo.dart';
import '../features/storage/domain/repos/notification_permission_repo.dart';
import '../features/storage/domain/entities/notification_permission.dart';
import 'notification_service.dart';
import 'alarm_notification_service.dart';

/// Service for managing background timer execution and lifecycle.
/// 
/// Coordinates timer state with notification scheduling and app lifecycle events.
/// Uses timestamp-based calculation to maintain accuracy when app is backgrounded.
class BackgroundTimerService with WidgetsBindingObserver {
  final TimerPersistenceRepo _persistenceRepo;
  final NotificationService _notificationService;
  final NotificationPermissionRepo? _permissionRepo;
  
  Timer? _uiUpdateTimer;
  TimerSession? _currentSession;
  
  // Callbacks for state updates
  void Function(TimerSession?)? onTimerStateChanged;

  BackgroundTimerService({
    required TimerPersistenceRepo persistenceRepo,
    required NotificationService notificationService,
    NotificationPermissionRepo? permissionRepo,
  })  : _persistenceRepo = persistenceRepo,
        _notificationService = notificationService,
        _permissionRepo = permissionRepo;

  /// Initialize the service and register app lifecycle observers.
  Future<void> initialize() async {
    // Register as lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Check for active session on startup
    _currentSession = await _persistenceRepo.loadTimerSession();
    
    if (_currentSession != null) {
      // If there's an active session, check if it's still valid
      final remaining = calculateRemainingTime(_currentSession!);
      
      if (remaining.isNegative) {
        // Timer has completed
        _currentSession = _currentSession!.copyWith(
          currentState: TimerState.completed,
          completionTimestamp: DateTime.now(),
        );
        await _persistenceRepo.clearTimerSession();
      } else {
        // Timer is still running, reschedule notification with remaining duration
        final remainingDuration = calculateRemainingTime(_currentSession!);
        await _scheduleNotificationIfPermitted(remainingDuration);
      }
      
      // Notify listeners
      onTimerStateChanged?.call(_currentSession);
    }
  }

  /// Start a new timer session.
  Future<TimerSession> startTimer({
    required Duration duration,
    required SessionType sessionType,
  }) async {
    // Cancel any existing timer
    await cancelTimer();
    
    // Create new session
    final now = DateTime.now();
    final session = TimerSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionType: sessionType,
      totalDuration: duration,
      startTimestamp: now,
      currentState: TimerState.running,
    );
    
    // Persist session
    await _persistenceRepo.saveTimerSession(session);
    _currentSession = session;
    
    // Schedule notification only if permission is granted
    await _scheduleNotificationIfPermitted(duration);
    
    // Start UI update timer (updates every second for smooth countdown)
    _startUiUpdateTimer();
    
    // Notify listeners
    onTimerStateChanged?.call(session);
    
    return session;
  }

  /// Schedule notification if permission is granted, skip if denied
  Future<void> _scheduleNotificationIfPermitted(Duration duration) async {
    try {
      // Check permission if repo is available
      if (_permissionRepo != null) {
        final status = await _permissionRepo.checkPermissionStatus();
        
        if (status == PermissionStatus.granted) {
          // Use AlarmManager for Android, flutter_local_notifications for iOS
          try {
            await AlarmNotificationService.scheduleNotification(delay: duration);
          } catch (e) {
            // Fallback to regular notification service (iOS or if AlarmManager fails)
            await _notificationService.scheduleTimerCompletionNotification(
              duration: duration,
            );
          }
        }
        // If permission denied, skip notification - timer still works normally
      } else {
        // No permission repo available, try to schedule anyway (fallback)
        try {
          await AlarmNotificationService.scheduleNotification(delay: duration);
        } catch (e) {
          await _notificationService.scheduleTimerCompletionNotification(
            duration: duration,
          );
        }
      }
    } catch (e) {
      // If notification scheduling fails, log but don't break timer functionality
      debugPrint('BackgroundTimerService: Failed to schedule notification - $e');
    }
  }

  /// Get the current timer session state.
  Future<TimerSession?> getCurrentSession() async {
    _currentSession ??= await _persistenceRepo.loadTimerSession();
    
    if (_currentSession == null) {
      return null;
    }
    
    // Calculate current state based on timestamps
    final remaining = calculateRemainingTime(_currentSession!);
    
    if (remaining.isNegative && _currentSession!.currentState == TimerState.running) {
      // Timer has completed
      _currentSession = _currentSession!.copyWith(
        currentState: TimerState.completed,
        completionTimestamp: DateTime.now(),
      );
      await _persistenceRepo.clearTimerSession();
      _stopUiUpdateTimer();
    }
    
    return _currentSession;
  }

  /// Cancel the currently active timer.
  Future<void> cancelTimer() async {
    if (_currentSession != null) {
      // Cancel BOTH notification systems
      
      // 1. Cancel Android AlarmManager (if available)
      try {
        await AlarmNotificationService.cancel();
      } catch (e) {
        // iOS or AlarmManager not available - skip silently
      }
      
      // 2. Cancel flutter_local_notifications (both Android & iOS)
      await _notificationService.cancelAllNotifications();
      
      // 3. Update state
      _currentSession = _currentSession!.copyWith(
        currentState: TimerState.cancelled,
      );
      
      // 4. Clear persistence
      await _persistenceRepo.clearTimerSession();
      
      // 5. Stop UI updates
      _stopUiUpdateTimer();
      
      // 6. Notify listeners
      onTimerStateChanged?.call(null);
      _currentSession = null;
    }
  }

  /// Calculate remaining time for a timer session.
  Duration calculateRemainingTime(TimerSession session) {
    final now = DateTime.now();
    final elapsed = now.difference(session.startTimestamp);
    final remaining = session.totalDuration - elapsed;
    return remaining;
  }

  /// Handle app lifecycle state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onAppLifecycleStateChanged(state);
  }

  /// Handle lifecycle state changes.
  void onAppLifecycleStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App returned from background - recalculate timer state
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        // App going to background - ensure state is persisted
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // No specific action needed
        break;
    }
  }

  /// Handle app resumed from background
  Future<void> _handleAppResumed() async {
    final session = await getCurrentSession();
    
    if (session != null) {
      // Restart UI update timer
      _startUiUpdateTimer();
      
      // Notify listeners to update UI
      onTimerStateChanged?.call(session);
    }
  }

  /// Handle app going to background
  Future<void> _handleAppPaused() async {
    // Stop UI update timer to save battery
    _stopUiUpdateTimer();
    
    // Ensure current state is persisted
    if (_currentSession != null && 
        _currentSession!.currentState == TimerState.running) {
      await _persistenceRepo.saveTimerSession(_currentSession!);
    }
  }

  /// Start periodic UI update timer
  void _startUiUpdateTimer() {
    _stopUiUpdateTimer();
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      onTimerStateChanged?.call(_currentSession);
    });
  }

  /// Stop UI update timer
  void _stopUiUpdateTimer() {
    _uiUpdateTimer?.cancel();
    _uiUpdateTimer = null;
  }

  /// Dispose resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopUiUpdateTimer();
  }
}
