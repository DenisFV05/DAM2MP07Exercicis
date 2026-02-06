# Escriptori Aqua (Flutter)

## 🚀 Cómo Ejecutar

```powershell
flutter pub get
flutter run -d windows
```

---

## 🏗️ Análisis del Código y Flujo

Este proyecto es un ejercicio avanzado de **Layout (Diseño)** y **Gestión de Estado** en Flutter para simular un entorno de escritorio completo.

### El reto del Layout (`Stack`)

A diferencia de las apps móviles normales que usan columnas y filas (flujo vertical), un escritorio es libre.
*   **`Stack` Widget:** Es la base de todo. Permite poner elementos uno encima de otro (Z-index).
    *   Capa 0 (Fondo): Imagen de fondo.
    *   Capa 1 (Iconos): Posicionados libremente.
    *   Capa 2 (Ventanas): Widgets `WindowWidget` dentro de un `Stack`.
    *   Capa 3 (Dock): Alineado abajo.

### Componentes Clave

1.  **Ventanas (`WindowWidget`):**
    *   No son ventanas del sistema operativo, son **Widgets simulados**.
    *   **Contenedor con Estado:** Mantienen variables internas como `position` (Offset) y `size`.
    *   **Movimiento:** Usan el widget `Draggable` o `GestureDetector` para capturar el arrastre del ratón y actualizar sus coordenadas `top/left` dentro del Stack padre.

2.  **El Dock Animado:**
    *   El efecto de lupa ("magnification") clásico de Mac se logra con `MouseRegion`.
    *   Detecta dónde está el ratón y calcula una curva de distancia. Los iconos cercanos al ratón reciben un factor de escala mayor.
    *   Usa `AnimatedContainer` para que el cambio de tamaño sea suave y fluido.

3.  **Estilizado (Theming):**
    *   Para lograr el efecto "Aqua" (brilloso, cristalino), se hace uso intensivo de:
        *   `LinearGradient` para los brillos metálicos.
        *   `BoxShadow` múltiples para profundidad.
        *   Opcidad (`Colors.white.withOpacity(0.5)`) para el efecto vidrio.

### Flujo de Interacción
1.  Usuario arrastra una ventana.
2.  `GestureDetector.onPanUpdate` captura el delta de movimiento (`dx`, `dy`).
3.  `setState` actualiza la posición `x,y` de esa ventana específica.
4.  Flutter redibuja el Stack con la ventana en la nueva posición en el siguiente frame (16ms después). Todo se siente instantáneo.
