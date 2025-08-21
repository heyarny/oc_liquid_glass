import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/**
 * LiquidGlass Shader Example - Creates realistic glass droplet effects
 * 
 * This file demonstrates a complex shader-based implementation that creates
 * liquid glass droplets with realistic refraction, blur, and lighting effects.
 * The system uses Flutter's FragmentShader API to apply GPU-accelerated effects.
 * 
 * Key Components:
 * - LiquidGlassSettings: Configuration for visual parameters
 * - LiquidGlassGroup: Container that manages multiple glass shapes
 * - LiquidGlass: Individual glass droplet widget
 * - Custom RenderObjects: Handle the low-level rendering and shader application
 */

/// Configuration class that holds all visual parameters for the liquid glass shader effect.
/// These parameters control various aspects like refraction, blur, lighting, and color.
class OCLiquidGlassSettings {
  // Shader uniform parameters - these control the visual appearance of the glass effect
  final double blendPx;           // Edge blending distance in pixels for smooth transitions
  final double refractStrength;   // Strength of light refraction (-1.0 to 1.0, negative = concave lens)
  final double distortFalloffPx;  // Distance over which distortion effect fades out
  final double distortExponent;   // Controls how sharply distortion falls off (higher = sharper)
  final double blurRadiusPx;      // Base blur radius applied to the glass area
  
  // Specular highlight parameters - creates the shiny reflection on glass surface
  final double specAngle;         // Light source angle for specular highlights
  final double specStrength;      // Intensity of specular highlights
  final double specPower;         // Sharpness of specular highlights (higher = sharper)
  final double specWidth;         // Specular width in px
  
  // Light band effect - creates a bright band across the glass for realism
  final double lightbandOffsetPx; // Distance from edge where light band appears
  final double lightbandWidthPx;  // Width of the light band effect
  final double lightbandStrength; // Intensity of the light band
  final Color lightbandColor;     // Color of the light band

  const OCLiquidGlassSettings({
    this.blendPx = 5,
    this.refractStrength = -0.06,
    this.distortFalloffPx = 45,
    this.distortExponent = 4,
    this.blurRadiusPx = 0,

    this.specAngle = 4,
    this.specStrength = 20.0,
    this.specPower = 100,
    this.specWidth = 10,

    this.lightbandOffsetPx = 10,
    this.lightbandWidthPx = 30,
    this.lightbandStrength = 0.9,
    this.lightbandColor = Colors.white,
  });

  /// Creates a copy of this settings object with the given fields replaced with new values.
  OCLiquidGlassSettings copyWith({
    double? blendPx,
    double? refractStrength,
    double? distortFalloffPx,
    double? distortExponent,
    double? blurRadiusPx,

    double? specAngle,
    double? specStrength,
    double? specPower,
    double? specWidth,

    double? lightbandOffsetPx,
    double? lightbandWidthPx,
    double? lightbandStrength,
    Color? lightbandColor,
  }) {
    return OCLiquidGlassSettings(
      blendPx: blendPx ?? this.blendPx,
      refractStrength: refractStrength ?? this.refractStrength,
      distortFalloffPx: distortFalloffPx ?? this.distortFalloffPx,
      distortExponent: distortExponent ?? this.distortExponent,
      blurRadiusPx: blurRadiusPx ?? this.blurRadiusPx,

      specAngle: specAngle ?? this.specAngle,
      specStrength: specStrength ?? this.specStrength,
      specPower: specPower ?? this.specPower,
      specWidth: specWidth ?? this.specWidth,

      lightbandOffsetPx: lightbandOffsetPx ?? this.lightbandOffsetPx,
      lightbandWidthPx: lightbandWidthPx ?? this.lightbandWidthPx,
      lightbandStrength: lightbandStrength ?? this.lightbandStrength,
      lightbandColor: lightbandColor ?? this.lightbandColor,
    );
  }
}

