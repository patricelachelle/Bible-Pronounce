import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../models/bible_word.dart';
import '../services/audio_service.dart';
import '../services/favorites_service.dart';
import '../services/tts_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.word});

  final BibleWord word;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isPlayingNormal = false;
  bool _isPlayingSlow = false;
  bool _isRecording = false;
  String? _recordingPath;

  Future<void> _playTts({required bool slowPlayback}) async {
    setState(() {
      _isPlayingNormal = !slowPlayback;
      _isPlayingSlow = slowPlayback;
    });

    try {
      // We intentionally send phonetic text for better pronunciation accuracy.
      await TtsService.instance.playPronunciation(
        phoneticText: widget.word.phonetic,
        slowPlayback: slowPlayback,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play pronunciation: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingNormal = false;
          _isPlayingSlow = false;
        });
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _playRecording() async {
    final path = _recordingPath;
    if (path == null) return;

    try {
      await AudioService.instance.toggleLocalFile(path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recorded audio could not be played.')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.instance.toggleFavorite(widget.word.word);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = FavoritesService.instance.isFavorite(widget.word.word);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.word.word),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFavorite),
              ),
            ),
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.word.word, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                    widget.word.phonetic,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(label: Text(widget.word.category.label)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Pronunciation', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            StreamBuilder<PlayerState>(
              stream: TtsService.instance.playerStateStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data?.playing ?? false;

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _isPlayingNormal || _isPlayingSlow
                          ? null
                          : () => _playTts(slowPlayback: false),
                      icon: _isPlayingNormal
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      label: const Text('Play pronunciation'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isPlayingNormal || _isPlayingSlow
                          ? null
                          : () => _playTts(slowPlayback: true),
                      icon: _isPlayingSlow
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.slow_motion_video),
                      label: const Text('Play slowly'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _toggleRecording,
                      icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic),
                      label: Text(_isRecording ? 'Stop practice recording' : 'Record your pronunciation'),
                    ),
                    if (_recordingPath != null)
                      OutlinedButton.icon(
                        onPressed: _playRecording,
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Play your recording'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
