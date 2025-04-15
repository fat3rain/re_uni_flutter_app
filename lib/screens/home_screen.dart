import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:re_uni/screens/test_screen.dart';
import 'package:rive/rive.dart' hide Image;
import 'subject_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isAdmin;
  // user?.email??''
  // User? user = FirebaseAuth.instance.currentUser;

  const HomeScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? 'none';
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
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            isAdmin ? 'Вы - Admin' : 'Вы - Student',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.20,
            ),
          ),
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'reUNI',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.20,
                ),
              ),
              const SizedBox(
                height: 30,
              ),

              ElevatedButton(
                style: const ButtonStyle(
                  overlayColor: WidgetStatePropertyAll<Color>(Colors.black),
                  shadowColor: WidgetStatePropertyAll<Color>(Colors.black),
                  backgroundColor:
                      WidgetStatePropertyAll<Color>(Colors.transparent),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TestScreen(
                                isAdmin: isAdmin,
                              )));
                },
                child: Text(
                  'Перейти к тестам',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.20,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              const SizedBox(
                height: 200,
                width: 200,
                child: RiveAnimation.asset(
                  'assets/animations/loading_book_4.riv',
                ),
              ),
              // Image.asset(
              //   'assets/logo11.png',
              //   height: 300,
              //   width: 300,
              // ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  overlayColor: WidgetStatePropertyAll<Color>(Colors.black),
                  shadowColor: WidgetStatePropertyAll<Color>(Colors.black),
                  backgroundColor:
                      WidgetStatePropertyAll<Color>(Colors.transparent),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubjectsScreen(isAdmin: isAdmin),
                    ),
                  );
                },
                child: Text(
                  'Перейти к предметам',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.20,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Вы: $email',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              )
            ],
          ),
        ),
      ),
    ]);
  }
}

// Text(
//                     'скопируй код от !group',
//                     style: GoogleFonts.montserrat(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w400,
//                       letterSpacing: 1.20,
//                     ),
//                   ),
  // google_fonts: ^6.2.1
