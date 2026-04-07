import 'dart:math';

import 'package:flutter/material.dart';

import '../models/bible_word.dart';
import '../services/tts_service.dart';
import '../services/word_repository.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final WordRepository _repository = const WordRepository();
  final Random _random = Random();

  late List<BibleWord> _words;
  int _index = 0;
  bool _quizEnabled = true;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _words = List<BibleWord>.from(_repository.getAllWords())..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final word = _words[_index];
    final options = _quizOptions(word);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Practice Mode', style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  const Icon(Icons.quiz_outlined),
                  Switch(
                    value: _quizEnabled,
                    onChanged: (value) => setState(() {
                      _quizEnabled = value;
                      _selectedAnswer = null;
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Word ${_index + 1} of ${_words.length}'),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  key: ValueKey(word.word),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(word.word, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        Text(word.category.label),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => TtsService.instance.playPronunciation(
                            phoneticText: word.phonetic,
                          ),
                          icon: const Icon(Icons.volume_up),
                          label: const Text('Play pronunciation'),
                        ),
                        if (_quizEnabled) ...[
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Which pronunciation is correct?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...options.map(
                            (option) => RadioListTile<String>(
                              value: option,
                              groupValue: _selectedAnswer,
                              title: Text(option),
                              onChanged: (value) => setState(() => _selectedAnswer = value),
                            ),
                          ),
                          if (_selectedAnswer != null)
                            Text(
                              _selectedAnswer == word.phonetic ? 'Correct! Great job.' : 'Good try! Listen and repeat again.',
                              style: TextStyle(
                                color: _selectedAnswer == word.phonetic
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1),
              duration: const Duration(milliseconds: 120),
              builder: (context, value, child) => Transform.scale(scale: value, child: child),
              child: FilledButton.icon(
                onPressed: () => setState(() {
                  _index = (_index + 1) % _words.length;
                  _selectedAnswer = null;
                }),
                icon: const Icon(Icons.navigate_next),
                label: const Text('Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _quizOptions(BibleWord word) {
    if (!_quizEnabled) return const <String>[];
    final wrong = <String>{};
    while (wrong.length < 2) {
      final randomWord = _words[_random.nextInt(_words.length)];
      if (randomWord.word != word.word) {
        wrong.add(randomWord.phonetic);
      }
    }
    final options = <String>[word.phonetic, ...wrong]..shuffle();
    return options;
  }
}
