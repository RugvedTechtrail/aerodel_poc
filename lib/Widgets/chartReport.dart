import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class ReportGenerator {
  // Reference to the chart for capturing
  final GlobalKey chartKey = GlobalKey();

  // Generate text report file
  Future<String> generateTextReport({
    required String firstName,
    required String lastName,
    required String gender,
    required String dateOfBirth,
    required String height,
    required String weight,
    required double peakFlow,
    required double fvc,
    required double fev1,
    required List<double> flowArray,
    required List<double> volumeArray,
    required List<double> timeArray,
  }) async {
    try {
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${lastName}_${firstName}_$timestamp.txt';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      final sink = file.openWrite();

      // Write header
      sink.writeln('Spirometry Test Results');
      sink.writeln('======================');
      sink.writeln('Date: ${DateTime.now().toString()}');
      sink.writeln('');

      // Write patient data
      sink.writeln('Patient Information:');
      sink.writeln('-----------------');
      sink.writeln('Name: $firstName $lastName');
      sink.writeln('Gender: $gender');
      sink.writeln('Date of Birth: $dateOfBirth');
      sink.writeln('Height: $height cm');
      sink.writeln('Weight: $weight kg');
      sink.writeln('');

      // Write test results
      sink.writeln('Test Results:');
      sink.writeln('-----------');
      sink.writeln('Peak Flow: ${peakFlow.toStringAsFixed(2)} L/s');
      sink.writeln('FVC: ${fvc.toStringAsFixed(2)} L');
      sink.writeln('FEV1: ${fev1.toStringAsFixed(2)} L');
      sink.writeln(
          'FEV1/FVC: ${(fev1 / (fvc > 0 ? fvc : 1) * 100).toStringAsFixed(2)}%');
      sink.writeln('');

      // Write raw data
      sink.writeln('Raw Data:');
      sink.writeln('--------');
      sink.writeln('Time (s), Flow (L/s), Volume (L)');

      for (int i = 0;
          i < timeArray.length &&
              i < flowArray.length &&
              i < volumeArray.length;
          i++) {
        sink.writeln(
            '${timeArray[i].toStringAsFixed(3)}, ${flowArray[i].toStringAsFixed(3)}, ${volumeArray[i].toStringAsFixed(3)}');
      }

      await sink.flush();
      await sink.close();

      return filePath;
    } catch (e) {
      print('Error generating text report: $e');
      rethrow;
    }
  }

  // Capture chart as image
  Future<Uint8List?> captureChart() async {
    try {
      final boundary =
          chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing chart: $e');
      return null;
    }
  }

  // Generate PDF report with charts
  Future<String> generatePdfReport({
    required String firstName,
    required String lastName,
    required String gender,
    required String dateOfBirth,
    required String height,
    required String weight,
    required double peakFlow,
    required double fvc,
    required double fev1,
    required List<double> flowVolumePoints,
    Uint8List? chartImage,
  }) async {
    try {
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${lastName}_${firstName}_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';

      final pdf = pw.Document();

      // Add page with report content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                  level: 0,
                  child: pw.Text('Spirometry Test Report',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold))),

              pw.SizedBox(height: 10),
              pw.Text('Date: ${DateTime.now().toString().split('.').first}'),
              pw.SizedBox(height: 20),

              // Patient information
              pw.Header(level: 1, child: pw.Text('Patient Information')),
              pw.Table(border: pw.TableBorder.all(), children: [
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Name:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('$firstName $lastName'),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Gender:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(gender),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Date of Birth:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(dateOfBirth),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Height:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('$height cm'),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Weight:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('$weight kg'),
                  ),
                ]),
              ]),

              pw.SizedBox(height: 20),

              // Test results
              pw.Header(level: 1, child: pw.Text('Test Results')),
              pw.Table(border: pw.TableBorder.all(), children: [
                pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Metric',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Value',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Predicted',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('% Predicted',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Peak Flow (L/s)'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(peakFlow.toStringAsFixed(2)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('--'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('--'),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('FVC (L)'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(fvc.toStringAsFixed(2)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('--'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('--'),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('FEV1 (L)'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(fev1.toStringAsFixed(2)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('--'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('--'),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('FEV1/FVC (%)'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                        (fev1 / (fvc > 0 ? fvc : 1) * 100).toStringAsFixed(2)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('--'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('--'),
                  ),
                ]),
              ]),

              pw.SizedBox(height: 20),

              // Flow-Volume Loop Chart
              pw.Header(level: 1, child: pw.Text('Flow-Volume Loop')),
              chartImage != null
                  ? pw.Center(child: pw.Image(pw.MemoryImage(chartImage)))
                  : pw.Center(child: pw.Text('Chart not available')),

              pw.SizedBox(height: 10),
              pw.Text(
                  'Note: This report is automatically generated and should be reviewed by a healthcare professional.',
                  style: pw.TextStyle(
                      fontSize: 8, fontStyle: pw.FontStyle.italic)),
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            );
          },
        ),
      );

      // Save the PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      print('Error generating PDF report: $e');
      rethrow;
    }
  }
}