/// Simplified shape data structure used to pass geometry information to the shader.
/// Each LiquidGlass widget gets converted into this format for GPU processing.
/// The border radius is automatically clamped to max(width/2, height/2) to ensure valid geometry.
class ShapeData {
  final Offset center;        // Center position of the glass shape
  final Size size;           // Width and height of the glass shape
  final double borderRadius; // Border radius (clamped to half of smaller dimension)
  final Color color; // Optional tint color for the glass shape
  ShapeData(this.center, this.size, this.borderRadius, this.color);
}

/// Container widget that manages multiple liquid glass shapes and applies the shader effect.
/// This widget loads the fragment shader and creates a render layer that collects
/// all LiquidGlass children and applies the unified glass effect to them.
///
/// Usage: Wrap your content with LiquidGlassGroup, then add LiquidGlass widgets
/// anywhere in the child tree to create glass droplets.
class OCLiquidGlassGroup extends StatefulWidget {
  final OCLiquidGlassSettings settings;
  final Widget child;
  const OCLiquidGlassGroup({
    super.key,
    required this.settings,
    required this.child,
  });

  @override
  State<OCLiquidGlassGroup> createState() => _OCLiquidGlassGroupState();
}

class _OCLiquidGlassGroupState extends State<OCLiquidGlassGroup> {
  FragmentProgram? _program; // Compiled shader program from the .frag file

  @override
  void initState() {
    super.initState();
    // Asynchronously load and compile the fragment shader from assets
    // The shader file contains the GLSL code that creates the glass effect
    FragmentProgram.fromAsset(
      'packages/oc_liquid_glass/shaders/liquid_glass.frag',
    ).then((p) => setState(() => _program = p));
  }

  @override
  Widget build(BuildContext context) {
    // Show child without effect while shader is loading
    if (_program == null) {
      return widget.child;
    }
    // Once shader is loaded, create the render object that applies the effect
    return _LiquidGlassGroupRenderObject(
      shader: _program!.fragmentShader(),
      settings: widget.settings,
      child: widget.child,
    );
  }
}

/// Internal widget that bridges between Flutter widgets and the custom render object.
/// This creates and manages the RenderLiquidGlassLayer that does the actual rendering.
class _LiquidGlassGroupRenderObject extends SingleChildRenderObjectWidget {
  final FragmentShader shader;
  final OCLiquidGlassSettings settings;

  const _LiquidGlassGroupRenderObject({
    required this.shader,
    required this.settings,
    super.child,
  });

  @override
  _RenderLiquidGlassGroup createRenderObject(BuildContext context) {
    // Create the custom render object with device pixel ratio for proper scaling
    final position = Scrollable.maybeOf(context)?.position;
    final renderObject = _RenderLiquidGlassGroup(
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      shader: shader,
      settings: settings,
      position: position,
    );

    _attachRouteAnimation(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLiquidGlassGroup renderObject,
  ) {
    // Update render object when settings change or device characteristics change
    final position = Scrollable.maybeOf(context)?.position;
    renderObject
      ..devicePixelRatio = MediaQuery.of(context).devicePixelRatio
      ..settings = settings
      ..scrollPosition = position;

    _attachRouteAnimation(context, renderObject);
  }

  void _attachRouteAnimation(BuildContext ctx, _RenderLiquidGlassGroup rb) {
    final route = ModalRoute.of(ctx);
    if (route != null) {
      rb.setRepaintSources(
        primary: route.animation, // this route’s own movement
        secondary: route.secondaryAnimation, // movement of any route above
      );
    }
  }

  @override
  void didUnmountRenderObject(_RenderLiquidGlassGroup rb) {
    rb.detachRepaintSources();
  }
}

/// The core render object that handles the liquid glass effect.
///
/// This is where the magic happens:
/// 1. Collects geometry data from all LiquidGlass children in the widget tree
/// 2. Converts the geometry to shader uniforms (GPU-readable parameters)
/// 3. Applies the fragment shader as a backdrop filter to create the glass effect
///
/// The shader receives information about up to 4 glass shapes and renders them
/// with realistic refraction, blur, and lighting effects.
class _RenderLiquidGlassGroup extends RenderProxyBox {
  static const int maxRects = 4; // Maximum number of glass shapes supported

