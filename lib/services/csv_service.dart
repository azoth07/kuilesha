import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class CsvService {
  static const _uuid = Uuid();

  static const _headers = [
    'ID',
    'Amount',
    'Category',
    'Description',
    'Date',
    'CreatedAt',
  ];

  String exportToCsv(List<Transaction> transactions) {
    final rows = <List<dynamic>>[
      _headers,
      ...transactions.map((tx) => [
            tx.id,
            tx.amount,
            tx.category,
            tx.description,
            tx.date.toIso8601String(),
            tx.createdAt.toIso8601String(),
          ]),
    ];
    return const CsvEncoder().convert(rows);
  }

  List<Transaction> importFromCsv(String csvContent) {
    final rows = const CsvDecoder().convert(csvContent);
    if (rows.isEmpty) return [];

    final hasHeader =
        rows.first.any((cell) => cell.toString().toUpperCase() == 'AMOUNT');
    final dataRows = hasHeader ? rows.skip(1) : rows;

    return dataRows.map((row) {
      return Transaction(
        id: row[0].toString().isNotEmpty ? row[0].toString() : _uuid.v4(),
        amount: double.tryParse(row[1].toString()) ?? 0,
        category: row.length > 2 ? row[2].toString() : '',
        description: row.length > 3 ? row[3].toString() : '',
        date: row.length > 4
            ? (DateTime.tryParse(row[4].toString()) ?? DateTime.now())
            : DateTime.now(),
        createdAt: row.length > 5
            ? (DateTime.tryParse(row[5].toString()) ?? DateTime.now())
            : DateTime.now(),
      );
    }).toList();
  }

  String exportToBase64(List<Transaction> transactions) {
    return base64Encode(utf8.encode(exportToCsv(transactions)));
  }

  List<Transaction> importFromBase64(String base64Str) {
    final csv = utf8.decode(base64Decode(base64Str.trim()));
    return importFromCsv(csv);
  }
}
