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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('Spirometry Test'),
              Obx(() => Padding(
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
                  )),
            ],
          ),
          centerTitle: true,
        ),
        body: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Connection Status Card

                SizedBox(height: 16),

                // Patient Information Form
                PatientForm(),

                SizedBox(height: 16),

                // Device Control Panel
                DeviceControlPanel(),

                SizedBox(height: 16),

                // Test Results Panel
                TestResultsPanel(),
                SizedBox(height: 16),

                // Test Charts - Add this widget
                TestCharts(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
