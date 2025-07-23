# OneClient Liquid Glass

A Flutter package for creating stunning liquid glass droplet effects with realistic refraction, blur, and lighting. Built with GPU-accelerated fragment shaders for smooth performance.

## Features

- 🚀 **No Dependencies**: Pure Flutter implementation with zero external dependencies
- 🌟 **Realistic Glass Effects**: Refraction, blur, and specular highlights
- ⚡ **GPU Accelerated**: Fragment shader-based rendering for optimal performance
- 🎨 **Highly Customizable**: Fine-tune all visual parameters
- 🎨 **Individual Colors**: Set unique colors for each liquid glass in a group
- 📱 **Production Ready**: Smooth animations and responsive design
- 🔧 **Easy Integration**: Simple widget-based API

## Preview

![Liquid Glass Demo](https://raw.githubusercontent.com/heyarny/oc_liquid_glass/refs/heads/main/screenshots/demo.gif)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  oc_liquid_glass: ^0.1.0
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

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| `blendPx` | `double` | `5` | `0+` | Edge blending distance in pixels for smooth transitions |
| `refractStrength` | `double` | `-0.06` | `-1.0` to `1.0` | Strength of light refraction (negative = concave lens) |
| `distortFalloffPx` | `double` | `45` | `0+` | Distance over which distortion effect fades out |
| `distortExponent` | `double` | `4` | `1+` | Controls how sharply distortion falls off (higher = sharper) |
| `blurRadiusPx` | `double` | `0` | `0+` | Base blur radius applied to the glass area |
| `specAngle` | `double` | `4` | `0+` | Light source angle for specular highlights |
| `specStrength` | `double` | `20.0` | `0+` | Intensity of specular highlights |
| `specPower` | `double` | `100` | `1+` | Sharpness of specular highlights (higher = sharper) |
| `specWidth` | `double` | `10` | `0+` | Specular width in pixels |
| `lightbandOffsetPx` | `double` | `10` | `0+` | Distance from edge where light band appears |
| `lightbandWidthPx` | `double` | `30` | `0+` | Width of the light band effect |
| `lightbandStrength` | `double` | `0.9` | `0` to `1.0` | Intensity of the light band |
| `lightbandColor` | `Color` | `Colors.white` | Any color | Color of the light band |

### OCLiquidGlass Widget Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enabled` | `bool` | `true` | Whether the glass effect is enabled |
| `width` | `double?` | `null` | Width of the glass shape |
| `height` | `double?` | `null` | Height of the glass shape |
| `color` | `Color` | `Colors.transparent` | Tint color for the glass shape |
| `borderRadius` | `double` | `0.0` | Border radius (clamped to half of smaller dimension) |
| `shadow` | `BoxShadow?` | `null` | Optional shadow effect |
| `child` | `Widget?` | `null` | Child widget to display inside the glass |

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

## Performance Tips

- Limit to 4 glass shapes per group for optimal performance and limits in Flutters fragment shaders
- Use `enabled: false` to temporarily disable effects

## Fun Fact

This widget & shader was created and improved using AI: OpenAI (o3, o4-mini-high) and Claude Sonnet 4.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.
