# Buscaminas (Dart CLI)

## 🚀 Cómo Ejecutar

```powershell
# En la carpeta del proyecto
dart run
```

---

## 🏗️ Análisis del Código y Flujo

Este proyecto demuestra cómo gestionar lógica de estado compleja en una aplicación de consola secuencial.

### Estructura de Clases

*   **`Casella` (Clase):** Representa cada unidad del tablero.
    *   Propiedades: `esMina` (bool), `revelada` (bool), `marcada` (bool), `minasVeines` (int).
    *   Es la unidad atómica de estado.
*   **`Tablero` (Clase Entidad):**
    *   Contiene la matriz `List<List<Casella>>`.
    *   **Generación:** Al iniciar, coloca minas aleatoriamente (`Random().nextInt`). Importante: Garantiza que no se superpongan.
    *   **Cálculo de Vecinos:** Después de poner minas, recorre CADA casilla y mira sus 8 vecinas. Si una vecina es mina, incrementa su contador. Esto se pre-calcula al inicio para que el juego sea rápido durante la partida.

### Flujo del Juego (Game Loop)

El programa corre dentro de un bucle `while (!gameOver)`:

1.  **Renderizado (`imprimirTablero`):**
    *   Limpia la consola (o imprime líneas nuevas).
    *   Itera la matriz. Si `revelada` es falso, imprime `■`. Si es verdadero, imprime el número o mina.
2.  **Input (`stdin.readLineSync`):**
    *   El programa se pausa esperando que el usuario escriba.
    *   Formato esperado: "fila columna" (ej "3 4").
3.  **Procesamiento:**
    *   Parsea el input. Valida que esté dentro de rangos.
    *   **Lógica de Revelado Recursivo (Flood Fill):** Si destapas una casilla con `0` minas vecinas, el juego automáticamente destapa a todas sus vecinas, y si estas son 0, a sus vecinas... Esto se hace con una función recursiva `revelarVecinos(x, y)`. Es lo que da la satisfacción de ver abrirse un gran hueco en el tablero.
4.  **Condición de Victoria/Derrota:**
    *   Si pisas mina -> `gameOver = true`, pierdes.
    *   Si `casillasTotales - casillasReveladas == numeroMinas` -> has ganado.

### Funciones Clave
*   `_calcularMinasAdyacentes()`: Algoritmo crítico de inicialización.
*   `revelar(x, y)`: Gestiona la recursividad del "flood fill".
