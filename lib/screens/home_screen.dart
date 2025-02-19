import 'package:aerodel_poc/Widgets/test_chart.dart';
import 'package:aerodel_poc/Widgets/widgets.dart';
import 'package:aerodel_poc/controllers/spirometer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpirometryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spirometry Test'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connection Status Card
              Obx(() => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            controller.isConnected.value
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: controller.isConnected.value
                                ? Colors.green
                                : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            controller.isConnected.value
                                ? 'Connected'
                                : 'Disconnected',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 16),

              // Patient Information Form
              const PatientForm(),

              const SizedBox(height: 16),

              // Device Control Panel
              const DeviceControlPanel(),

              const SizedBox(height: 16),

              // Test Results Panel
              const TestResultsPanel(),
              const SizedBox(height: 16),

              // Test Charts - Add this widget
              const TestCharts(),
            ],
          ),
        ),
      ),
    );
  }
}
