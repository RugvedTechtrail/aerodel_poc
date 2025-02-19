// patient_form.dart
import 'package:aerodel_poc/controllers/spirometer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PatientForm extends StatefulWidget {
  const PatientForm({super.key});

  @override
  State<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<SpirometryController>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final maskFormatter = MaskTextInputFormatter(
    mask: '##-##-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if any
    _firstNameController.text = controller.firstName.value;
    _lastNameController.text = controller.lastName.value;
    _dobController.text = controller.dateOfBirth.value;
    _heightController.text = controller.height.value.toString();
    _weightController.text = controller.weight.value.toString();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }
    if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(value)) {
      return 'Use format DD-MM-YYYY';
    }
    try {
      final parts = value.split('-');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (year < 1900 || year > DateTime.now().year) {
        return 'Invalid year';
      }
      if (month < 1 || month > 12) {
        return 'Invalid month';
      }

      // Validate day based on month and year
      final daysInMonth = _getDaysInMonth(year, month);
      if (day < 1 || day > daysInMonth) {
        return 'Invalid day for the selected month';
      }
    } catch (e) {
      return 'Invalid date format';
    }
    return null;
  }

  int _getDaysInMonth(int year, int month) {
    // Check days in month, accounting for leap years
    switch (month) {
      case 2: // February
        return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))
            ? 29
            : 28;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  String? _validateNumber(String? value, String field, int min, int max) {
    if (value == null || value.isEmpty) {
      return '$field is required';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }
    if (number < min || number > max) {
      return '$field must be between $min and $max';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Patient Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // First Name and Last Name
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name*',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) => controller.firstName.value = value,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name*',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) => controller.lastName.value = value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gender and DOB
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: controller.gender.value.isEmpty
                          ? null
                          : controller.gender.value,
                      decoration: const InputDecoration(
                        labelText: 'Gender*',
                        prefixIcon: Icon(Icons.wc),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(
                            value: 'female', child: Text('Female')),
                      ],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select gender'
                          : null,
                      onChanged: (value) {
                        if (value != null) {
                          controller.gender.value = value;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth*',
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: 'DD-MM-YYYY',
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [maskFormatter],
                      validator: _validateDOB,
                      onChanged: (value) =>
                          controller.dateOfBirth.value = value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Height and Weight
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)*',
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _validateNumber(value, 'Height', 50, 250),
                      onChanged: (value) {
                        controller.height.value = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)*',
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _validateNumber(value, 'Weight', 20, 250),
                      onChanged: (value) {
                        controller.weight.value = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    controller.updatePatientData();
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Patient Data'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                '* Required fields',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceControlPanel extends StatelessWidget {
  const DeviceControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpirometryController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Device Control',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    // Devices List
                    if (controller.devices.isNotEmpty) ...[
                      const Text('Available Devices:'),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.devices.length,
                        itemBuilder: (context, index) {
                          final device = controller.devices[index];
                          return ListTile(
                            leading: const Icon(Icons.bluetooth),
                            title: Text(device['name'] ?? 'Unknown Device'),
                            subtitle: Text(device['address'] ?? ''),
                            dense: true,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Control Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.isScanning.value
                                ? null
                                : () => controller.scanDevices(),
                            icon: const Icon(Icons.search),
                            label: Text(controller.isScanning.value
                                ? 'Scanning...'
                                : 'Scan Devices'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.isConnected.value
                                ? () => controller.disconnectDevice()
                                : () => controller.connectDevice(),
                            icon: Icon(controller.isConnected.value
                                ? Icons.bluetooth_disabled
                                : Icons.bluetooth_connected),
                            label: Text(controller.isConnected.value
                                ? 'Disconnect'
                                : 'Connect'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: !controller.isConnected.value ||
                              controller.isTesting.value
                          ? null
                          : () => controller.startTrial(),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(controller.isTesting.value
                          ? 'Test in Progress...'
                          : 'Start Test'),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class TestResultsPanel extends StatelessWidget {
  const TestResultsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpirometryController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    _buildProgressBar(controller),
                    const SizedBox(height: 16),
                    _buildResultsGrid(controller),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(SpirometryController controller) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: controller.currentProgress.value / 100,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Text(
          'Progress: ${controller.currentProgress.value.toStringAsFixed(1)}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildResultsGrid(SpirometryController controller) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: [
        _buildResultCard(
          'Flow',
          '${controller.currentFlow.value.toStringAsFixed(2)} L/s',
          Icons.speed,
        ),
        _buildResultCard(
          'Volume',
          '${controller.currentVolume.value.toStringAsFixed(2)} L',
          Icons.height,
        ),
        _buildResultCard(
          'Time',
          '${controller.currentTime.value.toStringAsFixed(2)} s',
          Icons.timer,
        ),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
