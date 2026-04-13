<div style="display: flex; width: 100%;">
    <div style="flex: 1; padding: 0px;">
        <p>© Albert Palacios Jiménez, 2023</p>
    </div>
    <div style="flex: 1; padding: 0px; text-align: right;">
        <img src="./assets/ieti.png" height="32" alt="Logo de IETI" style="max-height: 32px;">
    </div>
</div>
<br/>

# Vistes i navegació

A Flutter les vistes també són Widgets.

Flutter proporciona diverses maneres de navegar entre pantalles. La més comuna és utilitzar el widget Navigator. El Navigator gestiona una pila de rutes (vistes/pantalles) i proporciona mètodes per empènyer noves rutes a la pila o treure-les.

- **Navigator.push**: Utilitzat per empènyer una nova ruta a la pila de navegació. En aquest exemple, MaterialPageRoute es construeix amb SecondPage com la nova pantalla.
- **Navigator.pop**: Utilitzat per treure la ruta superior de la pila de navegació i tornar a la pantalla anterior.

Per exemple, per canviar de vista apretant un botó:

```dart
CupertinoButton(
    child: const Text('Go to View 1'),
    onPressed: () {
        Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => View1()),
        );
    },
),
```

**Nota:** Amb els widgets de *Cupertino* la barra de navegació ja mostra el botó *"<"* per tornar enrrera fent un *".pop"* de manera automàtica.

**Exemple 0300:**

```bash
cd exemple0300
flutter run -d macos
```

<br/>
<center><img src="./assets/ex0300.png" style="max-height: 400px" alt="">
<br/></center>
<br/>

## Vistes segons la mida de la pantalla

Es pot comprovar la mida de la pantalla, per mostrar les vistes segons calgui:

**Exemple 0301:**

En aquest exemple s'escull la vista segons si l'espai disponible és superior o inferior a 600 píxels:

```dart
  @override
Widget build(BuildContext context) {
return LayoutBuilder(
    builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
        return ViewDesktop();
    } else {
        return ViewMobile();
    }
    },
);
}
```

```bash
cd exemple0301
flutter run -d macos
```

<br/>
<center><img src="./assets/ex0301.png" style="max-height: 400px" alt="">
<br/></center>
<br/>
<br/>

## Subvistes

Com que amb Flutter tot són Widgets, és fàcil crear subvistes que es fan servir en llistes.

La subvista es forma com qualsevol altre widget, però se li passen els paràmetres amb la informació.

**Exemple 0302:**

En aquest exemple la subvista rep com a paràmtre un objecte tipus **"ColorData"** que conté la informació específica de cada element de la llista.

Quan es vol fer servir la informació només cal fer *data.??* on ?? és l'atribut que es vol obtenir: 

```dart
class ColorListItem extends StatelessWidget {
  final ColorData data;

  const ColorListItem({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ViewColorDetail(data: data),
          ),
        );
      },
      child: Container(
        color: CupertinoColors
            .white, // Color de fons per assegurar la detecció de tocs
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.name}, ${data.color}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              // ...
            ],),],),),
    }
}
```

Per formar una *ListView* a partir d'una llista es fa servir un *".builder"*. En aquest exemple:

- La llista amb la informació està a *"List<ColorData> colorDataList"*.
- El *builder* passa la informació a cada *ColorListItem* amb el paràmetre *"data"* del constructor.

```dart
class ColorListItem extends StatelessWidget {
  final ColorData data;

  const ColorListItem({required this.data, super.key});

  //  ...
}
```

```dart
child: ListView.builder(
  itemCount: colorDataList.length,
  itemBuilder: (context, index) {
    return Column(
      children: [
        ColorListItem(data: colorDataList[index]),
        if (index < colorDataList.length - 1)
          const Divider(
            height: 1,
            thickness: 1,
            color: CupertinoColors.separator,
          ),
      ],
    );
  },
),
```

**Nota:** En aquest exemple es mostra una linia separatòria (*Divider*) entre cada element de la llista (excepte l'últim element)

Per enviar dades a una subvista, es fa igual:

```dart
    onTap: () {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => ViewColorDetail(data: data),
        ),
      );
    },
```

```dart
class ViewColorDetail extends StatelessWidget {
  final ColorData data;

  const ViewColorDetail({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(data.name),
      ),
      child: Center(
        // ...
      ),
    );
  }
}
```

<br/>
<center><img src="./assets/ex0302.gif" style="max-height: 400px" alt="">
<br/></center>
<br/>
<br/>