  Animation<double>? _primary;
  Animation<double>? _secondary;
  ScrollPosition? _scrollPosition;

  _RenderLiquidGlassGroup(
      {required double devicePixelRatio,
      required FragmentShader shader,
      required OCLiquidGlassSettings settings,
      ScrollPosition? position})
      : _devicePixelRatio = devicePixelRatio,
        _shader = shader,
        _settings = settings,
        _scrollPosition = position {
    _scrollPosition?.addListener(_onScroll);
  }

  // ── scroll binding ──
  set scrollPosition(ScrollPosition? value) {
    if (value == _scrollPosition) return;
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = value;
    _scrollPosition?.addListener(_onScroll);
    markNeedsPaint();
  }

  void _onScroll() => markNeedsPaint();

  // Device pixel ratio for proper scaling on high-DPI displays
  double _devicePixelRatio;
  set devicePixelRatio(double v) {
    if (_devicePixelRatio == v) return;
    _devicePixelRatio = v;
    markNeedsPaint(); // Trigger repaint when DPI changes
  }

  // Visual settings for the shader effect
  OCLiquidGlassSettings _settings;
  set settings(OCLiquidGlassSettings v) {
    _settings = v;
    markNeedsPaint(); // Trigger repaint when settings change
  }

  final FragmentShader _shader;                        // The compiled shader program
  final Set<RenderLiquidGlass> registeredShapes = {};  // All glass shapes in the widget tree

  // Called by the widget whenever the route hierarchy may have changed
  void setRepaintSources({
    Animation<double>? primary,
    Animation<double>? secondary,
  }) {
    if (_primary != primary) {
      _primary?.removeListener(markNeedsPaint);
      _primary = primary?..addListener(markNeedsPaint);
    }
    if (_secondary != secondary) {
      _secondary?.removeListener(markNeedsPaint);
      _secondary = secondary?..addListener(markNeedsPaint);
    }
  }

  // Clean-up when the render object leaves the tree
  void detachRepaintSources() {
    _primary?.removeListener(markNeedsPaint);
    _secondary?.removeListener(markNeedsPaint);
    _primary = _secondary = null;
    _scrollPosition?.removeListener(_onScroll);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    markNeedsPaint();
  }

