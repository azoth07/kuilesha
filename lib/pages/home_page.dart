import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/csv_service.dart';
import '../services/file_service.dart';
import '../widgets/glass_card.dart';
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  final StorageService storage;
  const HomePage({super.key, required this.storage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _csvService = CsvService();
  List<Transaction> _transactions = [];
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _refresh();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _transactions = widget.storage.getAll();
    });
  }

  double get _totalLoss =>
      _transactions.fold(0.0, (sum, t) => sum + t.amount);

  String _getLossInsight() {
    final fmt = NumberFormat('#,##0.00');
    if (_totalLoss == 0) {
      return '还没有记录亏损。记住：人对损失的痛苦感受是同等收益快乐感的 2 倍。';
    }
    final painValue = _totalLoss * 2;
    return '你的 ¥${fmt.format(_totalLoss)} 亏损带来的心理痛苦，等同于赚到 ¥${fmt.format(painValue)} 的快乐。'
        '\n每一笔亏损都在提醒你：下次出手前，再想一想。';
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('亏了啥'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: _onMenuAction,
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'export_csv', child: Text('导出 CSV')),
                const PopupMenuItem(
                    value: 'import_csv', child: Text('导入 CSV')),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'export_text', child: Text('导出同步码')),
                const PopupMenuItem(
                    value: 'import_text', child: Text('导入同步码')),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'clear',
                    child: Text('清空数据',
                        style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                children: [
                  _buildLossHero(),
                  const SizedBox(height: 12),
                  _buildInsightCard(),
                  const SizedBox(height: 16),
                  _buildListHeader(),
                  const SizedBox(height: 12),
                  ..._buildTxList(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddEdit(null),
          icon: const Icon(Icons.add_rounded),
          label: const Text('记一笔亏损',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildLossHero() {
    final fmt = NumberFormat('#,##0.00');
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (context, child) {
        return GlassCard(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          blur: 30,
          opacity: 0.12,
          tint: _totalLoss > 0
              ? Color.lerp(
                  const Color(0xFFFF6B6B),
                  const Color(0xFFFF8E8E),
                  (_shimmerCtrl.value * 2 * pi).abs() * 0.1,
                )
              : Colors.white,
          child: Column(
            children: [
              Text(
                '累计亏损',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: _totalLoss > 0
                      ? [
                          const Color(0xFFFF6B6B),
                          const Color(0xFFFF8E53),
                          const Color(0xFFFF6B6B),
                        ]
                      : [Colors.white70, Colors.white, Colors.white70],
                  stops: [
                    (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
                    _shimmerCtrl.value,
                    (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds),
                child: Text(
                  '¥${fmt.format(_totalLoss)}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _glassStat(
                      '亏损笔数',
                      '${_transactions.length}',
                      const Color(0xFFFF6B6B)),
                  _glassStatDivider(),
                  _glassStat(
                      '平均每笔',
                      _transactions.isEmpty
                          ? '¥0.00'
                          : '¥${fmt.format(_totalLoss / _transactions.length)}',
                      const Color(0xFFFF8E53)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _glassStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _glassStatDivider() {
    return Container(
      width: 0.5,
      height: 28,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildInsightCard() {
    return GlassCard(
      opacity: 0.10,
      tint: const Color(0xFF6C63FF),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withValues(alpha: 0.3),
                      const Color(0xFF48C6EF).withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.psychology_rounded,
                      size: 18, color: Color(0xFF48C6EF)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '损失厌恶理论',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              Text(
                'Loss Aversion',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.25),
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 0.5,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 12),
          Text(
            _getLossInsight(),
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— Kahneman & Tversky, 1979',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.3),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      children: [
        Text('亏损记录',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6))),
        const Spacer(),
        Text('${_transactions.length} 笔',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
      ],
    );
  }

  List<Widget> _buildTxList() {
    if (_transactions.isEmpty) {
      return [
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined,
                  size: 48, color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 12),
              Text('暂无记录',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 15)),
            ],
          ),
        ),
      ];
    }
    return _transactions
        .map((tx) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTxCard(tx),
            ))
        .toList();
  }

  Widget _buildTxCard(Transaction tx) {
    final fmt = NumberFormat('#,##0.00');
    return GlassCard(
      opacity: 0.06,
      blur: 16,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: InkWell(
        onTap: () => _openAddEdit(tx),
        onLongPress: () => _confirmDelete(tx),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('📉', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '-¥${fmt.format(tx.amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (tx.category.isNotEmpty) tx.category,
                      if (tx.description.isNotEmpty) tx.description,
                      DateFormat('yyyy-MM-dd').format(tx.date),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.15), size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddEdit(Transaction? tx) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) =>
            AddEditPage(storage: widget.storage, transaction: tx),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true) _refresh();
  }

  Future<void> _confirmDelete(Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('删除这笔亏损 ¥${tx.amount.toStringAsFixed(2)}？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.storage.delete(tx.id);
      _refresh();
    }
  }

  void _onMenuAction(String action) {
    switch (action) {
      case 'export_csv':
        _exportCsv();
      case 'import_csv':
        _importCsv();
      case 'export_text':
        _exportText();
      case 'import_text':
        _importText();
      case 'clear':
        _clearData();
    }
  }

  Future<void> _exportCsv() async {
    final csv = _csvService.exportToCsv(_transactions);
    final fileName =
        'kuilesha_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    try {
      await FileService.instance.shareFile(csv, fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导出失败: $e')));
      }
    }
  }

  Future<void> _importCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      final content = utf8.decode(bytes);
      final txList = _csvService.importFromCsv(content);
      await widget.storage.saveAll(txList);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 ${txList.length} 条记录')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导入失败: $e')));
      }
    }
  }

  Future<void> _exportText() async {
    final text = _csvService.exportToBase64(_transactions);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('跨平台同步码'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('复制下方文本到另一个平台导入：',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6))),
              const SizedBox(height: 12),
              SelectableText(
                text,
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> _importText() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入同步码'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '粘贴从另一个平台导出的同步码...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('导入')),
        ],
      ),
    );
    if (confirmed != true || controller.text.trim().isEmpty) return;
    try {
      final txList = _csvService.importFromBase64(controller.text);
      await widget.storage.saveAll(txList);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 ${txList.length} 条记录')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导入失败，请检查同步码: $e')));
      }
    }
    controller.dispose();
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空所有数据'),
        content: const Text('此操作不可恢复，建议先导出备份。确定清空？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('清空', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.storage.clear();
      _refresh();
    }
  }
}
