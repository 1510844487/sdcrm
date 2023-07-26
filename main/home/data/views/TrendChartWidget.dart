import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:fluttercrmmodule/pages/bean/Statistics.dart';

class TrendChartWidget extends StatelessWidget {
  List<CaseTrendList>? caseTrendList;
  List<Point> points = [];
  Color? paintColor;
  double width = 72.0;
  double height = 30;

  TrendChartWidget({this.caseTrendList, this.paintColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: TrendChartWidgetPaint(
        caseTrendList: caseTrendList,
        paintColor: paintColor,
        width: width,
        height: height,
      ),
    );
  }
}

class TrendChartWidgetPaint extends CustomPainter {
  List<CaseTrendList>? caseTrendList;
  List<Point<double>> points = [];
  Color? paintColor;
  double width;
  double height;

  TrendChartWidgetPaint(
      {this.caseTrendList, this.paintColor, required this.width, required this.height}) {
    if (paintColor == null) {
      paintColor = Color(0xFF0071FE);
    }
    if (caseTrendList == null || caseTrendList!.length <= 0) {
      return;
    }
    double stepX = width / (caseTrendList!.length - 1);
    int maxY = 0;
    for (CaseTrendList caseTrend in caseTrendList!) {
      if (maxY < caseTrend.caseCnt) {
        maxY = caseTrend.caseCnt;
      }
    }
    double ratioY = maxY == 0 ? 0 : height / maxY;
    for (int p = 0; p < caseTrendList!.length; p++) {
      CaseTrendList caseTrend = caseTrendList![p];
      double x = stepX * p;
      double y = height - ratioY * caseTrend.caseCnt;
      points.add(Point(x, y));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points == null || points.length <= 0) {
      return;
    }
    Paint mainPaint = Paint()
      ..strokeWidth = 3
      ..color = paintColor!
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Path mainPath = Path();
    bool isFirst = true;
    for (Point<double> point in points) {
      if (isFirst) {
        isFirst = false;
        mainPath.moveTo(point.x, point.y);
      } else {
        mainPath.lineTo(point.x, point.y);
      }
    }
    canvas.drawPath(mainPath, mainPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
