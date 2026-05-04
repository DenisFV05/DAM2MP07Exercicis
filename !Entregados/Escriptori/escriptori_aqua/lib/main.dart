import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const AquaDesktopApp());
}

class AquaDesktopApp extends StatelessWidget {
  const AquaDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MacOS Aqua Desktop',
      theme: ThemeData(
        fontFamily: 'Lucida Grande',
        scaffoldBackgroundColor: const Color(0xFF6B92B9),
      ),
      home: const AquaDesktop(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// =============================================
// COLORES AQUA CLÁSICOS
// =============================================
class AquaColors {
  static const Color aquaBlue = Color(0xFF0A9CFF);
  static const Color aquaLightBlue = Color(0xFF7FCFFF);
  static const Color aquaGray = Color(0xFFE8E8E8);
  static const Color aquaDarkGray = Color(0xFF888888);
  static const Color aquaRed = Color(0xFFFF5F57);
  static const Color aquaYellow = Color(0xFFFFBD2E);
  static const Color aquaGreen = Color(0xFF27CA40);
  static const Color windowBackground = Color(0xFFECECEC);
  static const Color titleBarGradientTop = Color(0xFFDADADA);
  static const Color titleBarGradientBottom = Color(0xFFB8B8B8);
  static const Color stripedLight = Color(0xFFFFFFFF);
  static const Color stripedDark = Color(0xFFE8E8FF);
}

// =============================================
// ESCRITORIO PRINCIPAL
// =============================================
class AquaDesktop extends StatefulWidget {
  const AquaDesktop({super.key});

  @override
  State<AquaDesktop> createState() => _AquaDesktopState();
}

class _AquaDesktopState extends State<AquaDesktop> {
  final List<_WindowData> _windows = [];
  int _windowCounter = 0;

  void _openWindow(String title, Widget content) {
    setState(() {
      _windows.add(_WindowData(
        id: _windowCounter++,
        title: title,
        content: content,
        position: Offset(50.0 + (_windowCounter * 30), 80.0 + (_windowCounter * 20)),
      ));
    });
  }

  void _closeWindow(int id) {
    setState(() {
      _windows.removeWhere((w) => w.id == id);
    });
  }

  void _bringToFront(int id) {
    setState(() {
      final window = _windows.firstWhere((w) => w.id == id);
      _windows.remove(window);
      _windows.add(window);
    });
  }

  void _updatePosition(int id, Offset delta) {
    setState(() {
      final index = _windows.indexWhere((w) => w.id == id);
      if (index != -1) {
        _windows[index].position += delta;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de escritorio estilo Aqua
          _buildDesktopBackground(),
          
          // Barra de menú superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildMenuBar(),
          ),
          
          // Iconos del escritorio
          Positioned(
            top: 40,
            right: 20,
            child: _buildDesktopIcons(),
          ),
          
          // Ventanas
          ..._windows.map((w) => Positioned(
            left: w.position.dx,
            top: w.position.dy,
            child: AquaWindow(
              title: w.title,
              content: w.content,
              onClose: () => _closeWindow(w.id),
              onTap: () => _bringToFront(w.id),
              onDrag: (delta) => _updatePosition(w.id, delta),
            ),
          )),
          
          // Dock inferior
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: _buildDock(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6B92B9),
            Color(0xFF4A7A9F),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          // Apple logo
          const Text('', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 15),
          _menuItem('Finder'),
          _menuItem('Arxiu'),
          _menuItem('Editar'),
          _menuItem('Visualitzar'),
          _menuItem('Anar'),
          _menuItem('Finestra'),
          _menuItem('Ajuda'),
          const Spacer(),
          // Iconos de la derecha
          const Icon(Icons.wifi, size: 14, color: Colors.black54),
          const SizedBox(width: 12),
          const Icon(Icons.battery_full, size: 14, color: Colors.black54),
          const SizedBox(width: 12),
          Text(
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _menuItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDesktopIcons() {
    return Column(
      children: [
        _desktopIcon('Macintosh HD', Icons.computer, () {
          _openWindow('Macintosh HD', const _FinderContent());
        }),
        const SizedBox(height: 10),
        _desktopIcon('Documents', Icons.folder, () {
          _openWindow('Documents', const _FinderContent());
        }),
        const SizedBox(height: 10),
        _desktopIcon('Trash', Icons.delete_outline, () {}),
      ],
    );
  }

  Widget _desktopIcon(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onDoubleTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.blue.shade100,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AquaColors.aquaBlue, size: 28),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AquaColors.aquaBlue.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDock() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.6),
              Colors.white.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dockIcon(Icons.folder, 'Finder', () {
              _openWindow('Finder', const _FinderContent());
            }),
            _dockIcon(Icons.mail, 'Mail', () {
              _openWindow('Mail', const _MailContent());
            }),
            _dockIcon(Icons.language, 'Safari', () {
              _openWindow('Safari', const _SafariContent());
            }),
            _dockIcon(Icons.settings, 'Preferències', () {
              _openWindow('Preferències del Sistema', const _PreferencesContent());
            }),
            _dockIcon(Icons.calculate, 'Calculadora', () {
              _openWindow('Calculadora', const _CalculatorContent());
            }),
            _dockIcon(Icons.text_snippet, 'TextEdit', () {
              _openWindow('TextEdit', const _TextEditContent());
            }),
          ],
        ),
      ),
    );
  }

