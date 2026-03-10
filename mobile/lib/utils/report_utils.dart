import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:finsight_mobile/providers/settings_provider.dart';

class ReportUtils {
  static const MethodChannel _channel =
      MethodChannel('finsight.native/downloads');

  static Future<void> showDownloadOptions({
    required BuildContext context,
    required String reportName,
    required List<String> csvHeaders,
    required List<List<dynamic>> csvData,
    required List<Map<String, dynamic>> rawData,
    required String dateInfo,
    Map<String, String>? summaryData,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Export Report",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Choose a format to save the $reportName locally."),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.description, color: Colors.white),
              ),
              title: const Text("Export as CSV"),
              subtitle: const Text("Best for Excel/Google Sheets"),
              onTap: () {
                Navigator.pop(sheetContext);
                _saveAsCSV(context, reportName, dateInfo, csvHeaders, csvData,
                    summaryData);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.picture_as_pdf, color: Colors.white),
              ),
              title: const Text("Export as PDF"),
              subtitle: const Text("Best for printing and sharing"),
              onTap: () {
                Navigator.pop(sheetContext);
                _saveAsPDF(context, reportName, dateInfo, csvHeaders, csvData,
                    summaryData);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Future<void> _saveAsCSV(
    BuildContext context,
    String name,
    String dateInfo,
    List<String> headers,
    List<List<dynamic>> data,
    Map<String, String>? summaryData,
  ) async {
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      StringBuffer csv = StringBuffer();

      csv.writeln(settings.companyName);
      if (settings.companyTagline.isNotEmpty) {
        csv.writeln(settings.companyTagline);
      }
      csv.writeln([
        settings.companyEmail,
        settings.companyPhone,
        settings.companyAddress
      ].where((e) => e.isNotEmpty).join(' | '));
      csv.writeln();
      csv.writeln(name);
      csv.writeln("Period: $dateInfo");
      csv.writeln(
          "Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}");
      csv.writeln();

      csv.writeln(headers.join(','));
      for (var row in data) {
        csv.writeln(row.join(','));
      }

      if (summaryData != null && summaryData.isNotEmpty) {
        csv.writeln();
        csv.writeln("Summary");
        for (var entry in summaryData.entries) {
          csv.writeln("${entry.key},${entry.value}");
        }
      }

      final dateStr = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
      final sanitizedName = name.replaceAll(' ', '_');
      final fileName = '${sanitizedName}_$dateStr.csv';

      if (Platform.isAndroid) {
        final path = await _channel.invokeMethod('saveFile', {
          'fileName': fileName,
          'mimeType': 'text/csv',
          'bytes': Uint8List.fromList(utf8.encode(csv.toString())),
        });
        if (!context.mounted) return;
        _showSuccess(context, "CSV Saved", "File saved to $path");
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csv.toString());

      if (!context.mounted) return;
      _showSuccess(context, "CSV Saved", "File saved to ${file.path}");
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, "Export Failed", e.toString());
    }
  }

  static Future<void> _saveAsPDF(
    BuildContext context,
    String name,
    String dateInfo,
    List<String> headers,
    List<List<dynamic>> data,
    Map<String, String>? summaryData,
  ) async {
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pdfContext) {
            return [
              pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(settings.companyName,
                        style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor(0.83, 0.686, 0.216))),
                    pw.SizedBox(height: 4),
                    pw.Text(
                        settings.companyTagline.isNotEmpty
                            ? settings.companyTagline
                            : "Your Financial Partner",
                        style: const pw.TextStyle(
                            fontSize: 14, color: PdfColor(0.4, 0.4, 0.4))),
                    pw.SizedBox(height: 8),
                    pw.Text(
                        [
                          settings.companyEmail,
                          settings.companyPhone,
                          settings.companyAddress
                        ].where((s) => s.isNotEmpty).join('  |  '),
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.black)),
                  ],
                ),
              ),
              pw.Divider(color: const PdfColor(0.8, 0.8, 0.8)),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(name,
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text("Period: $dateInfo",
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Text(
                      "Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}",
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColor(0.5, 0.5, 0.5))),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              if (summaryData != null && summaryData.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: summaryData.entries.map((e) {
                      bool isLoss =
                          e.value.contains('-') || e.value.contains('Loss');
                      return pw.Container(
                        width: 250,
                        padding: const pw.EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                                bottom: pw.BorderSide(
                                    color: PdfColor(0.8, 0.8, 0.8)))),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(e.key,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 13)),
                            pw.Text(e.value,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 13,
                                    color: isLoss
                                        ? PdfColors.red
                                        : const PdfColor(0.0, 0.5, 0.0))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ];
          },
        ),
      );

      final dateStr = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
      final sanitizedName = name.replaceAll(' ', '_');
      final fileName = '${sanitizedName}_$dateStr.pdf';

      if (Platform.isAndroid) {
        final pdfBytes = await pdf.save();
        final path = await _channel.invokeMethod('saveFile', {
          'fileName': fileName,
          'mimeType': 'application/pdf',
          'bytes': pdfBytes,
        });
        if (!context.mounted) return;
        _showSuccess(context, "PDF Saved", "File saved to $path");
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      if (!context.mounted) return;
      _showSuccess(context, "PDF Saved", "File saved to ${file.path}");
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, "Export Failed", e.toString());
    }
  }

  static void _showSuccess(BuildContext context, String title, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(message, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[800],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void _showError(BuildContext context, String title, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(message, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[800],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
