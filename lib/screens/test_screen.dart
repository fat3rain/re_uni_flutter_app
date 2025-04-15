import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_uni/screens/attestation_screen.dart';
import 'package:re_uni/widgets/custom_text_field.dart';

// ignore: must_be_immutable
class TestScreen extends StatefulWidget {
  bool isAdmin;

  TestScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _titleTest = TextEditingController();
  final _titleSubject = TextEditingController();
  CollectionReference get _Test =>
      FirebaseFirestore.instance.collection('tests');
  _deleteTest(String testId) async {
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.20,
                          color: Colors.red),
                    )),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                    onPressed: () async {
                      await _Test.doc(testId).delete();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'да',
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.20,
                          color: Colors.green),
                    )),
              ],
            ));
  }
  // void _deleteSubject(String subjectId) async {
  //   await _subjects.doc(subjectId).delete();
  // // }

  _addTest() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              backgroundColor: const Color.fromARGB(187, 0, 0, 0),
              title: Center(
                  child: Text(
                'Новый тест',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.20,
                ),
              )),
              content: SizedBox(
                height: 200,
                width: 200,
                child: Column(
                  children: [
                    CustomTextField(controller: _titleTest, name: 'Название'),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(controller: _titleSubject, name: 'Предмет'),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      //     void _addSubject() async {
                      //   if (_nameController.text.isNotEmpty) {
                      //     await _subjects.add({
                      //       'name': _nameController.text.trim(),
                      //     });
                      //     _nameController.clear();
                      //   }
                      // }
                      children: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                            )),
                        const SizedBox(
                          width: 130,
                        ),
                        IconButton(
                            onPressed: () async {
                              if (_titleTest.text.isNotEmpty) {
                                await _Test.add({
                                  'name': _titleTest.text.trim(),
                                  'titleSubject': _titleSubject.text.trim(),
                                  // 'time': Timestamp.now(),
                                });
                                //
                                _titleTest.clear();

                                _titleSubject.clear();
                              }
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.green,
                            )),
                      ],
                    )
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
          title: Text(
            (widget.isAdmin) ? 'Добавить тесты' : 'Ваши тесты:',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.20,
            ),
          ),
          centerTitle: true,
          actions: [
            if (widget.isAdmin)
              IconButton(
                icon: const Icon(
                  size: 35,
                  Icons.add_outlined,
                  color: Colors.white,
                ),
                onPressed: _addTest,
              )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _Test.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tests = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: tests.length,
                    itemBuilder: (context, index) {
                      final test = tests[index];
                      return ListTile(
                        trailing: !widget.isAdmin
                            ? null
                            : IconButton(
                                onPressed: () => _deleteTest(test.id),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttestationScreen(
                              testId: test.id,
                              name: test['name'],
                              isAdmin: widget.isAdmin,
                            ),
                          ),
                        ),
                        title: Text(
                          test['name'] ?? 'Без названия',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.20,
                          ),
                        ),
                        subtitle: Text(
                          test['titleSubject'] ?? 'Без названия',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.20,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
