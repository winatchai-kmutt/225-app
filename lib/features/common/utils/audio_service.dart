import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Singleton service for managing audio playback
///
/// This service preloads audio files at app startup and provides
/// fire-and-forget playback methods with graceful error handling.
/// Designed for UI sound effects with <50ms latency.
///
/// **Usage:**
/// ```dart
/// // In main()
/// await AudioService.instance.preload();
///
/// // In widgets
/// AudioService.instance.playSound('audio/ui_click_neo.mp3');
/// ```
class AudioService {
  // Singleton pattern
  static final AudioService instance = AudioService._internal();
  factory AudioService() => instance;
  AudioService._internal();

  // Audio players pool for concurrent playback
  final Map<String, AudioPlayer> _players = {};
  
  // Preload status tracking
  bool _isPreloaded = false;
  
  /// Audio files to preload at startup
  /// Note: Paths are relative to assets/ directory
  static const List<String> _audioFiles = [
    'audio/ui_click_neo.mp3',     // Actual file: assets/audio/ui_click_neo.mp3
    'audio/success_chime.mp3',    // Actual file: assets/audio/success_chime.mp3
  ];

  /// Preload all audio files
  /// 
  /// Call this once during app initialization (in main() before runApp).
  /// Returns true if all files loaded successfully, false otherwise.
  /// Errors are logged but don't throw to avoid blocking app startup.
  Future<bool> preload() async {
    if (_isPreloaded) {
      debugPrint('AudioService: Already preloaded');
      return true;
    }

    try {
      debugPrint('AudioService: Preloading ${_audioFiles.length} audio files...');
      
      for (final file in _audioFiles) {
        final player = AudioPlayer();
        await player.setSource(AssetSource(file));
        await player.setReleaseMode(ReleaseMode.stop);
        _players[file] = player;
        debugPrint('AudioService: Preloaded $file');
      }
      
      _isPreloaded = true;
      debugPrint('AudioService: All audio files preloaded successfully');
      return true;
    } catch (e) {
      debugPrint('AudioService: Error preloading audio - $e');
      // Graceful degradation: app continues without audio
      return false;
    }
  }

  /// Play a sound effect
  /// 
  /// Fire-and-forget method for UI sounds. Does not await completion.
  /// If audio file wasn't preloaded or fails to play, fails silently.
  /// 
  /// [assetPath] - Path to audio file (e.g., 'audio/ui_click_neo.mp3')
  void playSound(String assetPath) {
    if (!_isPreloaded) {
      debugPrint('AudioService: Cannot play $assetPath - not preloaded');
      return;
    }

    final player = _players[assetPath];
    if (player == null) {
      debugPrint('AudioService: Audio file not found - $assetPath');
      return;
    }

    // Reset to beginning, then play
    player.seek(Duration.zero).then((_) {
      return player.resume();
    }).catchError((error) {
      debugPrint('AudioService: Error playing $assetPath - $error');
      // Silent failure - don't disrupt user experience
    });
  }

  /// Dispose all audio players
  /// 
  /// Call this when the app is being disposed (rare in Flutter apps).
  /// Usually not needed as AudioService lives for app lifetime.
  Future<void> dispose() async {
    try {
      debugPrint('AudioService: Disposing ${_players.length} audio players...');
      for (final player in _players.values) {
        await player.dispose();
      }
      _players.clear();
      _isPreloaded = false;
      debugPrint('AudioService: Disposed successfully');
    } catch (e) {
      debugPrint('AudioService: Error disposing - $e');
    }
  }
}
