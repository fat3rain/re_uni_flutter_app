import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_uni/widgets/custom_text_field.dart';
import 'lecture_screen.dart';
import 'graph_screen.dart';

class ParagraphsScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final bool isAdmin;

  const ParagraphsScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.isAdmin,
  });

  @override
  State<ParagraphsScreen> createState() => _ParagraphsScreenState();
}

class _ParagraphsScreenState extends State<ParagraphsScreen> {
  final TextEditingController _paragraphNameController =
      TextEditingController();

  CollectionReference get _paragraphs => FirebaseFirestore.instance
      .collection('subjects')
      .doc(widget.subjectId)
      .collection('paragraphs');

  // Добавление параграфа
  void _addParagraph() async {
    if (_paragraphNameController.text.isNotEmpty) {
      await _paragraphs.add({
        'name': _paragraphNameController.text.trim(), // Название параграфа
        'content': '', // Пустой текст лекции
      });
      _paragraphNameController.clear();
    }
  }

  // Удаление параграфа
  void _deleteParagraph(String paragraphId) async {
    await _paragraphs.doc(paragraphId).delete();
  }

  // Переход на экран лекции
  void _openLecture(String paragraphId, String paragraphName) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LectureScreen(
            paragraphId: paragraphId,
            subjectId: widget.subjectId,
            paragraphName: paragraphName,
            isAdmin: widget.isAdmin,
            reference: '',
          ),
        ));
  }

  // Переход на экран графов
  void _openGraphScreen(String paragraphId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GraphScreen(
          paragraphId: paragraphId,
          subjectId: widget.subjectId,
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
          title: Text(
            'Лекции предмета: ${widget.subjectName}',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.20,
            ),
          ),
          actions: [
            if (!widget.isAdmin) // Кнопка доступна только студентам
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.search),
                onPressed: () => _openGraphScreen(widget.subjectId),
              ),
          ],
        ),
        body: Column(
          children: [
            if (widget.isAdmin) // Поле добавления параграфа только для админа
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                          controller: _paragraphNameController,
                          name: 'Название параграфа'),
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
                      onPressed: _addParagraph,
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
                stream: _paragraphs.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final paragraphs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: paragraphs.length,
                    itemBuilder: (context, index) {
                      final paragraph = paragraphs[index];
                      return ListTile(
                        title: Text(
                          paragraph['name'] ?? 'Без названия',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.20,
                          ),
                        ),
                        trailing: widget.isAdmin
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteParagraph(paragraph.id),
                              )
                            : null,
                        onTap: () => _openLecture(
                          paragraph.id,
                          paragraph['name'] ?? 'Без названия',
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
