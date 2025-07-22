import 'package:flutter/material.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

void main() {
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
  Offset _position1 = const Offset(50, 100);
  Offset _position2 = const Offset(320, 200);
  Offset _position3 = const Offset(100, 300);
  Offset _position4 = const Offset(300, 400);

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
                    Color(0xFF1E3C72),
                    Color(0xFF2A5298),
                    Color(0xFF3D6BB3),
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
                          Positioned(
                            left: _position1.dx,
                            top: _position1.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _position1 = Offset(
                                    (_position1.dx + details.delta.dx).clamp(0.0, constraints.maxWidth - 250),
                                    (_position1.dy + details.delta.dy).clamp(0.0, constraints.maxHeight - 80),
                                  );
                                });
                              },
                              child: OCLiquidGlass(
                                width: 250,
                                height: 80,
                                borderRadius: 40,
                                color: Colors.amber.withAlpha(100),
                                child: const SizedBox(),
                              ),
                            ),
                          ),
                          
                          // Glass droplet 2
                          Positioned(
                            left: _position2.dx,
                            top: _position2.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _position2 = Offset(
                                    (_position2.dx + details.delta.dx).clamp(0.0, constraints.maxWidth - 100),
                                    (_position2.dy + details.delta.dy).clamp(0.0, constraints.maxHeight - 100),
                                  );
                                });
                              },
                              child: OCLiquidGlass(
                                width: 100,
                                height: 100,
                                borderRadius: 50,
                                color: Colors.lightGreen.withAlpha(220),
                                child: const SizedBox(),
                              ),
                            ),
                          ),
                          
                          // Glass droplet 3
                          Positioned(
                            left: _position3.dx,
                            top: _position3.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _position3 = Offset(
                                    (_position3.dx + details.delta.dx).clamp(0.0, constraints.maxWidth - 80),
                                    (_position3.dy + details.delta.dy).clamp(0.0, constraints.maxHeight - 120),
                                  );
                                });
                              },
                              child: OCLiquidGlass(
                                width: 80,
                                height: 120,
                                borderRadius: 20,
                                child: const SizedBox(),
                              ),
                            ),
                          ),
                          
                          // Glass droplet 4
                          Positioned(
                            left: _position4.dx,
                            top: _position4.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _position4 = Offset(
                                    (_position4.dx + details.delta.dx).clamp(0.0, constraints.maxWidth - 60),
                                    (_position4.dy + details.delta.dy).clamp(0.0, constraints.maxHeight - 60),
                                  );
                                });
                              },
                              child: OCLiquidGlass(
                                width: 60,
                                height: 60,
                                borderRadius: 30,
                                color: Colors.black.withAlpha(200),
                                child: const SizedBox(),
                              ),
                            ),
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
                Text('Refraction Strength: ${_refractStrength.toStringAsFixed(3)}'),
                Slider(
                  value: _refractStrength,
                  min: -0.2,
                  max: 0.2,
                  onChanged: (value) => setState(() => _refractStrength = value),
                ),
                
                Text('Blur Radius: ${_blurRadius.toStringAsFixed(1)}'),
                Slider(
                  value: _blurRadius,
                  min: 0,
                  max: 10,
                  onChanged: (value) => setState(() => _blurRadius = value),
                ),
                
                Text('Specular Strength: ${_specStrength.toStringAsFixed(1)}'),
                Slider(
                  value: _specStrength,
                  min: 0,
                  max: 50,
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
