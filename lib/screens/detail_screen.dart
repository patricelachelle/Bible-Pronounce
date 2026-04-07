import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/bible_word.dart';
import '../services/audio_service.dart';
import '../services/favorites_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.word});

  final BibleWord word;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = false;

  Future<void> _togglePlayPause() async {
    setState(() => _isLoading = true);
    try {
      await AudioService.instance.togglePlayPause(widget.word.audioUrl);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio failed to load. Check URL/source.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.instance.toggleFavorite(widget.word.word);
    if (mounted) {
      setState(() {});
    }
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
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.word.word,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              widget.word.phonetic,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<PlayerState>(
              stream: AudioService.instance.stateStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data?.playing ?? false;

                return FilledButton.icon(
                  onPressed: _isLoading ? null : _togglePlayPause,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Pause pronunciation' : 'Play pronunciation'),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Audio URL: ${widget.word.audioUrl}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
