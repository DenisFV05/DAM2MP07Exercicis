import 'dart:io';
import 'dart:math';

class Buscaminas {
  static const int ROWS = 6;
  static const int COLS = 10;
  static const int TOTAL_MINES = 8;
  static const String LETTERS = 'ABCDEF';
  
  late List<List<String>> tauler;      // Tauler visible
  late List<List<bool>> mines;         // Posicions de les mines
  late List<List<bool>> descobertes;   // Caselles descobertes
  late List<List<bool>> banderes;      // Caselles amb bandera
  
  int tirades = 0;
  bool trampaActiva = false;
  bool partidaAcabada = false;
  bool primeraJugada = true;
  
  Buscaminas() {
    iniciarJoc();
  }
  
  void iniciarJoc() {
    tauler = List.generate(ROWS, (_) => List.generate(COLS, (_) => '·'));
    mines = List.generate(ROWS, (_) => List.generate(COLS, (_) => false));
    descobertes = List.generate(ROWS, (_) => List.generate(COLS, (_) => false));
    banderes = List.generate(ROWS, (_) => List.generate(COLS, (_) => false));
    
    colocarMines();
  }
  
  void colocarMines() {
    final random = Random();
    
    // Garantir almenys 2 mines a cada quadrant
    // Quadrant 1: [0,4] cols, [A,C] files (files 0-2, cols 0-4)
    // Quadrant 2: [5,9] cols, [A,C] files (files 0-2, cols 5-9)
    // Quadrant 3: [0,4] cols, [D,F] files (files 3-5, cols 0-4)
    // Quadrant 4: [5,9] cols, [D,F] files (files 3-5, cols 5-9)
    
    final quadrants = [
      {'rowMin': 0, 'rowMax': 2, 'colMin': 0, 'colMax': 4},
      {'rowMin': 0, 'rowMax': 2, 'colMin': 5, 'colMax': 9},
      {'rowMin': 3, 'rowMax': 5, 'colMin': 0, 'colMax': 4},
      {'rowMin': 3, 'rowMax': 5, 'colMin': 5, 'colMax': 9},
    ];
    
    int minesColocades = 0;
    
    // Primer, 2 mines per quadrant
    for (var q in quadrants) {
      int minesEnQuadrant = 0;
      while (minesEnQuadrant < 2) {
        int fila = q['rowMin']! + random.nextInt(q['rowMax']! - q['rowMin']! + 1);
        int col = q['colMin']! + random.nextInt(q['colMax']! - q['colMin']! + 1);
        if (!mines[fila][col]) {
          mines[fila][col] = true;
          minesEnQuadrant++;
          minesColocades++;
        }
      }
    }
    
    // Les mines restants (si n'hi ha) es posen aleatòriament
    while (minesColocades < TOTAL_MINES) {
      int fila = random.nextInt(ROWS);
      int col = random.nextInt(COLS);
      if (!mines[fila][col]) {
        mines[fila][col] = true;
        minesColocades++;
      }
    }
  }
  
  void mostrarTauler() {
    print('');
    String header = ' 0123456789';
    
    if (trampaActiva) {
      print('$header     $header');
    } else {
      print(header);
    }
    
    for (int i = 0; i < ROWS; i++) {
      String fila = LETTERS[i];
      for (int j = 0; j < COLS; j++) {
        fila += tauler[i][j];
      }
      
      if (trampaActiva) {
        fila += '     ${LETTERS[i]}';
        for (int j = 0; j < COLS; j++) {
          if (mines[i][j]) {
            fila += descobertes[i][j] ? 'X' : '*';
          } else if (descobertes[i][j]) {
            int num = comptarMinesAdjacents(i, j);
            fila += num == 0 ? ' ' : num.toString();
          } else {
            fila += '·';
          }
        }
      }
      
      print(fila);
    }
  }
  
  (int, int)? parseCasella(String input) {
    input = input.toUpperCase().trim();
    final regex = RegExp(r'^([A-F])([0-9])$');
    final match = regex.firstMatch(input);
    
    if (match == null) return null;
    
    int fila = LETTERS.indexOf(match.group(1)!);
    int col = int.parse(match.group(2)!);
    
    if (fila < 0 || fila >= ROWS || col < 0 || col >= COLS) return null;
    
    return (fila, col);
  }
  
  int comptarMinesAdjacents(int fila, int col) {
    int count = 0;
    for (int di = -1; di <= 1; di++) {
      for (int dj = -1; dj <= 1; dj++) {
        if (di == 0 && dj == 0) continue;
        int ni = fila + di;
        int nj = col + dj;
        if (ni >= 0 && ni < ROWS && nj >= 0 && nj < COLS) {
          if (mines[ni][nj]) count++;
        }
      }
    }
    return count;
  }
  
  void moureMina(int fila, int col) {
    final random = Random();
    mines[fila][col] = false;
    
    while (true) {
      int nfila = random.nextInt(ROWS);
      int ncol = random.nextInt(COLS);
      if (!mines[nfila][ncol] && !descobertes[nfila][ncol]) {
        mines[nfila][ncol] = true;
        break;
      }
    }
  }
  
