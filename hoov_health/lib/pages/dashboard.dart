import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../dashboard/overall_health_widget.dart';
import '../dashboard/metric_health_widget.dart';
import '../backend/state.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData(1, 35),
      ChartData(2, 23),
      ChartData(3, 34),
      ChartData(4, 25),
      ChartData(5, 40),
    ];

    return Consumer<StateModel>(
      builder: (context, stateModel, child) {
        var metricsMap = stateModel.metricsMap;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Summary",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Flexible(
                                      child: SfCartesianChart(
                                        enableSideBySideSeriesPlacement: false,
                                        series: <CartesianSeries<ChartData, int>>[
                                          ColumnSeries<ChartData, int>(
                                            dataSource: chartData,
                                            xValueMapper: (ChartData data, _) => data.x,
                                            yValueMapper: (ChartData data, _) => data.y,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            const Expanded(
                              child: OverallHealthWidget(
                                score: 69,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            for (var entry in metricsMap.entries) ...[
                              Expanded(
                                child: MetricHealthWidget(
                                  title: entry.value.title,
                                  icon: entry.value.icon,
                                  color: entry.value.mainColor,
                                  score: entry.value.title == 'Wifi Health' 
                                      ? stateModel.wifiHealthScore
                                      : entry.value.score,
                                  page_url: entry.value.page_url,
                                ),
                              ),
                              const SizedBox(width: 32),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChartData {
  final int x;
  final double y;

  ChartData(this.x, this.y);
}
