import 'dart:io';
import 'dart:math';

const int filas = 6;
const int columnas = 10;
const int minasTotales = 8;

class Casilla {
  bool mina = false;
  bool descubierta = false;
  bool bandera = false;
  int minasAlrededor = 0;
}

class Buscaminas {
  late List<List<Casilla>> tablero;
  bool primeraJugada = true;
  int tiradas = 0;

  Buscaminas() {
    tablero = List.generate(
      filas,
      (_) => List.generate(columnas, (_) => Casilla()),
    );
    _colocarMinas();
    _calcularMinasAlrededor();
  }

  void _colocarMinas() {
    final rand = Random();
    int colocadas = 0;

    // Definición de cuadrantes: [filaInicio, filaFin, colInicio, colFin]
    List<List<int>> cuadrantes = [
      [0, 2, 0, 4],
      [0, 2, 5, 9],
      [3, 5, 0, 4],
      [3, 5, 5, 9]
    ];

    // Asegurar 2 minas por cuadrante
    for (var q in cuadrantes) {
      int minasQ = 0;
      while (minasQ < 2) {
        int f = rand.nextInt(q[1] - q[0] + 1) + q[0];
        int c = rand.nextInt(q[3] - q[2] + 1) + q[2];
        if (!tablero[f][c].mina) {
          tablero[f][c].mina = true;
          minasQ++;
          colocadas++;
        }
      }
    }

    // Colocar el resto aleatoriamente
    while (colocadas < minasTotales) {
      int f = rand.nextInt(filas);
      int c = rand.nextInt(columnas);
      if (!tablero[f][c].mina) {
        tablero[f][c].mina = true;
        colocadas++;
      }
    }
  }

  void _calcularMinasAlrededor() {
    for (int f = 0; f < filas; f++) {
      for (int c = 0; c < columnas; c++) {
        tablero[f][c].minasAlrededor = _contarMinasAlrededor(f, c);
      }
    }
  }

  int _contarMinasAlrededor(int f, int c) {
    int count = 0;
    for (int df = -1; df <= 1; df++) {
      for (int dc = -1; dc <= 1; dc++) {
        int nf = f + df;
        int nc = c + dc;
        if (nf >= 0 && nf < filas && nc >= 0 && nc < columnas) {
          if (tablero[nf][nc].mina) count++;
        }
      }
    }
    return count;
  }

  // Devuelve true si explota (jugada usuario que pisa mina)
  bool destaparCasilla(int f, int c, {bool esJugadaUsuario = true}) {
    if (f < 0 || f >= filas || c < 0 || c >= columnas) return false;
    var casilla = tablero[f][c];

    if (casilla.descubierta || casilla.bandera) return false;

    // Si hay mina
    if (casilla.mina) {
      if (primeraJugada) {
        // mover mina a otra posición vacía aleatoria
        _moverMina(f, c);
        // recalc minas alrededores ya hecho por _moverMina
      } else if (esJugadaUsuario) {
        // Explotó la mina
        return true;
      } else {
        // recursividad no explota
        return false;
      }
    }

    // Descubrir la casilla
    casilla.descubierta = true;
    if (esJugadaUsuario) tiradas++;

    // Si no hay minas alrededor, destapar recursivamente adyacentes
    if (casilla.minasAlrededor == 0) {
      for (int df = -1; df <= 1; df++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (df != 0 || dc != 0) {
            destaparCasilla(f + df, c + dc, esJugadaUsuario: false);
          }
        }
      }
    }

