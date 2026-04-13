import 'dart:io';

void main() {
  double suma = 0.0;
  print("Introdueix un número (decimals amb .) o escriu 'sortir' per acabar:");

  while (true) {
    stdout.write("La suma actual és $suma\nIntrodueix un número o 'sortir': ");
    String? input = stdin.readLineSync();

    if (input == null) {
      continue;
    }

    if (input.toLowerCase() == 'sortir') {
      print("Finalitzant l'aplicació. La suma final és $suma");
      break;
    }

    try {
      double numero = double.parse(input);
      suma += numero;
    } catch (e) {
      print("Error, cal escriure un número o 'sortir'");
    }
  }
}
