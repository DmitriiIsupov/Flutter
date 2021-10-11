import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Draws a line chart of six data points with overlaying data label of current value
/// Source from fl_chart example github:
/// https://github.com/imaNNeoFighT/fl_chart/blob/master/example/lib/line_chart/samples/line_chart_sample2.dart
class CustomLineChart extends StatelessWidget {
  final List<double> dataPoints;
  final List<Color> gradientColors;
  final String dataCaption;
  final String chartLabel;
  final double borderRadius;
  final Color backgroundColor;

  CustomLineChart({
    @required this.dataPoints,
    @required this.gradientColors,
    @required this.dataCaption,
    @required this.chartLabel,
    this.backgroundColor = const Color(0xff232d37),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius),
            ),
            color: backgroundColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius),
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {},
          child: Center(
            child: AutoSizeText(
              dataCaption,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w300,
                fontSize: 60,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: AutoSizeText(
              chartLabel,
              maxLines: 1,
              minFontSize: 10,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: SideTitles(
          showTitles: false,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '10k';
              case 3:
                return '30k';
              case 5:
                return '50k';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: 10,
      minY: dataPoints.reduce(min) - 8,
      maxY: dataPoints.reduce(max) + 8,
      lineBarsData: [
        LineChartBarData(
          spots: getLineData(),
          isCurved: true,
          colors: gradientColors,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  /// get data to make the line
  List<FlSpot> getLineData() {
    List<FlSpot> data = [];

    for (int i = 0; i < 6; i++) {
      if (dataPoints.asMap().containsKey(i)) {
        data.add(FlSpot(i * 2.0, dataPoints[i]));
      } else {
        data.add(FlSpot.nullSpot);
      }
    }

    return data;
  }
}
