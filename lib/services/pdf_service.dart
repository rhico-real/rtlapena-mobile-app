import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/daily_report.dart';
import '../constants/app_constants.dart';

class PdfService {
  static Future<void> generateAndSharePdf(DailyReport report) async {
    final pdf = pw.Document();
    
    // Load font
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(report, fontBold),
            pw.SizedBox(height: 20),
            _buildProjectDetails(report, font, fontBold),
            pw.SizedBox(height: 20),
            _buildWeatherLog(report, font, fontBold),
            pw.SizedBox(height: 20),
            _buildWorkLog(report, font, fontBold),
            pw.SizedBox(height: 20),
            _buildIssuesAndSafety(report, font, fontBold),
            if (report.issuePhotos.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildIssuePhotos(report, font, fontBold),
            ],
            pw.SizedBox(height: 30),
            _buildFooter(font),
          ];
        },
      ),
    );

    // Save and share PDF
    final output = await getTemporaryDirectory();
    final fileName = 'Report_${report.blockNumber}_${report.lotNumber}_${report.reportDate}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Daily Construction Report - ${report.reportDate}',
    );
  }

  static pw.Widget _buildHeader(DailyReport report, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(
          'R.T. LAPEÑA CONSTRUCTION & SUPPLY, INC.',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 16,
            color: PdfColor.fromHex('#A97142'),
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'DAILY CONSTRUCTION REPORT',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 24,
            color: PdfColor.fromHex('#A97142'),
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Divider(
          thickness: 3,
          color: PdfColor.fromHex('#A97142'),
        ),
      ],
    );
  }

  static pw.Widget _buildProjectDetails(DailyReport report, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Date:', report.reportDate, font, fontBold),
        _buildDetailRow('Project:', '${UnitTypes.unitTypeNames[report.unitType]} - Block ${report.blockNumber}, Lot ${report.lotNumber}', font, fontBold),
        _buildDetailRow('Contractor:', report.contractorName, font, fontBold),
        _buildDetailRow('Personnel On Site:', '${report.personnelCount}', font, fontBold),
      ],
    );
  }

  static pw.Widget _buildDetailRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: fontBold, fontSize: 14),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildWeatherLog(DailyReport report, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Weather Log',
          style: pw.TextStyle(font: fontBold, fontSize: 18),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: report.weatherLog.map((entry) {
              final weatherInfo = WeatherConditions.weatherMap[entry.condition]!;
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey200),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      entry.time,
                      style: pw.TextStyle(font: fontBold, fontSize: 12),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: _getWeatherColor(entry.condition),
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        weatherInfo.name,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static PdfColor _getWeatherColor(String condition) {
    switch (condition) {
      case WeatherConditions.fair:
        return PdfColors.green;
      case WeatherConditions.cloudy:
        return PdfColors.grey;
      case WeatherConditions.rain:
        return PdfColors.blue;
      case WeatherConditions.heavyRain:
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  static pw.Widget _buildWorkLog(DailyReport report, pw.Font font, pw.Font fontBold) {
    final filteredWorkLog = report.workLog.where((entry) => 
      entry.log.trim().isNotEmpty || entry.photos.isNotEmpty).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Work Progress',
          style: pw.TextStyle(font: fontBold, fontSize: 18),
        ),
        pw.SizedBox(height: 10),
        if (filteredWorkLog.isEmpty)
          pw.Text(
            'No detailed work activity logged.',
            style: pw.TextStyle(font: font, fontSize: 13, color: PdfColors.grey600),
          )
        else
          ...filteredWorkLog.map((entry) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.time,
                  style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  entry.log.isEmpty ? 'No activity logged.' : entry.log,
                  style: pw.TextStyle(font: font, fontSize: 13),
                ),
                if (entry.photos.isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Text(
                    '${entry.photos.length} photo(s) attached',
                    style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ],
            ),
          )),
      ],
    );
  }

  static pw.Widget _buildIssuesAndSafety(DailyReport report, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Issues & Safety Notes',
          style: pw.TextStyle(font: fontBold, fontSize: 18),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Delays/Issues:',
                style: pw.TextStyle(font: fontBold, fontSize: 14),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFE8E8'),
                  border: pw.Border.all(color: PdfColor.fromHex('#FF0033')),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  report.issues.isEmpty ? 'None.' : report.issues,
                  style: pw.TextStyle(font: font, fontSize: 13),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Safety Observations:',
                style: pw.TextStyle(font: fontBold, fontSize: 14),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E8F3FF'),
                  border: pw.Border.all(color: PdfColor.fromHex('#0033FF')),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  report.safetyNotes.isEmpty ? 'None.' : report.safetyNotes,
                  style: pw.TextStyle(font: font, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildIssuePhotos(DailyReport report, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Issue Photos',
          style: pw.TextStyle(font: fontBold, fontSize: 18),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '${report.issuePhotos.length} annotated issue photo(s) attached',
          style: pw.TextStyle(font: font, fontSize: 13, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, style: pw.BorderStyle.dashed),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          'Report generated by R.T. Lapeña Construction & Supply, Inc. Digital Log - ${DateTime.now().toLocal().toString().split(' ')[0]}',
          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }
}
