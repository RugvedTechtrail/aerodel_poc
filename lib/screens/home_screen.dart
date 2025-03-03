import 'package:aerodel_poc/Widgets/test_chart.dart';
import 'package:aerodel_poc/Widgets/widgets.dart';
import 'package:aerodel_poc/controllers/spirometer_controller.dart';
import 'package:aerodel_poc/screens/qrcode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpirometryController>();

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrPage(),
                ));
          },
          child: Icon(Icons.qr_code),
        ),
        appBar: AppBar(
          title: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'Spirometry Test',
                    style: TextStyle(fontSize: 18),
                  ),
                  Icon(
                    controller.isConnected.value
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: controller.isConnected.value
                        ? Colors.green
                        : Colors.red,
                    size: 24,
                  ),
                  Text(
                    controller.isConnected.value ? 'Connected' : 'Disconnected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  controller.batteryStatus.value != ''
                      ? Row(
                          children: [
                            Icon(
                              _getBatteryIcon(controller.batteryStatus.value),
                              color: _getBatteryColor(
                                  controller.batteryStatus.value),
                              size: 25,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              controller.batteryStatus.value,
                              style: TextStyle(
                                fontSize: 15,
                                color: _getBatteryColor(
                                    controller.batteryStatus.value),
                              ),
                            ),
                          ],
                        )
                      : SizedBox()
                ],
              )),
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

  IconData _getBatteryIcon(String batteryStatus) {
    try {
      final batteryPercent = int.parse(batteryStatus.replaceAll('%', ''));
      if (batteryPercent >= 75) {
        return Icons.battery_full;
      } else if (batteryPercent >= 50) {
        return Icons.battery_3_bar;
      } else if (batteryPercent >= 25) {
        return Icons.battery_2_bar;
      } else {
        return Icons.battery_alert;
      }
    } catch (e) {
      return Icons.battery_unknown;
    }
  }

  // Helper method to determine battery color based on battery status
  Color _getBatteryColor(String batteryStatus) {
    try {
      final batteryPercent = int.parse(batteryStatus.replaceAll('%', ''));
      if (batteryPercent >= 50) {
        return Colors.green;
      } else if (batteryPercent >= 25) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    } catch (e) {
      return Colors.grey;
    }
  }
}
