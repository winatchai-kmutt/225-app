import 'package:flutter/material.dart';
import 'app.dart';
import 'features/common/utils/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preload audio files in background (non-blocking)
  // Audio will be ready within ~100ms, app starts immediately
  AudioService.instance.preload();
  
  runApp(const App());
}
