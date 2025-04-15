import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_uni/widgets/custom_text_field.dart'; // Убедитесь, что этот импорт верный
import 'lecture_screen.dart'; // Импортируем LectureScreen

class GraphScreen extends StatefulWidget {
  final String paragraphId;
  final String subjectId;

  const GraphScreen({
    super.key,
    required this.paragraphId,
    required this.subjectId,
  });

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  CollectionReference get _graphsRef => FirebaseFirestore.instance
      .collection('subjects')
      .doc(widget.subjectId)
      .collection('paragraphs')
      .doc(widget.paragraphId)
      .collection('graphs');

  CollectionReference get _paragraphsRef => FirebaseFirestore.instance
      .collection('subjects')
      .doc(widget.subjectId)
      .collection('paragraphs');

  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  String? _selectedParagraphId; // ID выбранного параграфа
  List<QueryDocumentSnapshot> _paragraphs = [];

  /// Загрузка списка параграфов
  Future<void> _fetchParagraphs() async {
    try {
      final snapshot = await _paragraphsRef.get();
      setState(() {
        _paragraphs = snapshot.docs;
      });
    } catch (e) {
      print('Ошибка загрузки параграфов: $e');
    }
  }

  /// Добавление метки
  Future<void> _addKeyword() async {
    if (_keywordController.text.isNotEmpty &&
        _referenceController.text.isNotEmpty &&
        _selectedParagraphId != null) {
      try {
        await _graphsRef.add({
          'keyword': _keywordController.text.trim(),
          'reference': _referenceController.text.trim(),
          'lectureId': _selectedParagraphId, // Связь с выбранным параграфом
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        _keywordController.clear();
        _referenceController.clear();
        setState(() {
          _selectedParagraphId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.transparent,
              content: Text(
                textAlign: TextAlign.center,
                'Метка добавлена!',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.20,
                  color: Colors.white,
                ),
              )),
        );
      } catch (e) {
        print('Ошибка при добавлении: $e');
      }
    }
  }

  /// Удаление метки
  Future<void> _deleteKeyword(String docId) async {
    try {
      await _graphsRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.transparent,
            content: Text(
              textAlign: TextAlign.center,
              'Метка удалена!',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.20,
                color: Colors.white,
              ),
            )),
      );
    } catch (e) {
      print('Ошибка при удалении: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchParagraphs();
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
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
          title: Text(
            'Создание меток',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.20,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Поле для ключевого слова
                  CustomTextField(
                    controller: _keywordController,
                    name: 'Введите метку',
                  ),
                  const SizedBox(height: 10),

                  // Выпадающий список параграфов
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.transparent,
                    value: _selectedParagraphId,
                    onChanged: (value) {
                      setState(() {
                        _selectedParagraphId = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      labelText: 'Выберите параграф',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    items: _paragraphs.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(
                          doc['name'] ?? 'Без названия',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Поле для ссылки
                  CustomTextField(
                    controller: _referenceController,
                    name: 'Введите текст ссылки',
                  ),
                  const SizedBox(height: 10),

                  // Кнопка добавления
                  ElevatedButton(
                    style: const ButtonStyle(
                      overlayColor: WidgetStatePropertyAll<Color>(Colors.black),
                      shadowColor: WidgetStatePropertyAll<Color>(Colors.black),
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.transparent),
                    ),
                    onPressed: _addKeyword,
                    child: Text(
                      'Добавить метку',
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
            // const Divider(),

            // Список меток
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _graphsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Пока что меток нет...',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.20,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final lectureId = data['lectureId'] ?? '';

                      return FutureBuilder<DocumentSnapshot>(
                        future: _paragraphsRef
                            .doc(lectureId)
                            .get(), // Запрашиваем параграф по его ID
                        builder: (context, paragraphSnapshot) {
                          String paragraphName = 'Без названия';

                          if (paragraphSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Загрузка...'),
                            );
                          }

                          if (paragraphSnapshot.hasError) {
                            paragraphName = 'Ошибка';
                          } else if (paragraphSnapshot.hasData &&
                              paragraphSnapshot.data!.exists) {
                            final paragraphData = paragraphSnapshot.data!.data()
                                as Map<String, dynamic>;
                            paragraphName =
                                paragraphData['name'] ?? 'Без названия';
                          }

                          // Отображаем метку с названием параграфа
                          return ListTile(
                            title: Text(
                              '${data['keyword']} - параграф: $paragraphName',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.20,
                              ),
                            ),
                            subtitle: Text(
                              data['reference'] ?? 'Нет ссылки',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.20,
                              ),
                            ),
                            leading: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteKeyword(doc.id),
                            ),
                            trailing: IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                final reference = data['reference'] ?? '';
                                final lectureId = data['lectureId'] ?? '';

                                if (lectureId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LectureScreen(
                                        paragraphId: lectureId,
                                        subjectId: widget.subjectId,
                                        paragraphName: paragraphName,
                                        isAdmin: false, // Передаем статус
                                        reference: reference, // Передаем ссылку
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Параграф не найден')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
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
