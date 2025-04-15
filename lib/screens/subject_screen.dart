import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_uni/screens/paragraph_screen.dart';
import 'package:re_uni/widgets/custom_text_field.dart';

class SubjectsScreen extends StatefulWidget {
  final bool isAdmin; // Новый параметр для роли пользователя

  const SubjectsScreen({super.key, required this.isAdmin});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final CollectionReference _subjects =
      FirebaseFirestore.instance.collection('subjects');

  // Метод для добавления предмета
  void _addSubject() async {
    if (_nameController.text.isNotEmpty) {
      await _subjects.add({
        'name': _nameController.text.trim(),
      });
      _nameController.clear();
    }
  }

  // Метод для удаления предмета
  void _deleteSubject(String subjectId) async {
    await _subjects.doc(subjectId).delete();
  }

  // Переход к экрану лекций (подколлекции paragraphs)
  void _openParagraphs(String subjectId, String subjectName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParagraphsScreen(
          subjectId: subjectId,
          subjectName: subjectName,
          isAdmin: widget.isAdmin, // Передаем роль пользователя
        ),
      ),
    );
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
          title: Row(
            children: [
              const SizedBox(
                width: 55,
              ),
              Text(
                'Предметы',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.20,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            if (widget.isAdmin) // Кнопка "Добавить" только для администратора
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                          controller: _nameController,
                          name: 'Название предмета'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: const ButtonStyle(
                        overlayColor:
                            WidgetStatePropertyAll<Color>(Colors.black),
                        shadowColor:
                            WidgetStatePropertyAll<Color>(Colors.black),
                        backgroundColor:
                            WidgetStatePropertyAll<Color>(Colors.transparent),
                      ),
                      onPressed: _addSubject,
                      child: Text(
                        'Добавить',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _subjects.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final subjects = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return ListTile(
                        title: Text(
                          subject['name'] ?? 'Без названия',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.20,
                          ),
                        ),
                        trailing: widget
                                .isAdmin // Кнопка "Удалить" только для администратора
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteSubject(subject.id),
                              )
                            : null,
                        onTap: () =>
                            _openParagraphs(subject.id, subject['name'] ?? ''),
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