    primeraJugada = false;
    return false;
  }

  void _moverMina(int f, int c) {
    final rand = Random();
    // quitar mina de (f,c)
    tablero[f][c].mina = false;

    while (true) {
      int nf = rand.nextInt(filas);
      int nc = rand.nextInt(columnas);
      if (!tablero[nf][nc].mina && (nf != f || nc != c)) {
        tablero[nf][nc].mina = true;
        break;
      }
    }
    // recalcular vecinos
    _calcularMinasAlrededor();
  }

  void ponerQuitarBandera(int f, int c) {
    if (f < 0 || f >= filas || c < 0 || c >= columnas) return;
    var casilla = tablero[f][c];
    if (!casilla.descubierta) casilla.bandera = !casilla.bandera;
  }

  bool comprobarVictoria() {
    // victoria si todas las casillas no-mina están descubiertas
    for (int f = 0; f < filas; f++) {
      for (int c = 0; c < columnas; c++) {
        var cas = tablero[f][c];
        if (!cas.mina && !cas.descubierta) return false;
      }
    }
    return true;
  }

  // Imprime tablero. cheat -> dibuja tablero lateral con minas.
  // revealAll -> muestra todas las minas (usado al perder o ganar)
  void mostrarTablero({bool cheat = false, bool revealAll = false}) {
    // Cabecera izquierda
    String headerLeft = ' ' + List.generate(columnas, (i) => '$i').join('');
    if (!cheat) {
      print(headerLeft);
      for (int f = 0; f < filas; f++) {
        String row = String.fromCharCode(65 + f);
        for (int c = 0; c < columnas; c++) {
          row += _simboloCelda(f, c, revealAll: revealAll);
        }
        print(row);
      }
      return;
    }

    // Si cheat == true, generamos leftRows y rightRows y las mostramos lado a lado
    String headerRight = headerLeft;
    print('$headerLeft    $headerRight');
    for (int f = 0; f < filas; f++) {
      String leftRow = String.fromCharCode(65 + f);
      for (int c = 0; c < columnas; c++) {
        leftRow += _simboloCelda(f, c, revealAll: false);
      }

      String rightRow = String.fromCharCode(65 + f);
      for (int c = 0; c < columnas; c++) {
        rightRow += (tablero[f][c].mina ? '*' : ' ');
      }

      print('$leftRow    $rightRow');
    }
  }

  // Símbolo que representa una celda (un carácter)
  String _simboloCelda(int f, int c, {required bool revealAll}) {
    var cas = tablero[f][c];
    if (cas.bandera) return '#';
    if (!cas.descubierta) {
      // Si revealAll y es mina mostramos *, de lo contrario punto
      if (revealAll && cas.mina) return '*';
      return '·';
    }
    // cas.descubierta == true
    if (cas.mina) {
      // solo mostrar mina cuando revealAll es true (ej. al perder)
      return revealAll ? '*' : '·';
    }
    if (cas.minasAlrededor > 0) return '${cas.minasAlrededor}';
    return ' '; // celda descubierta sin minas alrededor -> espacio simple
  }

  void mostrarAyuda() {
    print('Comandes disponibles:');
    print('- Destapar: fila+columna (ex: A2, D5)');
    print('- Bandera: fila+columna flag o bandera (ex: B3 flag)');
    print('- Cheat/trampes: cheat o trampes');
    print('- Ajuda/help: ajuda o help');
  }

  // Mostrar tablero final (revelando minas), conservando banderas visibles
  void mostrarFinal({required bool lost}) {
    // Si lost -> mostrar minas y banderas; si ganado -> mostrar minas también
    mostrarTablero(revealAll: true);
  }
}

void main() {
  var juego = Buscaminas();
  bool juegoTerminado = false;
  bool skipNextDisplay = false; // para que cheat no muestre el tablero normal de nuevo

  while (!juegoTerminado) {
    if (!skipNextDisplay) {
      juego.mostrarTablero();
    }
    skipNextDisplay = false;

    stdout.write('Escriu una comanda: ');
    String? entrada = stdin.readLineSync();
    if (entrada == null) continue;
    var input = entrada.trim();

    if (input.isEmpty) continue;

    String lower = input.toLowerCase();

    if (lower == 'help' || lower == 'ajuda') {
      juego.mostrarAyuda();
      continue;
    }

    if (lower == 'cheat' || lower == 'trampes') {
      // Mostrar tablero con mines al lado (una sola vez)
      juego.mostrarTablero(cheat: true);
      // evitar imprimir otra vez el tablero normal inmediatamente
      skipNextDisplay = true;
      continue;
    }

    // Expresiones regulares: aceptar A-F o a-f y columnas 0-9
    RegExp banderaExp = RegExp(r'^\s*([a-fA-F])\s*([0-9])\s+(flag|bandera)\s*$', caseSensitive: false);
    RegExp casillaExp = RegExp(r'^\s*([a-fA-F])\s*([0-9])\s*$', caseSensitive: false);

    if (banderaExp.hasMatch(input)) {
      var match = banderaExp.firstMatch(input)!;
      int f = match.group(1)!.toUpperCase().codeUnitAt(0) - 65;
      int c = int.parse(match.group(2)!);
      juego.ponerQuitarBandera(f, c);
      continue;
    } else if (casillaExp.hasMatch(input)) {
      var match = casillaExp.firstMatch(input)!;
      int f = match.group(1)!.toUpperCase().codeUnitAt(0) - 65;
      int c = int.parse(match.group(2)!);

      // Si la casilla tiene bandera y el usuario escribe sólo la posición,
      // por enunciado: al escribir la posición de una bandera la selecciona:
      // si no hay mina destapa adyacentes, si hay mina explota.
      // En nuestro diseño, si hay bandera no se destapa; así que si queremos
      // comportarnos como indica, ignoramos la bandera momentáneamente:
      // (no cambiaremos bandera automática; pero si hay bandera y el usuario
      // quiere forzar la jugada, debe quitar la bandera antes)
      // <-- mantendremos comportamiento simple: no destapar si hay bandera.
      if (juego.tablero[f][c].bandera) {
        print('Casella amb bandera. Treu la bandera si vols destapar.');
        continue;
      }

      bool explota = juego.destaparCasilla(f, c, esJugadaUsuario: true);

      if (explota) {
        // Perdiste: mostrar tablero final con minas reveladas
        print('Has perdut!');
        juego.mostrarTablero(revealAll: true);
        print('Número de tirades: ${juego.tiradas}');
        juegoTerminado = true;
        break;
      }

      // Comprobar victoria
      if (juego.comprobarVictoria()) {
        print('Has guanyat! Felicitats!');
        juego.mostrarTablero(revealAll: true);
        print('Número de tirades: ${juego.tiradas}');
        juegoTerminado = true;
        break;
      }

      continue;
    } else {
      print('Comanda no vàlida. Escriu "help" o "ajuda" per veure les comandes.');
    }
  }
}
