// SVG -> padded PNG rasterizer used to build the launcher icons.
//
// Run with:  flutter test tool/generate_app_icons_test.dart
//
// The brand SVGs have no internal padding/margin, so they cannot be used
// directly as an app icon. This tool renders each SVG, finds the tight
// opaque bounding box, and re-centres it with a safe margin on top of the
// correct background:
//   * LTBG (dark mark)  -> light backgrounds
//   * DTBG (light mark) -> dark backgrounds
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

const int _size = 1024;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate app icons from SVG', () async {
    final outDir = Directory('tool/icon_src')..createSync(recursive: true);

    final ltbg = await _load('assets/logo/Raqim_Logo_LTBG.svg');
    final dtbg = await _load('assets/logo/Raqim_Logo_DTBG.svg');

    // Standard (opaque) icons: light bg + dark mark, dark bg + light mark.
    // Content fraction controls the safe margin (~20% for a 0.60 fraction).
    await _writePadded(outDir, 'app_icon_light.png', ltbg, 0.60,
        const Color(0xFFFFFFFF));
    await _writePadded(outDir, 'app_icon_dark.png', dtbg, 0.60,
        const Color(0xFF004C69));

    // Adaptive foregrounds (transparent), sized for the Android safe zone
    // (Android also zooms the icon on the splash screen, so keep extra margin).
    await _writePadded(outDir, 'app_icon_light_fg.png', ltbg, 0.46, null);
    await _writePadded(outDir, 'app_icon_dark_fg.png', dtbg, 0.46, null);

    stdout.writeln('done');
  });
}

class _Loaded {
  _Loaded(this.picture, this.size, this.bbox);

  final ui.Picture picture;
  final ui.Size size;
  final ui.Rect bbox;
}

Future<_Loaded> _load(String path) async {
  final svgString = File(path).readAsStringSync();
  final info = await vg.loadPicture(SvgStringLoader(svgString), null);
  final width = info.size.width.isFinite && info.size.width > 0
      ? info.size.width
      : 2000.0;
  final height = info.size.height.isFinite && info.size.height > 0
      ? info.size.height
      : 2000.0;
  final probe = await _render(
    info.picture,
    1.0,
    width.round(),
    height.round(),
    null,
  );
  final bbox = await _alphaBBox(probe);
  stdout.writeln('$path  size=${info.size}  bbox=$bbox');
  return _Loaded(info.picture, ui.Size(width, height), bbox);
}

Future<ui.Image> _render(
  ui.Picture picture,
  double scale,
  int outW,
  int outH,
  Color? background,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (background != null) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
      Paint()..color = background,
    );
  }
  canvas.scale(scale);
  canvas.drawPicture(picture);
  return recorder.endRecording().toImage(outW, outH);
}

Future<ui.Rect> _alphaBBox(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final bytes = data!.buffer.asUint8List();
  final w = image.width;
  final h = image.height;
  var minX = w;
  var minY = h;
  var maxX = -1;
  var maxY = -1;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (bytes[(y * w + x) * 4 + 3] > 16) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0) {
    return ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble());
  }
  return ui.Rect.fromLTRB(
    minX.toDouble(),
    minY.toDouble(),
    (maxX + 1).toDouble(),
    (maxY + 1).toDouble(),
  );
}

Future<void> _writePadded(
  Directory dir,
  String name,
  _Loaded loaded,
  double fraction,
  Color? background,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (background != null) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _size.toDouble(), _size.toDouble()),
      Paint()..color = background,
    );
  }
  final bbox = loaded.bbox;
  final content = _size * fraction;
  final scale = content / math.max(bbox.width, bbox.height);
  final dw = bbox.width * scale;
  final dh = bbox.height * scale;
  canvas.save();
  canvas.translate((_size - dw) / 2, (_size - dh) / 2);
  canvas.scale(scale);
  canvas.translate(-bbox.left, -bbox.top);
  canvas.drawPicture(loaded.picture);
  canvas.restore();

  final image = await recorder.endRecording().toImage(_size, _size);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File('${dir.path}/$name').writeAsBytesSync(png!.buffer.asUint8List());
  stdout.writeln('wrote ${dir.path}/$name');
}