  @override
  void detach() {
    detachRepaintSources();
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // STEP 1: Collect geometry data from all registered glass shapes
    final shapes = <ShapeData>[];
    for (var shape in registeredShapes) {
      // Skip shapes that aren't properly attached or have no size
      if (!shape.attached || shape.size.isEmpty) continue;
      
      // Transform shape coordinates to screen space
      final transform = shape.getTransformTo(null);
      final rect = MatrixUtils.transformRect(
        transform,
        Offset.zero & shape.size,
      );
      
      // Clamp border radius to maximum of half the smaller dimension
      final maxRadius = (rect.size.width < rect.size.height 
          ? rect.size.width 
          : rect.size.height) / 2;
      final clampedRadius = shape.borderRadius > maxRadius 
          ? maxRadius 
          : shape.borderRadius;

      shapes.add(ShapeData(rect.center, rect.size, clampedRadius, shape.color));
    }

    // If no shapes are registered, skip rendering
    if (!ImageFilter.isShaderFilterSupported || shapes.isEmpty) {
      super.paint(context, offset);
      return;
    }

    // Calculate boudary of current render object
    final boundaryTransform = getTransformTo(null);
    final boundary = MatrixUtils.transformRect(
      boundaryTransform,
      Offset.zero & size,
    );

    // STEP 2: Configure shader uniforms (parameters passed to GPU)
    // final biggestSize = constraints.biggest;
    // final w = biggestSize.width * _devicePixelRatio;   // Screen width in physical pixels
    // final h = biggestSize.height * _devicePixelRatio;  // Screen height in physical pixels
    final sh = _shader;

    var idx = 2;

    // Global shader parameters
    sh
      // ..setFloat(idx++, 0.0)
      // ..setFloat(idx++, w)                          // Screen width
      // ..setFloat(idx++, h)                          // Screen height

      // boundary
      ..setFloat(idx++, boundary.left * _devicePixelRatio) // Min X in physical pixels
      ..setFloat(idx++, boundary.top * _devicePixelRatio) // Min Y in physical pixels
      ..setFloat(idx++, boundary.right * _devicePixelRatio) // Max X in physical pixels
      ..setFloat(idx++, boundary.bottom * _devicePixelRatio) // Max Y in physical pixels
      
      // Blend & refraction parameters
      ..setFloat(idx++, _settings.blendPx * _devicePixelRatio)      // Edge blending
      ..setFloat(idx++, _settings.refractStrength)                  // Refraction strength
      ..setFloat(idx++, _settings.distortFalloffPx * _devicePixelRatio) // Distortion falloff
      ..setFloat(idx++, _settings.distortExponent)                  // Distortion curve
      
      // Frosted glass blur parameters
      ..setFloat(idx++, _settings.blurRadiusPx * _devicePixelRatio) // Base blur
      
      // Specular highlight parameters (shiny reflections)
      ..setFloat(idx++, _settings.specAngle)       // specular light angle
      ..setFloat(idx++, _settings.specStrength)    // specular strength
      ..setFloat(idx++, _settings.specPower)       // specular power
      ..setFloat(idx++, _settings.specWidth * _devicePixelRatio)       // specular width
      
      // Light band parameters (bright streak across glass surface)
      ..setFloat(idx++, _settings.lightbandOffsetPx * _devicePixelRatio)  // Distance from edge
      ..setFloat(idx++, _settings.lightbandWidthPx * _devicePixelRatio)   // Band width
      ..setFloat(idx++, _settings.lightbandStrength)                     // Band intensity
      ..setFloat(idx++, _settings.lightbandColor.r)              // Band red
      ..setFloat(idx++, _settings.lightbandColor.g)              // Band green
      ..setFloat(idx++, _settings.lightbandColor.b)              // Band blue
      
      // Anti-aliasing and shape count
      ..setFloat(idx++, 1.0 * _devicePixelRatio) // 1px anti-aliasing
      ..setFloat(idx++, shapes.length.toDouble()); // Number of shapes

    // STEP 3: Pass individual shape data to shader (max 4 shapes supported)
    for (var i = 0; i < shapes.length && i < maxRects; i++) {
      final s = shapes[i];
      sh
        ..setFloat(idx++, s.center.dx * _devicePixelRatio)    // Center X
        ..setFloat(idx++, s.center.dy * _devicePixelRatio)    // Center Y
        ..setFloat(idx++, s.size.width * _devicePixelRatio)   // Width
        ..setFloat(idx++, s.size.height * _devicePixelRatio)  // Height
        ..setFloat(idx++, s.borderRadius * _devicePixelRatio)// Borner radius
        ..setFloat(idx++, s.color.r) // Color red
        ..setFloat(idx++, s.color.g) // Color green
        ..setFloat(idx++, s.color.b) // Color blue
        ..setFloat(idx++, s.color.a) // Color alpha
        ;
    }

    // STEP 4: Apply the shader as a backdrop filter
    // This creates a layer that processes the background through the shader
    context.pushLayer(
      BackdropFilterLayer(
        filter: ImageFilter.shader(sh), // Apply our glass shader
      ),
      super.paint,
      offset,
    );

    // if (child != null) {
    //   context.paintChild(child!, offset);
    // }
    // super.paint(context, offset);

    // final Rect bounds = Offset.zero & size;
    // context.pushClipRRect(
    //   needsCompositing,
    //   offset,
    //   bounds,
    //   BorderRadius.circular(100).toRRect(bounds),
    //   (PaintingContext ctx, Offset ofs) {
    //     // ② Filter layer sits *inside* the clip.
    //     ctx.pushLayer(
    //       BackdropFilterLayer(
    //         filter: ImageFilter.shader(sh),
    //       ),
    //       super.paint,
    //       ofs,
    //     );
    //   },
    //   clipBehavior: Clip.antiAlias,
    // );
  }
}

/// Widget that wraps any child to make it appear as a liquid glass droplet.
///
/// This is the user-facing widget - simply wrap any widget with LiquidGlass
/// and it will get the glass effect applied to it. The widget must be inside
/// a LiquidGlassGroup to work properly.
///
/// The borderRadius parameter controls how rounded the glass shape appears.
/// Note: The radius is automatically clamped to half of the smaller dimension
/// (min(width/2, height/2)) to ensure valid geometry.
/// The enabled parameter allows you to turn the glass effect on/off.
class OCLiquidGlass extends SingleChildRenderObjectWidget {
  final bool enabled;

