import 'package:just_audio/just_audio.dart';

import 'google_tts_service.dart';

/// A tiny wrapper to keep audio concerns out of UI widgets.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentSource;

  PlayerState get state => _player.playerState;
  Stream<PlayerState> get stateStream => _player.playerStateStream;

  Future<void> togglePlayPause(String source) async {
    final isSameTrack = _currentSource == source;
    final isPlaying = _player.playing;

    if (isSameTrack && isPlaying) {
      await _player.pause();
      return;
    }

    if (!isSameTrack) {
      _currentSource = source;
      await _player.setUrl(source);
    }

    await _player.play();
  }

  Future<void> toggleTts(String text) async {
    final filePath = await GoogleTtsService.instance.synthesizeToFile(text);
    await toggleLocalFile(filePath);
  }

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

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
