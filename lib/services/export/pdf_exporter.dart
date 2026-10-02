import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

import '../../database/app_database.dart';

class PdfExporter {
  static Future<void> exportMatch({
    required MatchRecord match,
    required List<ConsensusEventRecord> events,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(children: [
            pw.Expanded(child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('TAEKWONDO MATCH SCORESHEET',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(
                  match.category ?? match.mode.toUpperCase(),
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            )),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text(_formatDate(match.createdAt),
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
              if (match.completedAt != null)
                pw.Text('Duration: ${_duration(match.createdAt, match.completedAt!)}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ]),
          ]),

          pw.Divider(thickness: 2, color: PdfColors.grey800),
          pw.SizedBox(height: 12),

          // Fighters
          pw.Row(children: [
            _FighterBox(
              name: match.chungName,
              score: match.chungScore,
              penalties: match.chungPenalties,
              label: 'CHUNG (Blue)',
              color: PdfColors.blue700,
              isWinner: match.winner == 'chung',
            ),
            pw.SizedBox(width: 16),
            pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Text('VS', style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey500)),
            ]),
            pw.SizedBox(width: 16),
            _FighterBox(
              name: match.hongName,
              score: match.hongScore,
              penalties: match.hongPenalties,
              label: 'HONG (Red)',
              color: PdfColors.red700,
              isWinner: match.winner == 'hong',
            ),
          ]),

          pw.SizedBox(height: 20),

          // Result banner
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  match.winner == null ? 'DRAW'
                    : '${match.winner == 'chung' ? match.chungName : match.hongName} WINS',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(width: 16),
                pw.Text(
                  '${match.chungScore} — ${match.hongScore}',
                  style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Scoring log
          if (events.isNotEmpty) ...[
            pw.Text('SCORING LOG',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(0.8),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: ['RND', 'FIGHTER', 'TECHNIQUE', 'PTS']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(h,
                                style: pw.TextStyle(
                                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          ))
                      .toList(),
                ),
                // Data rows — awarded only
                ...events
                    .where((e) => e.outcome == 'awarded')
                    .map((e) => pw.TableRow(children: [
                          _cell('R${e.round}'),
                          _cell(e.awardedTo == 'chung'
                              ? match.chungName : match.hongName),
                          _cell(_techLabel(e.technique)),
                          _cell('+${e.pointsAwarded}'),
                        ])),
              ],
            ),
          ],

          pw.Spacer(),

          // Footer
          pw.Divider(color: PdfColors.grey400),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Generated by TaekwondoScore',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
              pw.Text('Rounds: ${match.totalRounds} × ${match.roundDurationSeconds ~/ 60}m',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
            ],
          ),
        ],
      ),
    ));

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'match_${match.chungName}_vs_${match.hongName}_${_fileDate(match.createdAt)}.pdf'
            .replaceAll(' ', '_');
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  static pw.Widget _FighterBox({
    required String name, required int score, required int penalties,
    required String label, required PdfColor color, required bool isWinner,
  }) {
    return pw.Expanded(child: pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
            color: isWinner ? color : PdfColors.grey300,
            width: isWinner ? 2 : 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: color,
            fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(name, style: pw.TextStyle(fontSize: 14,
            fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('$score', style: pw.TextStyle(fontSize: 40,
            fontWeight: pw.FontWeight.bold, color: color)),
        pw.SizedBox(height: 4),
        pw.Text('Gam-jeom: $penalties',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        if (isWinner) ...[
          pw.SizedBox(height: 6),
          pw.Text('WINNER', style: pw.TextStyle(fontSize: 10,
              fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ]),
    ));
  }

  static pw.Widget _cell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
  );

  static String _techLabel(String? tech) {
    switch (tech) {
      case 'headKick': return 'Head Kick';
      case 'bodyKick': return 'Body Kick';
      case 'punch': return 'Punch';
      case 'gamjeom': return 'Gam-jeom';
      default: return tech ?? '-';
    }
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  static String _fileDate(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2,'0')}${dt.day.toString().padLeft(2,'0')}';

  static String _duration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final m = diff.inMinutes;
    final s = diff.inSeconds % 60;
    return '${m}m ${s}s';
  }
}