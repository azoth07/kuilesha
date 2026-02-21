import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class StorageService {
  static const _boxName = 'transactions';
  late Box<Map> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  List<Transaction> getAll() {
    return _box.values
        .map((m) => Transaction.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> save(Transaction tx) async {
    await _box.put(tx.id, tx.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> saveAll(List<Transaction> txList) async {
    final map = {for (final tx in txList) tx.id: tx.toMap()};
    await _box.putAll(map);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
