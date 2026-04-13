# Guia d'Execució i Demostració: BattleRoyale (Tancs)

Aquest document explica com executar l'entorn multijugador en temps real conformat per un Servidor WebSockets (NodeJS) i un Client Jugador (Flutter).

## 🛠️ Requisits d'Instal·lació

Aquest projecte consta de dues parts i cadascuna requereix les seves eines:

**Per al Servidor (NodeJS):**
1.  **Node.js** (versió LTS recomanada, 18+).
2.  **npm** (inclòs amb Node).

**Per al Client (Flutter):**
1.  **Flutter SDK** (versió 3.19 o superior).
2.  **Web_socket_channel** (dependència de Flutter afegida al pubspec.yaml).

## 🚀 Com Executar-ho

L'entorn multijugador requereix iniciar primer el servidor i després els clients (jugadors).

### 1. Iniciar el Servidor
Obre una terminal i ves al directori del servidor:
```bash
cd DAM2MP09-Exercicis00Processos/BattleRoyale/server_nodejs
```
Instal·la les dependències (només la primera vegada):
```bash
npm install
```
Arrenca el servidor:
```bash
npm run dev
```
> Veuràs un missatge indicant que el servidor està actiu al port `3000`. No tanquis aquesta terminal.

### 2. Iniciar el/s Client/s
Obre una **nova** terminal i ves al directori del client:
```bash
cd DAM2MP07Exercicis/BattleRoyale/client_flutter
```
Instal·la les dependències (només la primera vegada):
```bash
flutter pub get
```
Inicia una instància del joc (com a aplicació d'escriptori):
```bash
flutter run -d windows
```
*(Torna a executar aquest mateix comandament en una altra terminal per obrir un segon jugador simultani).*

## 🎥 Com Demostrar el Seu Ús

Per obtenir una nota de 10 amb aquesta pràctica, segueix aquest flux dramàtic de demostració:

1.  **Ensurt Visual:** Obre el teu terminal de NodeJS on ja corre el servidor. Deixa-la en una cantonada de la pantalla per veure els missatges de *"WebSocket client connected"*.
2.  **Multijugador al Moment:** Obre DOS finestres del Client Flutter una al costat de l'altra a la teva pantalla.
3.  **El Login:** En una introdueix de nom "Jugador 1" i en l'altra "Jugador 2". El camp "Servidor" ja apunta per defecte a `localhost:3000`. Prem **Connectar** a totes dues alhora.
4.  **Sala d'Espera (Waiting Room):** En connectar-se el primer només posarà "Esperant". Al moment que es connecta el segon, saltarà un *Compte Enrere* global vermell visible en absolutament totes les pantalles.
5.  **A jugar!:** 
    - Explica els controls bàsics ràpidament: Tecles `WASD` per moure el tanc. Per disparar fas *Clic Esquerre* en qualsevol punt exacte amb el ratolí.
    - Fes que el *Jugador 1* persegueixi al *Jugador 2*, els tancs i l'orientació van en perfecte temps real net. 
    - Dispara a l'altre Tanc; veuràs un efecte fluid de col·lisió de bales.
    - Després d'una estona i treure-li gairebé vida, mostra ràpidament la cura (La "Creu Verda" il·luminada), fa que l'altre Tanc el toqui per mostrar com la **barra de vida superior HUD** augmenta instantàniament.
6.  **K.O i Rànquing Final:** Dóna-li un parell de trets més fins que quedi destruït amb un "💀". Si només hi ha 2 jugadors a l'apartat, el joc tallarà directament, redirigint ambdues finestres a la taula visual de Top Resultats indicant exactament els Danys, les Kills i emplaçant el líder d'Or d'aquella partida. 

## 🧠 Com Funciona Internament?

Aquesta arquitectura replica un vertader sistema professional: **"Authoritative Server Architecture"**.

1. **Mai Confiïs en el Client:** Els Tancs al *client* (el dibuix en UI) no són intel·ligents per decidir on estan, on viatja un tret seu, o si xoquen amb la paret. El codi Dart de Flutter fa únicament 2 coses: escoltar l'input teclejat en local de l'usuari i rendir un `CustomPainter` usant un bucle constant repintant sobre un llenç a base d'estímuls WebSocket ràpids enviats des del backend.
2. **Backpressure al servidor:** Si perds connexió per 200 ms, l'script `utilsGameMessages.js` al servidor (importat prèviament per en NodeJS) impedeix engreixar el *buffer/socket* sobresaturant el client. Llença la informació i es reemplaça únicament amb la nova lectura del proper "tick". Així només rep l'estat del joc instantani de tot just ara sense cap mena d'embutilament per un WiFi inestable!
3. **El GameLoop i la Vida Lògica:** El Node processa un array on cada client té les coordenades i l'Estat `health`. Els projectils (bales disparades) també existeixen al Servidor en memòria avançant rectament pels seus propis `dt` i verifiquen solapaments "Overlap bounding box" constant amb qualsevol de les parets creades o l'`X`/`Y` dels rivals actius. Si detecten l'intercepció modifiquen automàticament la barres de vides i informen globalment a tots els pantalles per `ws.broadcastGameState()`.