  final double? width;
  final double? height;

  final Color color;
  final double borderRadius;
  final BoxShadow? shadow;
  
  const OCLiquidGlass({
    super.key,
    this.enabled = true,

    this.width,
    this.height,

    this.color = Colors.transparent,
    this.borderRadius = 0.0,
    this.shadow,

    super.child
  });

  @override
  createRenderObject(BuildContext context) =>
      RenderLiquidGlass(enabled, borderRadius, color);

  @override
  void updateRenderObject(BuildContext context, RenderLiquidGlass renderObject) {
    renderObject
      ..enabled = enabled
      ..color = color
      ..borderRadius = borderRadius;
  }

  @override
  Widget? get child {
    // Adjust the shadow offset if the background is translucent.
    final shadow = this.shadow != null
        ? this.shadow?.copyWith(
              blurStyle: BlurStyle.outer,
              offset: const Offset(0, 0),
            )
        : this.shadow;

    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadow != null ? [shadow] : null,
        ),
        child: super.child);
  }
}

/// The render object for individual glass shapes.
///
/// This render object:
/// 1. Automatically registers itself with the parent LiquidGlassLayer when attached
/// 2. Provides its geometry (size, position, border radius) to the shader system
/// 3. Unregisters itself when removed from the widget tree
/// 4. Can be enabled/disabled to control whether the glass effect is applied
///
/// It acts as a proxy box, meaning it doesn't change the layout of its child.
class RenderLiquidGlass extends RenderProxyBox {
  bool _enabled;
  double _borderRadius;
  Color _color;

  RenderLiquidGlass(this._enabled, this._borderRadius, this._color);

  /// Whether the glass effect is enabled for this shape
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    
    // Update registration based on enabled state
    final layer = _findLayer();
    if (layer != null) {
      if (_enabled) {
        layer.registeredShapes.add(this);
      } else {
        layer.registeredShapes.remove(this);
      }
      layer.markNeedsPaint(); // Trigger repaint when state changes
    }
  }

  double get borderRadius => _borderRadius;
  set borderRadius(double value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // Register this shape with the parent glass layer only if enabled
    if (_enabled) {
      _findLayer()?.registeredShapes.add(this);
    }
  }

  @override
  void detach() {
    // Unregister this shape when removed from tree
    _findLayer()?.registeredShapes.remove(this);
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => _enabled;

  /// Searches up the render tree to find the LiquidGlassLayer that manages the shader.
  /// This allows individual glass shapes to register themselves with the system.
  _RenderLiquidGlassGroup? _findLayer() {
    var pr = parent;
    while (pr != null && pr is! _RenderLiquidGlassGroup) {
      pr = pr.parent; // Walk up the render tree
    }
    return pr as _RenderLiquidGlassGroup?;
  }
}
