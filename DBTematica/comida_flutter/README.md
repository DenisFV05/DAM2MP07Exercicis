# DBTematica - Cliente (Flutter)

## 🚀 Cómo Ejecutar

```powershell
flutter pub get
flutter run
```

---

## 🏗️ Análisis del Código y Flujo

Esta aplicación implementa el patrón de **Consumo de API** en Flutter.

### Componentes de la Arquitectura

1.  **Modelo de Datos (`comida.dart`):**
    *   Define una clase `Comida` que refleja la estructura del JSON que envía el servidor (ej. `{id, nombre, imagen}`).
    *   Tiene un constructor `fromJson` (Factory constructor). Esto es vital: convierte el `Map<String, dynamic>` (que Dart crea al leer el JSON) en un objeto `Comida` tipado y seguro.

2.  **Capa de Red (`fetchComidas`):**
    *   Usa `http.get`. Es una operación **Asíncrona** (`Future`).
    *   Flujo de errores: Si el servidor no responde (código 200), lanza una excepción (`throw Exception`) que la UI debe capturar.

3.  **Gestión de Estado Asíncrono (`FutureBuilder`):**
    *   Esta es la pieza angular de la UI. En lugar de usar `setState` manualmente para "cargando..." -> "listo", Flutter nos da `FutureBuilder`.
    *   Le pasamos el `Future` de la petición.
    *   El `builder` se ejecuta varias veces dependiendo del estado de la conexión (`ConnectionState`):
        *   `waiting`: Mostramos `CircularProgressIndicator`.
        *   `done` + `hasError`: Mostramos mensaje de error.
        *   `done` + `hasData`: Mostramos la `ListView`.

### Flujo de la App
1.  Inicia `ComidaListScreen`.
2.  En `initState`, se prepara la llamada a la API (pero `FutureBuilder` es quien la gestiona visualmente).
3.  El usuario ve un spinner girando.
4.  Llega el JSON del servidor.
5.  `Comida.fromJson` crea una lista de objetos.
6.  `FutureBuilder` detecta data, reconstruye el widget y muestra la lista de platos.
