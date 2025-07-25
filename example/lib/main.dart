import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
import 'package:rxdart/subjects.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OC Liquid Glass Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LiquidGlassDemo(),
    );
  }
}

class LiquidGlassDemo extends StatefulWidget {
  const LiquidGlassDemo({super.key});

  @override
  State<LiquidGlassDemo> createState() => _LiquidGlassDemoState();
}

class _LiquidGlassDemoState extends State<LiquidGlassDemo> {
  double _refractStrength = -0.06;
  double _blurRadius = 2.0;
  double _specStrength = 4.0;
  double _blendPx = 20.0;

  // Positions for draggable widgets
  late BehaviorSubject<Offset> _position1Controller;
  late BehaviorSubject<Offset> _position2Controller;
  late BehaviorSubject<Offset> _position3Controller;
  late BehaviorSubject<Offset> _position4Controller;

  @override
  void initState() {
    super.initState();
    _position1Controller = BehaviorSubject.seeded(Offset(50, 100));
    _position2Controller = BehaviorSubject.seeded(Offset(320, 200));
    _position3Controller = BehaviorSubject.seeded(Offset(100, 300));
    _position4Controller = BehaviorSubject.seeded(Offset(300, 400));
  }

  @override
  void dispose() {
    _position1Controller.close();
    _position2Controller.close();
    _position3Controller.close();
    _position4Controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OC Liquid Glass Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 18, 43, 91),
                    Color.fromARGB(255, 42, 83, 156),
                    Color.fromARGB(255, 134, 167, 219),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: GridPainter(),
                child: OCLiquidGlassGroup(
                  settings: OCLiquidGlassSettings(
                    blendPx: _blendPx,
                    specAngle: 0.8,
                    refractStrength: _refractStrength,
                    blurRadiusPx: _blurRadius,
                    specStrength: _specStrength,
                    specWidth: 2,
                    specPower: 10,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          // Glass droplet 1
                          StreamBuilder(
                              initialData: _position1Controller.valueOrNull,
                              stream: _position1Controller,
                              builder: (context, asyncSnapshot) {
                                final position1 =
                                    asyncSnapshot.data ?? Offset.zero;

                                return Positioned(
                                  left: position1.dx,
                                  top: position1.dy,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      _position1Controller.add(
                                        _position1Controller.value +
                                            details.delta,
                                      );
                                    },
                                    child: OCLiquidGlass(
                                      width: 250,
                                      height: 80,
                                      borderRadius: 40,
                                      color: Colors.amber.withAlpha(100),
                                      child: const SizedBox(),
                                    ),
                                  ),
                                );
                              }),

                          // Glass droplet 2
                          StreamBuilder(
                            initialData: _position2Controller.valueOrNull,
                            stream: _position2Controller,
                            builder: (context, asyncSnapshot) {
                              final position2 =
                                  asyncSnapshot.data ?? Offset.zero;
                              return Positioned(
                                left: position2.dx,
                                top: position2.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    _position2Controller.add(
                                      _position2Controller.value +
                                          details.delta,
                                    );
                                  },
                                  child: OCLiquidGlass(
                                    width: 100,
                                    height: 100,
                                    borderRadius: 50,
                                    color: Colors.lightGreen.withAlpha(220),
                                    child: const SizedBox(),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Glass droplet 3
                          StreamBuilder(
                            initialData: _position3Controller.valueOrNull,
                            stream: _position3Controller,
                            builder: (context, asyncSnapshot) {
                              final position3 =
                                  asyncSnapshot.data ?? Offset.zero;
                              return Positioned(
                                left: position3.dx,
                                top: position3.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    _position3Controller.add(
                                      _position3Controller.value +
                                          details.delta,
                                    );
                                  },
                                  child: OCLiquidGlass(
                                    width: 80,
                                    height: 120,
                                    borderRadius: 20,
                                    child: const SizedBox(),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Glass droplet 4
                          StreamBuilder(
                            initialData: _position4Controller.valueOrNull,
                            stream: _position4Controller,
                            builder: (context, asyncSnapshot) {
                              final position4 =
                                  asyncSnapshot.data ?? Offset.zero;
                              return Positioned(
                                left: position4.dx,
                                top: position4.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    _position4Controller.add(
                                      _position4Controller.value +
                                          details.delta,
                                    );
                                  },
                                  child: OCLiquidGlass(
                                    width: 60,
                                    height: 60,
                                    borderRadius: 30,
                                    color: Colors.black.withAlpha(150),
                                    child: const SizedBox(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                    'Refraction Strength: ${_refractStrength.toStringAsFixed(3)}'),
                Slider(
                  value: _refractStrength,
                  min: -0.2,
                  max: 0.2,
                  onChanged: (value) =>
                      setState(() => _refractStrength = value),
                ),
                Text('Blur Radius: ${_blurRadius.toStringAsFixed(1)}'),
                Slider(
                  value: _blurRadius,
                  min: 0,
                  max: 20,
                  onChanged: (value) => setState(() => _blurRadius = value),
                ),
                Text('Specular Strength: ${_specStrength.toStringAsFixed(1)}'),
                Slider(
                  value: _specStrength,
                  min: 0,
                  max: 5,
                  onChanged: (value) => setState(() => _specStrength = value),
                ),
                Text('Blend Pixels: ${_blendPx.toStringAsFixed(1)}'),
                Slider(
                  value: _blendPx,
                  min: 5,
                  max: 40,
                  onChanged: (value) => setState(() => _blendPx = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..strokeWidth = 1.5;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
