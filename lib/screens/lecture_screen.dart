import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';

class LectureScreen extends StatefulWidget {
  final String paragraphId;
  final String subjectId;
  final String paragraphName;
  final bool isAdmin; // Передаем статус пользователя
  final String? reference; // Reference для подсветки

  const LectureScreen({
    super.key,
    required this.paragraphId,
    required this.subjectId,
    required this.paragraphName,
    required this.isAdmin,
    this.reference,
  });

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  final TextEditingController _contentController = TextEditingController();
  Timestamp? _lastUpdated;

  DocumentReference<Map<String, dynamic>> get _lectureRef =>
      FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .collection('paragraphs')
          .doc(widget.paragraphId);

  // Получение данных параграфа
  Future<void> _fetchLectureData() async {
    try {
      final snapshot = await _lectureRef.get();
      if (snapshot.exists) {
        final data = snapshot.data();
        setState(() {
          _contentController.text = data?['content'] ?? '';
          _lastUpdated = data?['lastUpdated'] as Timestamp?;
        });
      }
    } catch (e) {
      print('Ошибка при получении данных: $e');
    }
  }

  // Сохранение изменений
  Future<void> _updateLectureContent() async {
    if (_contentController.text.isNotEmpty) {
      try {
        await _lectureRef.update({
          'content': _contentController.text.trim(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        await _fetchLectureData(); // Обновляем данные после сохранения
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.transparent,
              content: Text(
                textAlign: TextAlign.center,
                'Лекция обновлена!',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.20,
                  color: Colors.white,
                ),
              )),
        );
      } catch (e) {
        print('Ошибка при обновлении данных: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLectureData();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Лекция: ${widget.paragraphName}',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.20,
                ),
              ),
              if (_lastUpdated != null)
                Text(
                  _lastUpdated!.toDate().toLocal().toString().substring(0, 16),
                  style: const TextStyle(
                      fontSize: 12, color: Color.fromARGB(115, 255, 255, 255)),
                ),
            ],
          ),
        ),
        body: widget.isAdmin
            ? _buildAdminView()
            : _buildStudentView(), // Разные виды для администратора и студента
        floatingActionButton: widget.isAdmin
            ? FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: _updateLectureContent,
                child: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    ]);
  }

  // Вид для администратора
  Widget _buildAdminView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _contentController,
          maxLines: null,
          enabled: widget.isAdmin,
          readOnly: !widget.isAdmin,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.20,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(16.0),
          ),
        ),
      ),
    );
  }

  // Вид для студента
  Widget _buildStudentView() {
    final content = _contentController.text;

    // Если есть reference, подсвечиваем все вхождения
    final highlightedContent =
        widget.reference != null && widget.reference!.isNotEmpty
            ? content.replaceAll(
                RegExp(widget.reference!,
                    caseSensitive:
                        false), // Регулярное выражение для всех вхождений (регистр не важен)
                '<span style="background-color: yellow; font-weight: bold;">${widget.reference}</span>',
              )
            : content;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 3)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Html(
              data: highlightedContent != ''
                  ? highlightedContent
                  : 'Видимо, тут пусто... Обращайтесь к админу!', // Передаем текст с HTML-тегами
              style: {
                'span': Style(
                  backgroundColor: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}
