import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// Service responsible for:
/// 1) Requesting Google Cloud Text-to-Speech audio
/// 2) Caching generated audio locally
/// 3) Playing audio through a shared player instance
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  static const String _apiKey = String.fromEnvironment('GOOGLE_TTS_API_KEY');

  final AudioPlayer _player = AudioPlayer();

  /// In-memory key -> file path cache for quick lookups while app is running.
  final Map<String, String> _filePathCache = <String, String>{};

  String? _currentSource;

  bool get isConfigured => _apiKey.isNotEmpty;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Generates (or reuses cached) audio for [phoneticText] and plays it.
  ///
  /// Set [slowPlayback] to true for learning mode.
  Future<void> playPronunciation({
    required String phoneticText,
    bool slowPlayback = false,
  }) async {
    final filePath = await _getOrCreateAudioFile(
      phoneticText: phoneticText,
      slowPlayback: slowPlayback,
    );

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

  Future<String> _getOrCreateAudioFile({
    required String phoneticText,
    required bool slowPlayback,
  }) async {
    final normalized = phoneticText.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('Phonetic text must not be empty.');
    }

    if (!isConfigured) {
      throw StateError(
        'Google Cloud TTS is not configured. Run with --dart-define=GOOGLE_TTS_API_KEY=<your-key>.',
      );
    }

    final cacheKey = '${slowPlayback ? 'slow' : 'normal'}::$normalized';
    final cachedPath = _filePathCache[cacheKey];
    if (cachedPath != null && File(cachedPath).existsSync()) {
      return cachedPath;
    }

    final directory = await getApplicationSupportDirectory();
    final safeName = normalized.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final fileName = 'tts_${slowPlayback ? 'slow' : 'normal'}_$safeName.mp3';
    final file = File('${directory.path}/$fileName');

    // Persistent disk cache: survives app restarts until app storage is cleared.
    if (file.existsSync()) {
      _filePathCache[cacheKey] = file.path;
      return file.path;
    }

    final audioBytes = await _fetchAudioBytes(
      phoneticText: normalized,
      slowPlayback: slowPlayback,
    );

    await file.writeAsBytes(audioBytes, flush: true);
    _filePathCache[cacheKey] = file.path;
    return file.path;
  }

  Future<List<int>> _fetchAudioBytes({
    required String phoneticText,
    required bool slowPlayback,
  }) async {
    final response = await http.post(
      Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'input': <String, String>{'text': phoneticText},
        'voice': <String, String>{
          'languageCode': 'en-US',
          'name': 'en-US-Neural2-D',
        },
        'audioConfig': <String, dynamic>{
          'audioEncoding': 'MP3',
          'speakingRate': slowPlayback ? 0.72 : 0.92,
          'pitch': -1.5,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException('Google TTS request failed (${response.statusCode}).');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final audioContent = payload['audioContent'] as String?;

    if (audioContent == null || audioContent.isEmpty) {
      throw const FormatException('Google TTS returned empty audio.');
    }

    return base64Decode(audioContent);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
