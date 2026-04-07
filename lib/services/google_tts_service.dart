import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GoogleTtsService {
  GoogleTtsService._();

  static final GoogleTtsService instance = GoogleTtsService._();

  static const String _apiKey = String.fromEnvironment('GOOGLE_TTS_API_KEY');
  final Map<String, String> _cache = <String, String>{};

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> synthesizeToFile(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Text must not be empty.');
    }

    final cachedPath = _cache[trimmed];
    if (cachedPath != null && File(cachedPath).existsSync()) {
      return cachedPath;
    }

    if (!isConfigured) {
      throw StateError(
        'Google Cloud TTS is not configured. Pass --dart-define=GOOGLE_TTS_API_KEY=<your-key>.',
      );
    }

    final response = await http.post(
      Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'input': <String, String>{'text': trimmed},
        'voice': <String, String>{
          'languageCode': 'en-US',
          'name': 'en-US-Neural2-D',
        },
        'audioConfig': <String, dynamic>{
          'audioEncoding': 'MP3',
          'speakingRate': 0.92,
          'pitch': -1.5,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException('Google TTS request failed (${response.statusCode}): ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final content = payload['audioContent'] as String?;
    if (content == null || content.isEmpty) {
      throw const FormatException('Google TTS returned empty audio content.');
    }

    final dir = await getTemporaryDirectory();
    final safeName = trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final file = File('${dir.path}/tts_$safeName.mp3');
    await file.writeAsBytes(base64Decode(content), flush: true);

    _cache[trimmed] = file.path;
    return file.path;
  }
}
