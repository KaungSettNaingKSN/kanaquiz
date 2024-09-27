import 'package:flutter/material.dart';
import 'package:kanaquiz/home_screen.dart';
import 'package:provider/provider.dart';
import 'kana_quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<KanaQuizProvider>(context);

    final currentQuestion = quizProvider.isQuizComplete
        ? {}
        : quizProvider.questions[quizProvider.currentQuestionIndex];

    return Scaffold(
      appBar: quizProvider.isQuizComplete
          ? AppBar()
          : AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(quizProvider.timeRemaining * quizProvider.timerDuration).ceil().toString().padLeft(2, '0')}s',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text('Kana Quiz App'),
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    onPressed: () {
                      _showPauseDialog(context, quizProvider);
                      setState(() {
                        _isPaused = !_isPaused;
                        _isPaused
                            ? quizProvider.pauseTimer()
                            : quizProvider.resumeTimer();
                      });
                    },
                  ),
                ],
              ),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!quizProvider.isQuizComplete)
              // LinearProgressIndicator(
              //   value: quizProvider.timeRemaining,
              //   backgroundColor: Colors.grey[300],
              //   color: Colors.red,
              //   minHeight: 10,
              // ),
              const SizedBox(height: 20),
            Center(
              child: Text(
                quizProvider.isQuizComplete
                    ? "Quiz Completed!"
                    : currentQuestion['question'] as String,
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            quizProvider.isQuizComplete
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Your Score: ${quizProvider.score} / ${quizProvider.questions.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 0.9 / 2.3,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Home',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 0.9 / 2.3,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  quizProvider.resetQuiz();
                                },
                                child: const Text(
                                  'Restart Quiz',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                      children: !quizProvider.isQuizComplete
                          ? (currentQuestion['answers']
                                      as List<Map<String, Object>?>?)
                                  ?.map((answer) {
                                return AspectRatio(
                                  aspectRatio: 1,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!quizProvider.isQuizComplete) {
                                        quizProvider.answerQuestion(
                                            answer?['score'] as int? ?? 0);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            offset: const Offset(0, 4),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          answer?['text'] as String? ??
                                              "No answer text.",
                                          style: const TextStyle(fontSize: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList() ??
                              []
                          : [],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context, KanaQuizProvider quizProvider) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Kana Quiz',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              quizProvider.resetQuiz();
                              Navigator.of(context).pop();
                              setState(() {
                                _isPaused = !_isPaused;
                                _isPaused
                                    ? quizProvider.pauseTimer()
                                    : quizProvider.resumeTimer();
                              });
                            },
                            child: const Text(
                              'Restart Quiz',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _isPaused = !_isPaused;
                                _isPaused
                                    ? quizProvider.pauseTimer()
                                    : quizProvider.resumeTimer();
                              });
                            },
                            child: const Text(
                              'Resume',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
