import 'dart:async';
import 'dart:math';
import 'package:commun/commun.dart';
import 'package:flutter/material.dart';

class CvlOdin extends StatefulWidget {
  const CvlOdin({super.key});

  @override
  CvlOdinState createState() => CvlOdinState();
}

class CvlOdinState extends State<CvlOdin> {
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: 5), () {
      context.showInfo("Innactivité détectée");
      context.showInfo("Vous allez bientôt être déconnécté");
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _resetInactivityTimer,
        onPanDown: (_) => _resetInactivityTimer(),
        child: Column(
          children: [
            SizedBox(height: 100),
            Text(
              "Portail applicatif",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _resetInactivityTimer();
                context.pushPage(CvlNotes());
              },
              style: ButtonStyle(
                fixedSize: WidgetStateProperty.all<Size>(Size(200, 60)),
                backgroundColor: WidgetStateProperty.all(
                  Colors.deepOrange,
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              child: Text(
                "Etudiants",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            SizedBox(height: 5),
            Align(
              child: CachedImage(
                imageUrl:
                    "https://odin.iut.uca.fr/portail/images/odin.jpg",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CvlNotes extends StatefulWidget {
  const CvlNotes({super.key});

  @override
  CvlNotesState createState() => CvlNotesState();
}

class CvlNotesState extends State<CvlNotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF29363f),
      appBar: AppBar(
        title: Text(
          "Tu va redouble a cause de goi",
          style: TextStyle(color: Color(0xFF43b34b)),
        ),
        backgroundColor: Color(0xFF333333),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: index % 10 != 0 ? 25 : 0),
            child: ListTile(
              title: Text(
                index % 10 == 0
                    ? "UE 1.${(index / 10).toInt()}"
                    : (Random().nextInt(20) / 3.64).toStringAsFixed(2),
                style: TextStyle(
                  color: index % 10 == 0
                      ? Color(0xFF8e90e0)
                      : Color(0xFF43b34b),
                ),
              ),
              subtitle: Text(
                "Tu t'es fait enculer par GOI",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
        itemCount: 40,
        shrinkWrap: true,
      ),
    );
  }
}
