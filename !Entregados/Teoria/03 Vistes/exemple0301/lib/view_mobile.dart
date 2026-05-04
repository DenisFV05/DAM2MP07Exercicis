import 'package:flutter/cupertino.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mobile View'),
      ),
      child: Container(
        color: CupertinoColors
            .lightBackgroundGray, // Estableix el color de fons a gris clar
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0), // Afegir padding de 16 píxels
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Fes la finestra més gran per veure la vista d'escriptori",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center), // Text centrat
              ],
            ),
          ),
        ),
      ),
    );
  }
}
