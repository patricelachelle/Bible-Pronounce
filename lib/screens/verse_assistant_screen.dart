import 'package:flutter/material.dart';

import '../models/verse_analysis.dart';
import '../services/recent_verses_service.dart';
import '../services/tts_service.dart';
import '../services/verse_parser_service.dart';

class VerseAssistantScreen extends StatefulWidget {
  const VerseAssistantScreen({super.key});

  @override
  State<VerseAssistantScreen> createState() => _VerseAssistantScreenState();
}

class _VerseAssistantScreenState extends State<VerseAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final VerseParserService _parser = VerseParserService();

  VerseAnalysis _analysis = const VerseAnalysis(
    originalVerse: '',
    segments: <VerseSegment>[],
    focusWords: <VerseFocusWord>[],
  );

  bool _isAnalyzing = false;

  Future<void> _analyzeVerse() async {
    FocusScope.of(context).unfocus();
    final verse = _controller.text.trim();

    if (verse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste or type a verse first.')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final result = _parser.analyze(verse);
    await RecentVersesService.instance.saveVerse(verse);

    if (!mounted) return;
    setState(() {
      _analysis = result;
      _isAnalyzing = false;
    });
  }

  void _loadRecentVerse(String verse) {
    _controller.text = verse;
    _controller.selection = TextSelection.collapsed(offset: verse.length);
    _analyzeVerse();
  }

  Future<void> _showWordSheet(VerseFocusWord focusWord) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _WordPronunciationSheet(focusWord: focusWord),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verse Assistant', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Paste a verse, tap Analyze Verse, then tap highlighted words to practice pronunciation.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 7,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Verse input',
              alignLabelWithHint: true,
              hintText: 'Example: In those days came John the Baptist...',
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeVerse,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_fix_high),
              label: const Text('Analyze Verse'),
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: RecentVersesService.instance.changeNotifier,
            builder: (context, _, __) {
              final recent = RecentVersesService.instance.recentVerses;
              if (recent.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent verses', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recent
                        .map(
                          (verse) => ActionChip(
                            avatar: const Icon(Icons.history, size: 18),
                            label: SizedBox(
                              width: 170,
                              child: Text(
                                verse,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onPressed: () => _loadRecentVerse(verse),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _analysis.originalVerse.isEmpty
                ? _emptyState(context)
                : _analysisCard(context),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Card(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'Your analyzed verse will appear here with highlighted difficult words.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _analysisCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey('analysis'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Reading view', style: theme.textTheme.titleMedium),
                const Spacer(),
                Chip(label: Text('${_analysis.focusWords.length} focus words')),
              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: theme.textTheme.titleMedium?.copyWith(height: 1.6),
                children: _analysis.segments.map((segment) {
                  if (!segment.isHighlighted) {
                    return TextSpan(text: segment.raw);
                  }

                  final focusWord = segment.focusWord!;
                  final isWordOfVerse =
                      _analysis.wordOfTheVerse?.normalized == focusWord.normalized;

                  return WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: _HighlightWord(
                        word: segment.raw,
                        isWordOfVerse: isWordOfVerse,
                        onTap: () => _showWordSheet(focusWord),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_analysis.wordOfTheVerse != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Word of the Verse: ${_analysis.wordOfTheVerse!.surface}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightWord extends StatefulWidget {
  const _HighlightWord({
    required this.word,
    required this.onTap,
    required this.isWordOfVerse,
  });

  final String word;
  final VoidCallback onTap;
  final bool isWordOfVerse;

  @override
  State<_HighlightWord> createState() => _HighlightWordState();
}

class _HighlightWordState extends State<_HighlightWord> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.96 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: widget.isWordOfVerse
                ? theme.colorScheme.tertiaryContainer
                : theme.colorScheme.secondaryContainer,
          ),
          child: Text(
            widget.word,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _WordPronunciationSheet extends StatefulWidget {
  const _WordPronunciationSheet({required this.focusWord});

  final VerseFocusWord focusWord;

  @override
  State<_WordPronunciationSheet> createState() => _WordPronunciationSheetState();
}

class _WordPronunciationSheetState extends State<_WordPronunciationSheet> {
  bool _isPlayingNormal = false;
  bool _isPlayingSlow = false;

  Future<void> _play({required bool slow}) async {
    setState(() {
      _isPlayingNormal = !slow;
      _isPlayingSlow = slow;
    });

    try {
      await TtsService.instance.playPronunciation(
        phoneticText: widget.focusWord.phonetic,
        slowPlayback: slow,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play pronunciation: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isPlayingNormal = false;
        _isPlayingSlow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.focusWord.surface, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            widget.focusWord.phonetic,
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Chip(
            avatar: Icon(widget.focusWord.generated ? Icons.auto_awesome : Icons.dataset),
            label: Text(widget.focusWord.generated ? 'Generated pronunciation' : 'From Bible dataset'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: _isPlayingNormal || _isPlayingSlow
                    ? null
                    : () => _play(slow: false),
                icon: _isPlayingNormal
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: const Text('Play audio'),
              ),
              OutlinedButton.icon(
                onPressed: _isPlayingNormal || _isPlayingSlow ? null : () => _play(slow: true),
                icon: _isPlayingSlow
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.slow_motion_video),
                label: const Text('Slow playback'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