  Widget _dockIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AquaColors.aquaLightBlue,
                    AquaColors.aquaBlue,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================
// VENTANA ESTILO AQUA
// =============================================
class AquaWindow extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onClose;
  final VoidCallback onTap;
  final Function(Offset) onDrag;

  const AquaWindow({
    super.key,
    required this.title,
    required this.content,
    required this.onClose,
    required this.onTap,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 500,
        height: 350,
        decoration: BoxDecoration(
          color: AquaColors.windowBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Barra de título con efecto Aqua
            GestureDetector(
              onPanUpdate: (details) => onDrag(details.delta),
              child: Container(
                height: 22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AquaColors.titleBarGradientTop,
                      AquaColors.titleBarGradientBottom,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade500,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    // Botones semáforo Aqua
                    _trafficLightButton(AquaColors.aquaRed, onClose),
                    const SizedBox(width: 6),
                    _trafficLightButton(AquaColors.aquaYellow, () {}),
                    const SizedBox(width: 6),
                    _trafficLightButton(AquaColors.aquaGreen, () {}),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
            ),
            // Contenido
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _trafficLightButton(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [
              color.withValues(alpha: 0.8),
              color,
            ],
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.7),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================
// WIDGETS AQUA PERSONALIZADOS
// =============================================

// Botón Aqua clásico
class AquaButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AquaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<AquaButton> createState() => _AquaButtonState();
}

class _AquaButtonState extends State<AquaButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.isPrimary
                  ? [
                      _isHovered ? AquaColors.aquaLightBlue : AquaColors.aquaBlue,
                      AquaColors.aquaBlue,
                    ]
                  : [
                      _isHovered ? Colors.white : AquaColors.aquaGray,
                      AquaColors.aquaGray,
                    ],
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isPrimary
                  ? AquaColors.aquaBlue.withValues(alpha: 0.7)
                  : Colors.grey.shade400,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: widget.isPrimary ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// Checkbox Aqua
class AquaCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const AquaCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: value ? AquaColors.aquaBlue : Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.grey.shade500),
            ),
            child: value
                ? const Icon(Icons.check, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// Progress Bar Aqua
class AquaProgressBar extends StatelessWidget {
  final double value;

  const AquaProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          children: [
            // Fondo con rayas
            CustomPaint(
              painter: _StripedPainter(),
              size: const Size(double.infinity, 16),
            ),
            // Barra de progreso
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AquaColors.aquaLightBlue,
                      AquaColors.aquaBlue,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AquaColors.stripedDark
      ..strokeWidth = 2;

    for (double i = -size.height; i < size.width + size.height; i += 6) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================
// CONTENIDO DE LAS VENTANAS
// =============================================

class _FinderContent extends StatelessWidget {
  const _FinderContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Sidebar
          Container(
            width: 150,
            color: AquaColors.aquaGray,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FAVORITS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                _sidebarItem(Icons.desktop_mac, 'Escriptori'),
                _sidebarItem(Icons.folder, 'Documents'),
                _sidebarItem(Icons.download, 'Descàrregues'),
                _sidebarItem(Icons.image, 'Imatges'),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(16),
              children: [
                _folderIcon('Aplicacions'),
                _folderIcon('Usuaris'),
                _folderIcon('Sistema'),
                _folderIcon('Biblioteca'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AquaColors.aquaBlue),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _folderIcon(String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.folder, size: 48, color: AquaColors.aquaBlue),
        Text(name, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _MailContent extends StatelessWidget {
  const _MailContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 64, color: AquaColors.aquaBlue),
            SizedBox(height: 16),
            Text('Benvingut a Mail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('No tens missatges nous', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SafariContent extends StatelessWidget {
  const _SafariContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de navegación
        Container(
          height: 30,
          color: AquaColors.aquaGray,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Text(
                    'https://www.apple.com',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language, size: 64, color: AquaColors.aquaBlue),
                  SizedBox(height: 16),
                  Text('Safari', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreferencesContent extends StatefulWidget {
  const _PreferencesContent();

  @override
  State<_PreferencesContent> createState() => _PreferencesContentState();
}

class _PreferencesContentState extends State<_PreferencesContent> {
  bool _check1 = true;
  bool _check2 = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AquaColors.aquaGray,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferències del Sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          AquaCheckbox(
            value: _check1,
            onChanged: (v) => setState(() => _check1 = v),
            label: 'Activar notificacions',
          ),
          const SizedBox(height: 12),
          AquaCheckbox(
            value: _check2,
            onChanged: (v) => setState(() => _check2 = v),
            label: 'Mode nocturn',
          ),
          const SizedBox(height: 20),
          const Text('Volum:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          const AquaProgressBar(value: 0.7),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AquaButton(label: 'Cancel·lar', onPressed: () {}),
              const SizedBox(width: 10),
              AquaButton(label: 'Aplicar', onPressed: () {}, isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalculatorContent extends StatefulWidget {
  const _CalculatorContent();

  @override
  State<_CalculatorContent> createState() => _CalculatorContentState();
}

class _CalculatorContentState extends State<_CalculatorContent> {
  String _display = '0';

  void _onDigit(String digit) {
    setState(() {
      if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

  void _clear() {
    setState(() => _display = '0');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AquaColors.aquaGray,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              _display,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 24, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [
                _calcButton('C', _clear),
                _calcButton('±', () {}),
                _calcButton('%', () {}),
                _calcButton('÷', () {}),
                _calcButton('7', () => _onDigit('7')),
                _calcButton('8', () => _onDigit('8')),
                _calcButton('9', () => _onDigit('9')),
                _calcButton('×', () {}),
                _calcButton('4', () => _onDigit('4')),
                _calcButton('5', () => _onDigit('5')),
                _calcButton('6', () => _onDigit('6')),
                _calcButton('-', () {}),
                _calcButton('1', () => _onDigit('1')),
                _calcButton('2', () => _onDigit('2')),
                _calcButton('3', () => _onDigit('3')),
                _calcButton('+', () {}),
                _calcButton('0', () => _onDigit('0')),
                _calcButton('.', () => _onDigit('.')),
                _calcButton('=', () {}, isPrimary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcButton(String label, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isPrimary
                ? [AquaColors.aquaLightBlue, AquaColors.aquaBlue]
                : [Colors.white, AquaColors.aquaGray],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isPrimary ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _TextEditContent extends StatelessWidget {
  const _TextEditContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: const TextField(
        maxLines: null,
        expands: true,
        decoration: InputDecoration.collapsed(
          hintText: 'Comença a escriure...',
        ),
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}

class _WindowData {
  final int id;
  final String title;
  final Widget content;
  Offset position;

  _WindowData({
    required this.id,
    required this.title,
    required this.content,
    required this.position,
  });
}
