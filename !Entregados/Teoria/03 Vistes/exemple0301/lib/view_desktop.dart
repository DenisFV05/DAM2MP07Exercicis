import 'package:flutter/cupertino.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Desktop View'),
      ),
      child: Container(
        color: const Color.fromARGB(
            255, 207, 236, 233), // Estableix el color de fons a gris clar
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0), // Afegir padding de 16 píxels
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Fes la finestra més petita per veure la vista de mòbil",
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
