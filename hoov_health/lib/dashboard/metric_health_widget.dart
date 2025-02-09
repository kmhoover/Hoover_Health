import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../backend/state.dart';

class MetricHealthWidget extends StatefulWidget {
  const MetricHealthWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.score,
    required this.page_url,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int score;
  final String page_url;

  @override
  State<MetricHealthWidget> createState() => _MetricHealthWidgetState();
}

class _MetricHealthWidgetState extends State<MetricHealthWidget> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<StateModel>(
      builder: (context, stateModel, child) {
        int score = widget.title == 'Wifi Health' ? stateModel.wifiHealthScore 
        : widget.title == 'Application Health' ? stateModel.appHealthScore 
        : 71; // Default or other metric score

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isHover ? widget.color.withAlpha(200) : widget.color,
          ),
          height: 200,
          child: InkWell(
            onTap: () {
              if (widget.title == 'Wifi Health') {
                print('Wifi Health Score: $score');
                if (score != -1) {
                  print('Wi-Fi score is available: $score');
                } else {
                  Navigator.pushNamed(context, '/network');
                }
              }else if (widget.title == 'Application Health') {
                print('App Health Score: $score');
                if (score != -1) {
                  print('Application score is available: $score');
                } else {
                  Navigator.pushNamed(context, '/applications');
                }
              } else {
                Navigator.pushNamed(context, widget.page_url);
              }
            },
            onHover: (val) {
              setState(() {
                isHover = val;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Icon(widget.icon, size: 32, color: Colors.white),
                  Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          startAngle: 150,
                          radiusFactor: 0.75,
                          endAngle: 30,
                          minimum: 0,
                          maximum: 100,
                          axisLineStyle: const AxisLineStyle(
                            thickness: 0,
                          ),
                          ranges: <GaugeRange>[
                            GaugeRange(
                                startValue: score.toDouble(),
                                endValue: 100,
                                color: Colors.grey[400]),
                            GaugeRange(
                                startValue: 0,
                                endValue: score.toDouble(),
                                color: Colors.white),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Container(
                                child: Text(
                                  '$score%',
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              angle: 90,
                              positionFactor: 0,
                            ),
                          ],
                          showLabels: false,
                          interval: 100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
