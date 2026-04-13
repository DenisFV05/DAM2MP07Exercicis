import 'package:flutter/cupertino.dart';
import 'picker360.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  ViewWidgetState createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  double _angle = 0.0;

  void onChanged(double value) {
    setState(() {
      _angle = value; // Aquí assignem el valor correcte
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Custom Widget'),
      ),
      child: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Picker360(value: _angle, onChanged: onChanged),
              const SizedBox(width: 8),
              SizedBox(
                width: 150,
                child: Text(
                  "Angle: ${_angle.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
