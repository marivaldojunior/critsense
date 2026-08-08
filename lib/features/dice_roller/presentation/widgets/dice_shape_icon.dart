import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

/// Desenha a silhueta geométrica aproximada do sólido de cada [DiceType],
/// para que o seletor de pool seja reconhecível pelo formato do dado, não
/// só pelo rótulo numérico:
/// - d4 → tetraedro (pirâmide de base triangular)
/// - d6 → hexaedro regular (cubo)
/// - d8 → octaedro (duas pirâmides de base triangular unidas pela base)
/// - d10 / d100 → trapezoedro pentagonal (formato de pipa alongada)
/// - d12 → dodecaedro regular (faces pentagonais)
/// - d20 → icosaedro regular (faces triangulares)
///
/// É uma projeção 2D simplificada (contorno + arestas internas sugerindo
/// as faces ocultas), não uma renderização 3D real.
class DiceShapeIcon extends StatelessWidget {
  const DiceShapeIcon({
    super.key,
    required this.type,
    required this.color,
    this.fillColor,
    this.size = 40,
  });

  final DiceType type;
  final Color color;
  final Color? fillColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiceShapePainter(
          type: type,
          strokeColor: color,
          fillColor: fillColor,
        ),
      ),
    );
  }
}

class _DiceShapePainter extends CustomPainter {
  _DiceShapePainter({
    required this.type,
    required this.strokeColor,
    this.fillColor,
  });

