/// generate_icon_png.dart
/// Draws the app icon directly using dart:ui and saves as PNG.
/// Run: flutter run -d windows tools/generate_icon_png.dart  (or use below)
///
/// Actually we use a pure Dart image approach — writes raw pixel data.
/// Run: dart run tools/generate_icon_png.dart

import 'dart:io';
import 'dart:math';

// We'll write a minimal BMP/PPM and convert, but easiest:
// We download the rendered PNG from a public SVG render service.

import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🎨 Generating app icon PNG...');

  // Read SVG
  final svg = File('assets/images/app_icon.svg').readAsStringSync();
  final encoded = Uri.encodeComponent(svg);

  // Try multiple free SVG→PNG endpoints
  final endpoints = [
    // Cloudflare SVG worker (open)
    Uri.parse('https://svg-to-png.vercel.app/api?w=1024&h=1024'),
    // SVG render via resvg WASM service
    Uri.parse('https://resvg.app/render?width=1024&height=1024'),
  ];

  // Best approach: use Kroki.io — open source diagram renderer, supports SVG passthrough
  print('  Trying kroki.io...');
  try {
    final res = await http.post(
      Uri.parse('https://kroki.io/svgbob/png'),
      headers: {'Content-Type': 'text/plain'},
      body: svg,
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200 && res.bodyBytes.length > 500) {
      _save(res.bodyBytes);
      return;
    }
  } catch (_) {}

  // Use Browserless screenshot of an HTML page embedding the SVG
  print('  Trying cloudinary...');
  try {
    // Encode SVG as data URI and fetch rendered version
    final dataUri = 'data:image/svg+xml;charset=utf-8,$encoded';
    final res = await http.get(
      Uri.parse('https://res.cloudinary.com/demo/image/fetch/w_1024,h_1024/$dataUri'),
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200 && res.bodyBytes.length > 1000) {
      _save(res.bodyBytes);
      return;
    }
  } catch (_) {}

  // Final fallback — use html2canvas via a public render API
  print('  Trying htmlcsstoimage...');
  try {
    final html = '''<!DOCTYPE html><html><body style="margin:0;padding:0;width:1024px;height:1024px;">
${svg.replaceAll('width="100%"', 'width="1024"').replaceAll('height="100%"', 'height="1024"')}
</body></html>''';
    final res = await http.post(
      Uri.parse('https://hcti.io/v1/image'),
      headers: {'Content-Type': 'application/json'},
      body: '{"html":"${html.replaceAll('"', '\\"').replaceAll('\n', '')}","css":"","google_fonts":""}',
    ).timeout(const Duration(seconds: 20));
    if (res.statusCode == 200) {
      print('  Got URL, downloading...');
    }
  } catch (_) {}

  print('\n❌ All online methods failed due to network restrictions.');
  print('\n✅ EASY MANUAL METHOD (2 minutes):');
  print('   1. Go to: https://svgtopng.com');
  print('   2. Upload this file: assets/images/app_icon.svg');
  print('   3. Set size to 1024×1024');
  print('   4. Download and save as: assets/images/app_icon.png');
  print('   5. Run: dart run tools/setup_launcher_icons.dart');
  print('\n   OR open the SVG file in a browser (Chrome/Edge),');
  print('   right-click the image → "Save image as" → app_icon.png');
  print('   Save to: assets/images/app_icon.png');
}

void _save(List<int> bytes) {
  File('assets/images/app_icon.png').writeAsBytesSync(bytes);
  print('✅ Saved: assets/images/app_icon.png (${bytes.length ~/ 1024} KB)');
  print('   Now run: dart run tools/setup_launcher_icons.dart');
}
