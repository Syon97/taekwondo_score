import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../database/app_database.dart';

class ExcelExporter {
  static Future<void> exportMatch({
    required MatchRecord match,
    required List<ConsensusEventRecord> events,
  }) async {
    final excel = Excel.createExcel();

    // ── Sheet 1: Summary ─────────────────────────────────────────────────────
    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    _header(summary, 0, ['TAEKWONDO MATCH SCORESHEET']);
    _row(summary, 1, ['Date', _formatDate(match.createdAt)]);
    _row(summary, 2, ['Category', match.category ?? match.mode.toUpperCase()]);
    _row(summary, 3, ['Rounds', '${match.totalRounds} × ${match.roundDurationSeconds ~/ 60}m']);
    _row(summary, 4, []);
    _header(summary, 5, ['FIGHTER', 'SCORE', 'GAM-JEOM', 'RESULT']);
    _row(summary, 6, [
      match.chungName, match.chungScore, match.chungPenalties,
      match.winner == 'chung' ? 'WINNER' : '',
    ]);
    _row(summary, 7, [
      match.hongName, match.hongScore, match.hongPenalties,
      match.winner == 'hong' ? 'WINNER' : '',
    ]);
    _row(summary, 8, []);
    _row(summary, 9, ['Final Score',
        '${match.chungName} ${match.chungScore} — ${match.hongScore} ${match.hongName}']);
    if (match.winner != null) {
      _row(summary, 10, ['Winner',
          match.winner == 'chung' ? match.chungName : match.hongName]);
    }

    // ── Sheet 2: Scoring Log ─────────────────────────────────────────────────
    final log = excel['Scoring Log'];
    _header(log, 0, ['ROUND', 'FIGHTER', 'TECHNIQUE', 'POINTS', 'TIMESTAMP']);

    int row = 1;
    for (final e in events.where((e) => e.outcome == 'awarded')) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e.resolvedAtMs);
      _row(log, row++, [
        'Round ${e.round}',
        e.awardedTo == 'chung' ? match.chungName : match.hongName,
        _techLabel(e.technique),
        e.pointsAwarded,
        _formatDate(dt),
      ]);
    }

    // ── Sheet 3: Full Audit ───────────────────────────────────────────────────
    final audit = excel['Full Audit'];
    _header(audit, 0, ['ROUND', 'OUTCOME', 'FIGHTER', 'TECHNIQUE', 'POINTS', 'TIMESTAMP']);

    int auditRow = 1;
    for (final e in events) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e.resolvedAtMs);
      _row(audit, auditRow++, [
        'Round ${e.round}',
        e.outcome,
        e.awardedTo ?? '-',
        _techLabel(e.technique),
        e.pointsAwarded,
        _formatDate(dt),
      ]);
    }

    // Save and open
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'match_${match.chungName}_vs_${match.hongName}_${_fileDate(match.createdAt)}.xlsx'
            .replaceAll(' ', '_');
    final file = File('${dir.path}/$fileName');
    final bytes = excel.save();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    }
  }

  static void _header(Sheet sheet, int rowIdx, List<dynamic> values) {
    for (int i = 0; i < values.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIdx));
      cell.value = TextCellValue(values[i].toString());
      cell.cellStyle = CellStyle(bold: true);
    }
  }

  static void _row(Sheet sheet, int rowIdx, List<dynamic> values) {
    for (int i = 0; i < values.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIdx));
      final val = values[i];
      if (val is int) {
        cell.value = IntCellValue(val);
      } else {
        cell.value = TextCellValue(val?.toString() ?? '');
      }
    }
  }

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
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  static String _fileDate(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2,'0')}${dt.day.toString().padLeft(2,'0')}';
}