  final DiceType type;
  final Color strokeColor;
  final Color? fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final outerStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.06
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final innerStroke = Paint()
      ..color = strokeColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.035
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case DiceType.d4:
        _paintTetrahedron(canvas, size, outerStroke, innerStroke);
        break;
      case DiceType.d6:
        _paintCube(canvas, size, outerStroke, innerStroke);
        break;
      case DiceType.d8:
        _paintOctahedron(canvas, size, outerStroke, innerStroke);
        break;
      case DiceType.d10:
      case DiceType.d100:
        _paintPentagonalTrapezohedron(canvas, size, outerStroke, innerStroke);
        break;
      case DiceType.d12:
        _paintDodecahedron(canvas, size, outerStroke);
        break;
      case DiceType.d20:
        _paintIcosahedron(canvas, size, outerStroke, innerStroke);
        break;
    }
  }

  void _fillAndStroke(Canvas canvas, Path path, Paint outerStroke) {
    if (fillColor != null) {
      canvas.drawPath(path, Paint()..color = fillColor!);
    }
    canvas.drawPath(path, outerStroke);
  }

  /// Triângulo com as três arestas ocultas convergindo para o vértice de
  /// trás — leitura clássica de um tetraedro em 2D.
  void _paintTetrahedron(
    Canvas canvas,
    Size size,
    Paint outerStroke,
    Paint innerStroke,
  ) {
    final w = size.width;
    final h = size.height;
    final top = Offset(w * 0.5, h * 0.08);
    final bottomLeft = Offset(w * 0.08, h * 0.92);
    final bottomRight = Offset(w * 0.92, h * 0.92);
    final hiddenApex = Offset(w * 0.5, h * 0.62);

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    _fillAndStroke(canvas, path, outerStroke);
    canvas.drawLine(top, hiddenApex, innerStroke);
    canvas.drawLine(bottomLeft, hiddenApex, innerStroke);
    canvas.drawLine(bottomRight, hiddenApex, innerStroke);
  }

  /// Cubo isométrico (cubo de Necker): hexágono regular dividido em três
  /// losangos por linhas do centro às pontas alternadas — as três faces
  /// visíveis de um cubo visto pelo canto.
  void _paintCube(
    Canvas canvas,
    Size size,
    Paint outerStroke,
    Paint innerStroke,
  ) {
    final center = Offset(size.width * 0.5, size.height * 0.52);
    final radius = size.shortestSide * 0.46;
    final vertices = _regularPolygonVertices(center, radius, 6);

    final outline = Path()..addPolygon(vertices, true);
    _fillAndStroke(canvas, outline, outerStroke);
    for (var i = 0; i < vertices.length; i += 2) {
      canvas.drawLine(center, vertices[i], innerStroke);
    }
  }

  /// Losango com a "linha do equador" onde as duas pirâmides de base
  /// triangular do octaedro se unem.
  void _paintOctahedron(
    Canvas canvas,
    Size size,
    Paint outerStroke,
    Paint innerStroke,
  ) {
    final w = size.width;
    final h = size.height;
    final top = Offset(w * 0.5, h * 0.06);
    final right = Offset(w * 0.94, h * 0.5);
    final bottom = Offset(w * 0.5, h * 0.94);
    final left = Offset(w * 0.06, h * 0.5);

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    _fillAndStroke(canvas, path, outerStroke);
    canvas.drawLine(left, right, innerStroke);
  }

  /// Pipa alongada com as facetas em ziguezague típicas do trapezoedro
  /// pentagonal (dado usado tanto para d10 quanto para d100).
  void _paintPentagonalTrapezohedron(
    Canvas canvas,
    Size size,
    Paint outerStroke,
    Paint innerStroke,
  ) {
    final w = size.width;
    final h = size.height;
    final top = Offset(w * 0.5, h * 0.04);
    final upperRight = Offset(w * 0.88, h * 0.34);
    final lowerRight = Offset(w * 0.7, h * 0.78);
    final bottom = Offset(w * 0.5, h * 0.96);
    final lowerLeft = Offset(w * 0.3, h * 0.78);
    final upperLeft = Offset(w * 0.12, h * 0.34);

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(upperRight.dx, upperRight.dy)
      ..lineTo(lowerRight.dx, lowerRight.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(lowerLeft.dx, lowerLeft.dy)
      ..lineTo(upperLeft.dx, upperLeft.dy)
      ..close();

    _fillAndStroke(canvas, path, outerStroke);
    canvas.drawLine(top, lowerLeft, innerStroke);
    canvas.drawLine(top, lowerRight, innerStroke);
    canvas.drawLine(bottom, upperLeft, innerStroke);
    canvas.drawLine(bottom, upperRight, innerStroke);
  }

  /// Pentágono regular — uma das doze faces do dodecaedro.
  void _paintDodecahedron(Canvas canvas, Size size, Paint outerStroke) {
    final center = Offset(size.width * 0.5, size.height * 0.52);
    final radius = size.shortestSide * 0.46;
    final path = _regularPolygonPath(center, radius, 5);
    _fillAndStroke(canvas, path, outerStroke);
  }

  /// Hexágono com as seis arestas do centro às pontas, sugerindo as faces
  /// triangulares visíveis de um icosaedro.
  void _paintIcosahedron(
    Canvas canvas,
    Size size,
    Paint outerStroke,
    Paint innerStroke,
  ) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.shortestSide * 0.46;
    final vertices = _regularPolygonVertices(center, radius, 6);

    final path = Path()..addPolygon(vertices, true);
    _fillAndStroke(canvas, path, outerStroke);
    for (final vertex in vertices) {
      canvas.drawLine(center, vertex, innerStroke);
    }
  }

  List<Offset> _regularPolygonVertices(
    Offset center,
    double radius,
    int sides,
  ) {
    final step = 2 * math.pi / sides;
    // Começa apontando para cima (-90°) para as formas ficarem eretas.
    const startAngle = -math.pi / 2;
    return [
      for (var i = 0; i < sides; i++)
        center +
            Offset(
              radius * math.cos(startAngle + step * i),
              radius * math.sin(startAngle + step * i),
            ),
    ];
  }

  Path _regularPolygonPath(Offset center, double radius, int sides) {
    return Path()
      ..addPolygon(_regularPolygonVertices(center, radius, sides), true);
  }

  @override
  bool shouldRepaint(covariant _DiceShapePainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor;
  }
}
