# Guia d'Execució i Demostració: MarIA (Custom Calls i Ollama)

En aquest lliurament interactuem completament mitjançant trucades programàtiques a intel·ligència artificial offline dins la teva mateixa màquina "local" (mitjançant un Docker d'Ollama/Llama o models compatibles d'IA generadora).

## 🛠️ Requisits d'Instal·lació
1. **Flutter SDK**.
2. **Ollama** instal·lat prèviament al teu Ordinador PC on demostraràs el procediment.
3. Un model de llenguatge basat en execució preparat abans de començar per part de Ollama prèviament baixat via pull o ja preparat (Exemple `llama3` en local terminal prèviament o `qwen`).

## 🚀 Com Executar-ho
Obre la ruta dins del teu ordinador al client determinat segons si prefereixes ensenyar "L'eina de Imatges 07A", o l'aprovació d'administració pel Node ProxMox de la classe de Teoria.
Per exemple, si entres al Directori d'Acció de Dibuix A:
```bash
cd DAM2MP07Exercicis/MarIA\ Exercicis/Exercici\ 07A/dibujo_ia
flutter run -d windows
```
*(Igual que passava amb BD Temàtica, Recorda deixar correr en fons o background de minimitzat el teu sistema base d'Ollama corrent normal al client a darrere)*

## 🎥 Com Demostrar el Seu Ús
1. **Presentació (07A - Tira una Call Visual):** Assegura i menciona literalment el que estem veient: SÓC L'APP DIBUIXANT! Envia ràpid en text en el teu xatbot intern "Dibuixa'm un rectangle de color Blau i després repeteix a l'esquerre una rodona vermellosa". Assenyala ràpid que l'IA no acaba de "contestar-te textualment", sinó que t'envia directament i de forma estricta l'execució automàtica i sense requerir una línia teva l'acció a sobre del teu Widget del `CanvasPainter`.
2. **El punt al Proxmox (07B - Control System):** Al contrari... entra i demana-li a la MarIA... "Apaga'm d'urgència el Servidor del centre el qual és número ID:39". Revisa la vista com passa automàticament de status lluneta i rodoneta "Verd" a "Negre/Apagat" demostrant l'atac de directiva intern pel canvi automatitzat d'entitats internes i APIs generades a un simulacre remot real de Backend Sense tocar pas la pantalla. Tota l'acció delegada per NLP en text natural! L'Auditor estarà encantat!

## 🧠 Com Funciona Internament?
Mitjançant les eines i la teva implementació d'`ai_service.dart`:
Aquest fitxer té implementat els coneguts esdeveniments per les llibreries i models d'A.I com **`tools schema function calls`**.
En lloc de fer un "prompt al bot" lliure... el que envia el document internament és "Llista les meves funcions acceptades en format JSON estricte" a través del missatge inicial (ex:`draw_line` / `fill_rect` per defecte o `SystemD_Disable` segons la implementació de control usada). Ollama llegeix i accepta, generant de tornada un dictat per mètode clau json sense lletres humanes externes. I finalment l'eina Dart del front end del teu bloc intern en el telèfon "detecta la declaració de tipus", passant aquests paràmetres injectats al teu veritable `CustomPainter` desplaçant i canviant formes en calent total dins el context del teu UI d'Entitat Viva. 
L'autèntic i definitiu final del Front end avançat de control via IA d'aquest últim segle recentment sorgit de cara al disseny per als models com GPT o Llama!
