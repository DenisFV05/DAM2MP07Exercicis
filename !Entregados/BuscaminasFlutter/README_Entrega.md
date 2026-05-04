# Guia d'Execució i Demostració: Buscaminas (Dart)

Dins d'aquest directori trobem l'Exercici "Joc Dart cmd" de Buscamines, on el concepte més fort és la recursivitat en les cadenes buides d'un Click al buit.

## 🛠️ Requisits d'Instal·lació
1. **Dart SDK** instal·lat a la teva màquina en les variables d'entorn PATH.

## 🚀 Com Executar-ho
1. Obre el terminal.
2. Navega fins a la carpeta arrel del client Dart que conté les dependències i el projecte CLI:
   ```bash
   cd DAM2MP07Exercicis/BuscaminasFlutter/buscaminas_dart
   ```
3. Executa amb Dart el nom del paquet de la carpeta `bin/`:
   ```bash
   dart run bin/buscaminas_dart.dart
   ```

## 🎥 Com Demostrar el Seu Ús
Un cop en execució veuràs una taula 2D buida llista a acceptar entrades. 
1. Demostra els controls interactuant amb la paraula: `destapar fila columna`. (ex: `destapar 1 1`).
2. Tira la sentència de comandament `bandera <fila> <columna>` visualitzant el control marcat (normalment lletra `B`).
3. Realitza **un cop complet sobre una casella que doni blanc total (`0` bombes al voltant)**, la qual cosa obligatòriament mostrarà tota la pantalla emplenant-se sense teclejar res, una explosió on tota la taula veïnada mostrarà el numero de mines pròximes, desmuntant els marges amagats en una simple i única sentència d'acció! 
4. Ocult i sense dir-ho enlaire, mostra l'script al professor destacant que hi compta del famós requeriment tècnic on està permès perdre i destapar "una mina en la primera jugada", explicant que ell el sistema posseeix la capacitat del `moureMina()`, per no amargar mai cap partida la segona u de funcionament!

## 🧠 Com Funciona Internament?
L'escript utilitza lògiques d'algorítmia per l'assentament de probabilitats d'un camp minat.
- Trobem el bloc a destacar cridat de normal `destapaCasella`:
  Si s'activa un punt que conté numèric `0`, s'inicia una Funció Recursiva: Es crida a sí mateixa al veí de Dalt. Aquell detecta si també rep el paràmetre que es buit, repesca a tots els integrants drets, sota, esquerra. Parant finalment si hi ha final de Llenç (`IndexOutBounds()`) i posant el tap al mur del Recurs fins a saturació i revelat constant de taula blanca fins a les limitacions numerades pròximes al costat d'una autèntica perillosa Mina.
