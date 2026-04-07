import 'package:just_audio/just_audio.dart';

/// A tiny wrapper to keep audio concerns out of UI widgets.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;

  PlayerState get state => _player.playerState;
  Stream<PlayerState> get stateStream => _player.playerStateStream;

  Future<void> togglePlayPause(String url) async {
    final isSameTrack = _currentUrl == url;
    final isPlaying = _player.playing;

    if (isSameTrack && isPlaying) {
      await _player.pause();
      return;
    }

    if (!isSameTrack) {
      _currentUrl = url;
      await _player.setUrl(url);
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
