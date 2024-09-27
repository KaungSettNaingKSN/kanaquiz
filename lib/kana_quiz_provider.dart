import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'kana_data.dart';

enum QuizMode {
  hiraToRomaji,
  romajiTohira,
  kataToRomaji,
  romajiToKata,
}

class KanaQuizProvider with ChangeNotifier {
  int _currentQuestionIndex = 0;
  int _score = 0;
  final int _totalQuestions = 71;
  final Random _random = Random();
  Timer? _timer;
  double _timeRemaining = 1.0;
  static const int _timerDuration = 10;
  bool _isPaused = false;

  late List<Map<String, Object>> _questions;
  QuizMode _quizMode = QuizMode.hiraToRomaji;

  KanaQuizProvider() {
    _generateRandomQuestions();
  }

  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  double get timeRemaining => _timeRemaining;
  int get timerDuration => _timerDuration;
  List<Map<String, Object>> get questions => _questions;
  bool get isQuizComplete => _currentQuestionIndex >= _totalQuestions;

  void setQuizMode(QuizMode mode) {
    _quizMode = mode;
    resetQuiz();
  }

  void _generateRandomQuestions() {
    final kanaList = List<Map<String, String>>.from(allKana)..shuffle(_random);
    _questions = kanaList.take(_totalQuestions).map((kana) {
      final character = _quizMode == QuizMode.hiraToRomaji ||
              _quizMode == QuizMode.kataToRomaji
          ? kana[_quizMode == QuizMode.hiraToRomaji ? 'hira' : 'kata'] ?? ''
          : kana['romaji'] ?? '';
      final question = _quizMode == QuizMode.hiraToRomaji ||
              _quizMode == QuizMode.kataToRomaji
          ? kana['romaji'] ?? ''
          : kana[_quizMode == QuizMode.romajiTohira ? 'hira' : 'kata'] ?? '';

      final wrongAnswers = _generateWrongAnswers(character);
      final answers = [...wrongAnswers, character];
      answers.shuffle(_random);

      return {
        'question': question,
        'answers': answers.map((answer) {
          return {'text': answer, 'score': answer == character ? 1 : 0};
        }).toList(),
      };
    }).toList();
    _startTimer();
    notifyListeners();
  }

  List<String> _generateWrongAnswers(String correctAnswer) {
    final wrongAnswers = <String>{};
    while (wrongAnswers.length < 3) {
      final randomAnswer = allKana[_random.nextInt(allKana.length)][
              _quizMode == QuizMode.hiraToRomaji ||
                      _quizMode == QuizMode.kataToRomaji
                  ? (_quizMode == QuizMode.hiraToRomaji ? 'hira' : 'kata')
                  : 'romaji'] ??
          '';
      if (randomAnswer != correctAnswer) {
        wrongAnswers.add(randomAnswer);
      }
    }
    return wrongAnswers.toList();
  }

  void _startTimer() {
    _timeRemaining = 1.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPaused) {
        _timeRemaining -= 0.1 / _timerDuration;
        notifyListeners();

        if (_timeRemaining <= 0) {
          _timeRemaining = 0;
          timer.cancel();
          _moveToNextQuestion();
        }
      }
    });
  }

  void pauseTimer() {
    _isPaused = true;
    notifyListeners();
  }

  void resumeTimer() {
    _isPaused = false;
    notifyListeners();
  }

  void answerQuestion(int score) {
    _score += score;

    if (_currentQuestionIndex < _totalQuestions) {
      _moveToNextQuestion();
    } else {
      _timer?.cancel();
      notifyListeners();
    }
  }

  void _moveToNextQuestion() {
    _currentQuestionIndex++;
    _startTimer();
    notifyListeners();
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _generateRandomQuestions();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
