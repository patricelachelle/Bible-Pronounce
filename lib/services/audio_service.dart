import 'package:just_audio/just_audio.dart';

/// Tiny wrapper used for local file playback (for user recordings).
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentSource;

  Future<void> toggleLocalFile(String filePath) async {
    final isSameTrack = _currentSource == filePath;
    final isPlaying = _player.playing;

    if (isSameTrack && isPlaying) {
      await _player.pause();
      return;
    }

    if (!isSameTrack) {
      _currentSource = filePath;
      await _player.setFilePath(filePath);
    }

    await _player.play();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