  bool destapaCasella(int fila, int col, bool esPrimeraJugada, bool esJugadaUsuari) {
    // Si és fora dels límits o ja descoberta o té bandera
    if (fila < 0 || fila >= ROWS || col < 0 || col >= COLS) return false;
    if (descobertes[fila][col]) return false;
    if (banderes[fila][col]) return false;
    
    // Si és bomba
    if (mines[fila][col]) {
      if (esPrimeraJugada) {
        moureMina(fila, col);
        // Continua destapant normalment
      } else if (esJugadaUsuari) {
        return true; // Explosió
      } else {
        return false; // No explota durant la recursivitat
      }
    }
    
    descobertes[fila][col] = true;
    int numMines = comptarMinesAdjacents(fila, col);
    
    if (numMines == 0) {
      tauler[fila][col] = ' ';
      // Destapar recursivament les adjacents
      for (int di = -1; di <= 1; di++) {
        for (int dj = -1; dj <= 1; dj++) {
          if (di == 0 && dj == 0) continue;
          destapaCasella(fila + di, col + dj, false, false);
        }
      }
    } else {
      tauler[fila][col] = numMines.toString();
    }
    
    return false;
  }
  
  void escollirCasella(String input) {
    final casella = parseCasella(input);
    if (casella == null) {
      print('Casella no vàlida. Usa format: A0, B3, etc.');
      return;
    }
    
    final (fila, col) = casella;
    
    if (banderes[fila][col]) {
      print('Aquesta casella té una bandera. Treu-la primer amb "${LETTERS[fila]}$col flag".');
      return;
    }
    
    if (descobertes[fila][col]) {
      print('Aquesta casella ja està destapada.');
      return;
    }
    
    tirades++;
    bool explosio = destapaCasella(fila, col, primeraJugada, true);
    primeraJugada = false;
    
    if (explosio) {
      // Mostrar mines
      for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
          if (mines[i][j]) {
            tauler[i][j] = '*';
          }
        }
      }
      mostrarTauler();
      print('Has perdut!');
      print('Número de tirades: $tirades');
      partidaAcabada = true;
      return;
    }
    
    // Comprovar victòria
    bool guanyat = true;
    for (int i = 0; i < ROWS; i++) {
      for (int j = 0; j < COLS; j++) {
        if (!mines[i][j] && !descobertes[i][j]) {
          guanyat = false;
          break;
        }
      }
      if (!guanyat) break;
    }
    
    if (guanyat) {
      mostrarTauler();
      print('🎉 Has guanyat!');
      print('Número de tirades: $tirades');
      partidaAcabada = true;
    }
  }
  
  void posarBandera(String input) {
    final casella = parseCasella(input);
    if (casella == null) {
      print('Casella no vàlida. Usa format: A0 flag, B3 bandera, etc.');
      return;
    }
    
    final (fila, col) = casella;
    
    if (descobertes[fila][col]) {
      print('No pots posar bandera en una casella destapada.');
      return;
    }
    
    banderes[fila][col] = !banderes[fila][col];
    tauler[fila][col] = banderes[fila][col] ? '#' : '·';
    print(banderes[fila][col] ? 'Bandera posada.' : 'Bandera treta.');
  }
  
  void mostrarAjuda() {
    print('''
╔══════════════════════════════════════════════════════════╗
║                    💣 BUSCAMINES                          ║
╠══════════════════════════════════════════════════════════╣
║  Comandes disponibles:                                   ║
║                                                          ║
║  <casella>            - Escollir casella (ex: B2, D5)    ║
║  <casella> flag       - Posar/treure bandera             ║
║  <casella> bandera    - Posar/treure bandera             ║
║  cheat / trampes      - Mostrar/amagar trampes           ║
║  help / ajuda         - Mostra aquesta ajuda             ║
║  sortir               - Sortir del joc                   ║
╚══════════════════════════════════════════════════════════╝
''');
  }
  
  bool processarComanda(String input) {
    input = input.trim().toLowerCase();
    
    if (input.isEmpty) return true;
    
    if (partidaAcabada) {
      if (input == 'sortir' || input == 'exit') {
        return false;
      }
      print('La partida ha acabat. Escriu "sortir" per tancar.');
      return true;
    }
    
    final parts = input.split(RegExp(r'\s+'));
    final comanda = parts[0];
    
    switch (comanda) {
      case 'help':
      case 'ajuda':
        mostrarAjuda();
        break;
        
      case 'cheat':
      case 'trampes':
        trampaActiva = !trampaActiva;
        print(trampaActiva ? 'Trampes activades.' : 'Trampes desactivades.');
        break;
        
      case 'sortir':
      case 'exit':
        print('Adéu! 👋');
        return false;
        
      default:
        // Comprovar si és casella + flag/bandera
        if (parts.length >= 2 && (parts[1] == 'flag' || parts[1] == 'bandera')) {
          posarBandera(parts[0]);
        } else {
          // Intentar escollir casella
          escollirCasella(parts[0]);
        }
    }
    
    return true;
  }
  
  void iniciar() {
    print('\n💣 BUSCAMINES - Joc de línia de comandes');
    print('Escriu "ajuda" per veure les comandes disponibles.\n');
    
    while (true) {
      mostrarTauler();
      stdout.write('Escriu una comanda: ');
      final input = stdin.readLineSync() ?? '';
      
      if (!processarComanda(input)) {
        break;
      }
    }
  }
}

void main() {
  final joc = Buscaminas();
  joc.iniciar();
}
