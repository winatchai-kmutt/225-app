import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/timer_session.dart';
import '../domain/repos/timer_persistence_repo.dart';

/// SharedPreferences implementation of TimerPersistenceRepo.
/// 
/// Persists timer session state to enable continuation across app lifecycle events.
class SharedPreferencesTimerRepo implements TimerPersistenceRepo {
  static const String _keyActiveSession = 'timer_active_session';

  final Future<SharedPreferences> _prefs;

  SharedPreferencesTimerRepo({
    Future<SharedPreferences>? prefs,
  }) : _prefs = prefs ?? SharedPreferences.getInstance();

  @override
  Future<void> saveTimerSession(TimerSession session) async {
    final prefs = await _prefs;
    final jsonString = jsonEncode(session.toJson());
    await prefs.setString(_keyActiveSession, jsonString);
  }

  @override
  Future<TimerSession?> loadTimerSession() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_keyActiveSession);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final session = TimerSession.fromJson(json);
      
      // Validate timestamp - check if session is stale
      // If the session was started before a reasonable time window, it's likely from
      // before a device reboot. We consider sessions older than 24 hours as stale.
      final now = DateTime.now();
      final sessionAge = now.difference(session.startTimestamp);
      
      // If session is older than 24 hours OR already completed/cancelled, return null
      if (sessionAge.inHours > 24 || 
          session.currentState == TimerState.completed ||
          session.currentState == TimerState.cancelled) {
        await clearTimerSession();
        return null;
      }
      
      return session;
    } catch (e) {
      // If JSON is invalid, return null (graceful degradation)
      await clearTimerSession();
      return null;
    }
  }

  @override
  Future<void> clearTimerSession() async {
    final prefs = await _prefs;
    await prefs.remove(_keyActiveSession);
  }

  @override
  Future<bool> hasActiveSession() async {
    final prefs = await _prefs;
    return prefs.containsKey(_keyActiveSession);
  }
}
