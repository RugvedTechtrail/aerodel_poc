import 'package:aerodel_poc/Widgets/widgets.dart';
import 'package:aerodel_poc/controllers/spirometer_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestCharts extends StatelessWidget {
  const TestCharts({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpirometryController>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Test Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Content
            Obx(() => Column(
                  children: [
                    // Progress Indicator
                    LinearProgressIndicator(
                      value: controller.currentProgress.value / 100,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progress: ${controller.currentProgress.value.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Add Timer Widget here
                    const TestTimer(),
                    const SizedBox(height: 24),
                    // Flow-Volume Loop Chart
                    SizedBox(
                      height: 320,
                      child: SfCartesianChart(
                        primaryXAxis: const NumericAxis(
                          title: AxisTitle(text: 'Volume (L)'),
                          minimum: 0,
                          maximum: 6,
                        ),
                        primaryYAxis: const NumericAxis(
                          title: AxisTitle(text: 'Flow (L/s)'),
                          minimum: 0,
                          maximum: 12,
                        ),
                        series: [
                          LineSeries<FlowVolumePoint, double>(
                            dataSource: controller.getFlowVolumePoints(),
                            xValueMapper: (FlowVolumePoint point, _) =>
                                point.volume,
                            yValueMapper: (FlowVolumePoint point, _) =>
                                point.flow,
                            color: Colors.blue,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Open File Button (when test is completed)
                    if (controller.isTestCompleted.value)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton.icon(
                          onPressed: controller.openTestFile,
                          icon: const Icon(Icons.file_open),
                          label: const Text('Open Test Results File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),

                    // Test Statistics
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Test Metrics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  'Peak Flow',
                                  '${controller.peakFlow.value.toStringAsFixed(2)} L/s',
                                  Icons.arrow_upward,
                                  Colors.blue,
                                ),
                                _buildStatCard(
                                  'FVC',
                                  '${controller.fvc.value.toStringAsFixed(2)} L',
                                  Icons.straighten,
                                  Colors.green,
                                ),
                                _buildStatCard(
                                  'FEV1',
                                  '${controller.fev1.value.toStringAsFixed(2)} L',
                                  Icons.schedule,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
