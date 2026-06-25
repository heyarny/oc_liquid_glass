# OneClient Liquid Glass

A Flutter package for creating stunning liquid glass droplet effects with realistic refraction, blur, and lighting. Built with GPU-accelerated fragment shaders for smooth performance.

## Features

- 🚀 **No Dependencies**: Pure Flutter implementation with zero external dependencies
- 🌟 **Realistic Glass Effects**: Refraction, blur, and specular highlights
- ⚡ **GPU Accelerated**: Fragment shader-based rendering for optimal performance
- 🎨 **Highly Customizable**: Fine-tune all visual parameters
- 🎨 **Individual Colors**: Set unique colors for each liquid glass in a group
- 📱 **Production Ready**: Smooth animations and responsive design
- � **Scrollable Support**: Supported when used inside scrollable widgets
- 🎭 **Modal Route Animation**: Supported when used in modal route animations
- �🔧 **Easy Integration**: Simple widget-based API
- 🔢 **Unlimited Droplets**: Create as many droplets as you want (performance degrades with the amount of effects)


## Limitations

- Works only on platforms that support Impeller engine
- Grouped shapes are limited to 4 shapes within one group


## Preview

![Liquid Glass Demo](https://raw.githubusercontent.com/heyarny/oc_liquid_glass/refs/heads/main/screenshots/demo.gif)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  oc_liquid_glass: ^0.2.2
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

Wrap your content with `OCLiquidGlassGroup` and add `OCLiquidGlass` widgets for glass effects:

```dart
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

Stack(
  children: [
    // Your background content
    Image.asset('assets/background.jpg'),
    
    // Glass layer with droplets
    OCLiquidGlassGroup(
      settings: const OCLiquidGlassSettings(),
      child: Stack(
        children: [
          Positioned(
            top: 100,
            left: 50,
            child: OCLiquidGlass(
              width: 120,
              height: 80,
              borderRadius: 40,
              child: Container(),
            ),
          ),
        ],
      ),
    ),
  ],
)
```

### Precaching the Shader

The shader loads asynchronously the first time an `OCLiquidGlassGroup` appears.
For transient UI such as toasts, dialogs, or bottom sheets, preload it before the
first glass widget is shown:

```dart
@override
void initState() {
  super.initState();
  OCLiquidGlassGroup.precacheShader();
}
```

### Advanced Configuration

Customize the glass appearance with `OCLiquidGlassSettings`:

```dart
Stack(
  children: [
    // Your background content
    Image.asset('assets/background.jpg'),
    
    // Glass layer with custom settings
    OCLiquidGlassGroup(
      settings: const OCLiquidGlassSettings(
        refractStrength: -0.08,     // Stronger refraction
        blurRadiusPx: 2.0,         // Add frosted glass blur
        specStrength: 25.0,        // Brighter reflections
        lightbandColor: Colors.cyan, // Colored light band
      ),
      child: OCLiquidGlass(
        width: 120,
        height: 80,
        borderRadius: 40,
        child: Container(),
      ),
    ),
  ],
)
```

## Configuration Reference

### OCLiquidGlassSettings Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `blendPx` | `double` | Edge blending distance in pixels for smooth transitions |
| `refractStrength` | `double` | Strength of light refraction (negative = concave lens) |
| `distortFalloffPx` | `double` | Distance over which distortion effect fades out |
| `distortExponent` | `double` | Controls how sharply distortion falls off (higher = sharper) |
| `blurRadiusPx` | `double` | Base blur radius applied to the glass area |
| `specAngle` | `double` | Light source angle for specular highlights |
| `specStrength` | `double` | Intensity of specular highlights |
| `specPower` | `double` | Sharpness of specular highlights (higher = sharper) |
| `specWidth` | `double` | Specular width in pixels |
| `lightbandOffsetPx` | `double` | Distance from edge where light band appears |
| `lightbandWidthPx` | `double` | Width of the light band effect |
| `lightbandStrength` | `double` | Intensity of the light band |
| `lightbandColor` | `Color` | Color of the light band |

### OCLiquidGlass Widget Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | `bool` | Whether the glass effect is enabled |
| `width` | `double?` | Width of the glass shape |
| `height` | `double?` | Height of the glass shape |
| `color` | `Color` | Tint color for the glass shape |
| `borderRadius` | `double` | Border radius (clamped to half of smaller dimension) |
| `shadow` | `BoxShadow?` | Optional shadow effect |
| `child` | `Widget?` | Child widget to display inside the glass |

### Multiple Glass Droplets Example

Create multiple glass effects with different colors and sizes:

```dart
Stack(
  children: [
    // Background
    Container(
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
    ),
    
    // Glass layer with multiple droplets
    OCLiquidGlassGroup(
      settings: const OCLiquidGlassSettings(
        refractStrength: -0.08,
        blurRadiusPx: 1.5,
        specStrength: 15.0,
        lightbandColor: Colors.white70,
      ),
      child: Stack(
        children: [
          // Large amber droplet
          Positioned(
            top: 100,
            left: 50,
            child: OCLiquidGlass(
              width: 200,
              height: 120,
              borderRadius: 60,
              color: Colors.amber.withOpacity(0.3),
              child: const SizedBox(),
            ),
          ),
          
          // Medium blue droplet
          Positioned(
            top: 250,
            left: 300,
            child: OCLiquidGlass(
              width: 150,
              height: 100,
              borderRadius: 50,
              color: Colors.blue.withOpacity(0.2),
              child: const SizedBox(),
            ),
          ),
          
          // Small pink droplet
          Positioned(
            top: 180,
            left: 200,
            child: OCLiquidGlass(
              width: 80,
              height: 60,
              borderRadius: 30,
              color: Colors.pink.withOpacity(0.25),
              child: const SizedBox(),
            ),
          ),
          
          // Tiny green droplet
          Positioned(
            top: 320,
            left: 150,
            child: OCLiquidGlass(
              width: 60,
              height: 40,
              borderRadius: 20,
              color: Colors.green.withOpacity(0.2),
              child: const SizedBox(),
            ),
          ),
        ],
      ),
    ),
  ],
)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.
