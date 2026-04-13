# Guia d'Execució i Demostració: Gestor Proxmox (Custom Widgets i Custom Painter)

El Repositori compta amb elements personalitzats totalment únics dins d'aquest directori utilitzant capacitats natives de processament per gràfics en Flutter.

## 🛠️ Requisits d'Instal·lació
1. **Flutter SDK** instal·lat correctament a la màquina on faràs la demostració pràctica de coneixement de mòbil/desktop.

## 🚀 Com Executar-ho
Obre la terminal al directori general (l'equivalent a Exercici 05 on jeu el fitxer Flutter d'arrel, usualment dins d'`Exercici 05A/gestor_proxmox` dependrit de la distribució interna temporal feta):
```bash
cd DAM2MP07Exercicis/GestorProxmox/Exercici\ 05A/\ "nom_carpeta"  # Modificar d'acord la ruta on consta pubspec.yaml del ProxMox de l'exercici.
flutter run -d windows
```

## 🎥 Com Demostrar el Seu Ús
Un cop en obertura mostra'l de la següent manera i per ordre:
1. Al llenç trobarem tots els dispositius llistats per panells per un `TitledListWidget`, passa una mica el ratolí indicant la qualitat visual i mostra els petits canvis o comportaments custom adaptats (hovering actiu en CustomWidgets).
2. Tira el repàs pel text i destaca ràpid el text label personalitzat en línies on demanaves IPs al document lliurat pel professor `LabeledTextField` per ensenyar integració UI pròpia total de widgets reutilitzables no vists abans.
3. El segon fort d'aquest apartat es visual sobre el mètode **`StatusIndicator`** i la xarxa, atura i assenyala la capacitat geomètrica per veure directament quins estan apagats amb pilots rodons de pintures o ràcios de text diferent (Servidor 1 / 2..).
4. El final rodó és **"l'Eina Discs del Baobab"** (`BaobabTreeWidget`). Demostra obrint diferents màquines simulades diferents com apareix un meravellós cercle que defineix per sectors/porcions l'arc d'ús a dins l'espai d'emmagatzematge.

## 🧠 Com Funciona Internament?
- **Widget Clàssic "CustomWidget" VS "CustomPainter":** Mentre que un `PortRedirectWidget` utilitza composició base d'arrels heretant estats Stateless o Stateful tradicionals com contenidors estàndard (SizedBox, Rows, Columns i decoracions clàssiques)...  L’Indicador `BaobabTreeWidget` i en certa mesura els focus per les boletes pures del "StatusIndicator", abandonen aquest procediment clàssic per baixar al metall pur que ofereix Flutter... Desenvolupant mètodes fets un a un (`Canvas.drawArc` o `drawCircle`) sobre les classes que heretin formalment el preuat `CustomPainter` usant Pinzells virtuals sense requerir afegir i estressar el motor de control Widget Tree del dispositiu, fent-ho més veloç al refrejament asíncron global de UI de fons pesats.
