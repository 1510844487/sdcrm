import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/GlobalConst/SDColor.dart';
import 'package:fluttercrmmodule/pages/bean/TrendModel.dart';

class SDChartWidget extends StatelessWidget {
  const SDChartWidget({this.isShowingMainData});

  final bool? isShowingMainData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  AxisTitles get bottomTitles => AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 22,
        interval: 1,
        getTitlesWidget: (double value, TitleMeta meta) {
          String title = "";
          switch (value.toInt()) {
            case 2:
              title = 'SEPT';
              break;
            case 7:
              title = 'OCT';
              break;
            case 12:
              title = 'DEC';
              break;
          }

          return Text(title,
              style: TextStyle(
                color: Color(0xff72719b),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ));
        },
      ));

  FlGridData get gridData => FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 4),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );
}

class LineChartSample2 extends StatelessWidget {
  List<TrendModelList>? max;
  List<FlSpot> jdDotToday = [];
  List<FlSpot> jdDot8Weeks = [];

  bool showAvg = false;

  double maxYY = 0;
  double maxXX = 0;

  LineChartSample2(List<TrendModelList>? jdToday, List<TrendModelList>? jd8Weeks) {
    double jdSize = jdToday == null ? 0.toDouble() : jdToday.length.toDouble();
    double jd8Size = jd8Weeks == null ? 0.toDouble() : jd8Weeks.length.toDouble();
    double maxSize = jdSize > jd8Size ? jdSize : jd8Size;
    if (jdSize > jd8Size) {
      max = jdToday;
    } else {
      max = jd8Weeks;
    }
    maxXX = maxSize;
    maxXX = 24;
    for (int p = 0; p < maxSize.toInt(); p++) {
      TrendModelList todayTrend;
      double? todayValue;
      if (p < (jdToday?.length ?? 0)) {
        todayTrend = jdToday![p];

        print("todayTrend = ${todayTrend.toJson()}");

        todayValue = todayTrend.value.toDouble();
        jdDotToday.add(FlSpot(p.toDouble(), todayValue));
      }
      TrendModelList _8WeekTrend;
      double? _8WeekValue;
      if (p < (jd8Weeks?.length ?? 0)) {
        _8WeekTrend = jd8Weeks![p];

        print("_8WeekTrend = ${_8WeekTrend.toJson()}");

        _8WeekValue = _8WeekTrend.value.toDouble();
        jdDot8Weeks.add(FlSpot(p.toDouble(), _8WeekValue));
      }

      if (todayValue == null && _8WeekValue != null) {
        maxYY = maxYY > _8WeekValue ? maxYY : _8WeekValue;
      } else if (todayValue != null && _8WeekValue == null) {
        maxYY = maxYY > todayValue ? maxYY : todayValue;
      } else if (todayValue != null && _8WeekValue != null) {
        double maxTemp = todayValue > _8WeekValue ? todayValue : _8WeekValue;
        maxYY = maxYY > maxTemp ? maxYY : maxTemp;
      }
    }

    print("jdDotToday = ${jdDotToday.length},,, jdDot8Weeks = ${jdDot8Weeks.length}");

    if (jdToday == null && jd8Weeks == null) {
      maxYY = 0;
      maxXX = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: AspectRatio(
        aspectRatio: 660 / 280.toDouble(),
        child: LineChart(
          mainData(),
        ),
      ),
    );
  }

  Color _defaultGetDotColor(FlSpot _, double xPercentage, LineChartBarData bar) {
    if (bar.color == null) {
      throw ArgumentError('"colors" is empty.');
    } else {
      return bar.color!;
    }
  }

  Map dateSet = {0: "00:00", 8: "08:00", 16: "16:00", 24: "24:00"};

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: touchedSpot.bar.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                return LineTooltipItem(touchedSpot.y.toInt().toString(), textStyle);
              }).toList();
            }),
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((e) {
            return TouchedSpotIndicatorData(
              VerticalLine(
                color: Color(0xFF0071FE),
                strokeWidth: 1,
                dashArray: [5, 6],
                x: 0,
              ),
              FlDotData(getDotPainter: (FlSpot spot, double xPercentage, LineChartBarData bar, int index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: _defaultGetDotColor(spot, xPercentage, bar),
                  strokeWidth: 0,
                );
              }),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return HorizontalLine(
            y: 0,
            color: const Color(0xFFC0C0C0),
            strokeWidth: 1,
            dashArray: [5, 6],
            label: HorizontalLineLabel(
              show: false,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.normal),
              labelResolver: (line) => 'H: ${line.y}',
            ),
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: 1,
          getTitlesWidget: (double value, TitleMeta meta) {
            String title = "";
            if (dateSet.containsKey(value.toInt())) {
              title = dateSet[value.toInt()];
            }
            return Container(
              margin: EdgeInsets.only(top: 2),
              child: Text(
                title,
                style: TextStyle(color: Color(0xFFC0C0C0), fontWeight: FontWeight.normal, fontSize: 10),
              ),
            );
          },
        )),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            return Text(
              meta.formattedValue,
              style: TextStyle(
                color: Color(0xFFC0C0C0),
                fontWeight: FontWeight.normal,
                fontSize: 10,
              ),
            );
          },
          reservedSize: 20,
        )),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white, width: 1)),
      minX: 0,
      maxX: maxXX,
      minY: 0,
      maxY: maxYY,
      lineBarsData: [
        LineChartBarData(
          spots: jdDotToday,
          isCurved: false,
          color: Color(0xFF0071FE),
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Color(0x1A0071FE),
          ),
        ),
        LineChartBarData(
          spots: jdDot8Weeks,
          isCurved: false,
          color: SDColor.orange,
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
