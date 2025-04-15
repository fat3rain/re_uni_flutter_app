import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:re_uni/screens/results_screen.dart';
import 'package:re_uni/widgets/custom_text_field.dart';

class AttestationScreen extends StatefulWidget {
  final bool isAdmin;
  final String name;
  final String testId;
  const AttestationScreen(
      {super.key,
      required this.name,
      required this.testId,
      required this.isAdmin});

  @override
  State<AttestationScreen> createState() => _AttestationScreenState();
}

class _AttestationScreenState extends State<AttestationScreen> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  CollectionReference get _questions => FirebaseFirestore.instance
      .collection('tests')
      .doc(widget.testId)
      .collection('questions');
  CollectionReference get _results => FirebaseFirestore.instance
      .collection('tests')
      .doc(widget.testId)
      .collection('results');
  Map<int, String> ans = {};

  _deleteQuestion(String questionId) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              backgroundColor: const Color.fromARGB(187, 0, 0, 0),
              actionsAlignment: MainAxisAlignment.center,
              title: Center(
                child: Text(
                  'Вы уверены?',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.20,
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'нет',
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.20,
                      ),
                    )),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                    onPressed: () async {
                      _questions.doc(questionId).delete();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'да',
                      style: GoogleFonts.montserrat(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.20,
                      ),
                    )),
              ],
            ));
  }

  Future<void> checkingRes(
      // String questionId
      ) async {
    int score = 0;
    QuerySnapshot querySnapshot = await _questions.get();
    List<Map<String, dynamic>> questions = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    ans.forEach((questionIndex, userAnswer) {
      if (questionIndex - 1 < questions.length) {
        String correctAnswer = questions[questionIndex - 1]['correct_answer'];

        if (userAnswer == correctAnswer) {
          score++;
        }
      }
    });

    //  if (_titleTest.text.isNotEmpty) {
    //                             await _Test.add({
    //                               'name': _titleTest.text.trim(),
    //                               'titleSubject': _titleSubject.text.trim(),
    //                               // 'time': Timestamp.now(),
    //                             });
    //                             //
    //                             _titleTest.clear();

    //                             _titleSubject.clear();
    //                           }
    await _results.add({
      'userEmail': user?.email ?? '',
      'result': (score / questions.length * 100).toStringAsFixed(2)
    });
    debugPrint('Ваш результат: $score из ${questions.length}');
    return showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Center(
                child: Text(
                  score / questions.length < 0.5
                      ? 'увы, но...'
                      : 'поздравляем!',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.20,
                  ),
                ),
              ),
              content: SizedBox(
                height: 100,
                width: 100,
                child: Column(
                  children: [
                    Text(
                      'ваш результат: $score из ${questions.length}',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.20,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'закрыть',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.20,
                          ),
                        ))
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox.expand(
        child: Image.asset(
          'assets/background.png',
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
          actions: [
            if (widget.isAdmin)
              IconButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsScreen(
                            testId: widget.testId,
                          ),
                        ),
                      ),
                  icon: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Colors.white,
                    size: 35,
                  ))
          ],
          centerTitle: true,
          title: Text(
            widget.name,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.20,
            ),
          ),
        ),
        body: Column(
          children: [
            if (widget.isAdmin)
              TextButton(
                onPressed: () async {
                  return showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (BuildContext context) {
                      List<TextEditingController> controllers = [];
                      return StatefulBuilder(
                        builder: (context, setStateDialog) {
                          return AlertDialog(
                            backgroundColor: const Color.fromARGB(217, 0, 0, 0),
                            title: Center(
                                child: Text(
                              'Новый вопрос',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.20,
                              ),
                            )),
                            content: SizedBox(
                              height: 400,
                              width: 400,
                              child: Column(
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Закрыть',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.20,
                                        ),
                                      )),
                                  CustomTextField(
                                    controller: questionController,
                                    name: 'вопрос',
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  CustomTextField(
                                    controller: answerController,
                                    name: 'верный ответ',
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: controllers.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: CustomTextField(
                                            controller: controllers[index],
                                            name: 'ответ ${index + 2}',
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setStateDialog(() {
                                            if (controllers.isNotEmpty) {
                                              controllers.removeLast();
                                            }
                                          });
                                        },
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setStateDialog(() {
                                            controllers
                                                .add(TextEditingController());
                                          });
                                        },
                                        child: const Icon(
                                          Icons.add_outlined,
                                          color: Colors.green,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          {
                                            await _questions.add({
                                              // очень умно
                                              'question': questionController
                                                  .text
                                                  .trim(),
                                              'correct_answer':
                                                  answerController.text.trim(),
                                              'all_answers': [
                                                answerController.text.trim(),
                                                ...controllers
                                                    .map((c) => c.text.trim())
                                              ],
                                            });
                                            questionController.clear();
                                            answerController.clear();
                                            controllers.clear();
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text(
                                          'создать',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: const Text(
                  'Нажмите для создания вопроса',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2),
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _questions.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final questions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      // List<String> selectedItems = [];
                      // OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      final question = questions[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              // ignore: prefer_interpolation_to_compose_strings
                              ('${index + 1}. ' + question['question']),
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.20,
                              ),
                            ),
                            trailing: !widget.isAdmin
                                ? null
                                : IconButton(
                                    onPressed: () =>
                                        _deleteQuestion(question.id),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )),
                            ////_deleteQuestion

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...(() {
                                  List<dynamic> shuffledAnswers =
                                      List.from(question['all_answers']);
                                  shuffledAnswers.shuffle();
                                  return shuffledAnswers
                                      .asMap()
                                      .entries
                                      .map<Widget>(
                                        (entry) => Text(
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            '${entry.key + 1}) ${entry.value}'),
                                      )
                                      .toList();
                                })(),
                                if (widget.isAdmin)
                                  Text(
                                    'Правильный ответ: ${question['correct_answer']}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.20,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!widget.isAdmin)
                            DropdownMenu<String>(
                              label: Text(
                                'Ответ:',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.20,
                                ),
                              ),
                              menuStyle: MenuStyle(
                                  side:
                                      const WidgetStatePropertyAll<BorderSide>(
                                          BorderSide(
                                              width: 2, color: Colors.white)),
                                  shadowColor: const WidgetStatePropertyAll(
                                      Color.fromARGB(255, 0, 0, 0)),
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Color.fromARGB(228, 0, 0, 0)),
                                  shape: WidgetStatePropertyAll<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)))),
                              onSelected: (value) {
                                setState(() {
                                  if (value != null) {
                                    String fullAnswer =
                                        question['all_answers'].firstWhere(
                                      (answer) => value.startsWith(
                                          answer.length > 35
                                              ? answer.substring(0, 35)
                                              : answer),
                                      orElse: () => value,
                                    );

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: Center(
                                          child: Text(
                                            'Вы выбираете: $fullAnswer?',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.20,
                                            ),
                                          ),
                                        ),
                                        content: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  ans[index + 1] = fullAnswer;
                                                  debugPrint(ans.toString());
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Да'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  ans.remove(index + 1);
                                                  debugPrint(ans.toString());
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Удалить'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Закрыть'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.20,
                              ),
                              inputDecorationTheme: InputDecorationTheme(
                                hintStyle: const TextStyle(color: Colors.white),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.white)),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              dropdownMenuEntries: (() {
                                List<String> shuffledAnswers = List.from(
                                        question['all_answers'])
                                    .map((answer) => answer.toString().length >
                                            35
                                        ? '${answer.toString().substring(0, 35)}...'
                                        : answer.toString())
                                    .toList();
                                shuffledAnswers.shuffle(); // мешалка
                                return shuffledAnswers
                                    .map((answer) => DropdownMenuEntry<String>(
                                          style: MenuItemButton.styleFrom(
                                              foregroundColor: Colors.white),
                                          // const ButtonStyle(
                                          //     textStyle: WidgetStatePropertyAll<
                                          //             TextStyle>(
                                          //         TextStyle(
                                          //             color: Colors.white))),
                                          value: answer,
                                          label: answer,
                                        ))
                                    .toList();
                              })(),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            if (!widget.isAdmin)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                actionsAlignment: MainAxisAlignment.center,
                                title: Text(
                                  'Последний шанс',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.20,
                                    color: Colors.black,
                                  ),
                                ),
                                content: Text(
                                  textAlign: TextAlign.center,
                                  'Вы собираетесь отправить результаты на проверку?',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.20,
                                    color: Colors.black,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'нет',
                                        style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.20,
                                            color: Colors.red),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  TextButton(
                                      onPressed: checkingRes,
                                      child: Text(
                                        'да',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.20,
                                          color: Colors.green,
                                        ),
                                      )),
                                ],
                              )),
                      icon: const Icon(Icons.check),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    IconButton(
                      color: Colors.white,
                      onPressed: () {
                        final snackBar = SnackBar(
                            backgroundColor: Colors.transparent,
                            content: Center(
                              child: Text(
                                'ответы: ${ans.toString()}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.20,
                                  color: Colors.white,
                                ),
                              ),
                            ));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      icon: const Icon(Icons.search),
                    ),
                    // const Padding(
                    //   padding: EdgeInsets.all(90),
                    // ),
                    const SizedBox(
                      width: 30,
                    ),
                    IconButton(
                        color: Colors.white,
                        onPressed: () {
                          ans.clear();
                          final snackBar = SnackBar(
                              backgroundColor: Colors.transparent,
                              content: Center(
                                child: Text(
                                  'ответы удалены!',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.20,
                                    color: Colors.white,
                                  ),
                                ),
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        icon: const Icon(Icons.delete)),
                  ],
                ),
              )
          ],
        ),
      ),
    ]);
  }
}
