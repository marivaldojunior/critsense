// Script manual, não um teste automatizado — por isso mora em tool/ (fora de
// test/), onde `flutter test` não o descobre nem o executa por padrão.
//
// Regenera `assets/app_icon.png` a partir de `assets/app_icon.svg`, usado
// pelo `flutter_launcher_icons` (ver pubspec.yaml) para gerar os ícones
// nativos do app. Rode manualmente sempre que o SVG do ícone mudar:
//
//   flutter test tool/generate_app_icon.dart
//
// (usa `flutter_test`/`testWidgets` como forma de rasterizar o SVG dentro
// do binding de widgets do Flutter — não é um teste no sentido de asserção).

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _renderSvgToPng(
  WidgetTester tester, {
  required String assetPath,
  required String outputPath,
  required double size,
}) async {
  tester.view.physicalSize = Size(size, size);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: Colors.transparent,
          child: SvgPicture.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.fill,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List pngBytes = byteData!.buffer.asUint8List();
  File(outputPath).writeAsBytesSync(pngBytes);
}

void main() {
  testWidgets('generate app_icon.png from app_icon.svg', (tester) async {
    await _renderSvgToPng(
      tester,
      assetPath: 'assets/app_icon.svg',
      outputPath: 'assets/app_icon.png',
      size: 1024,
    );
  });
}
