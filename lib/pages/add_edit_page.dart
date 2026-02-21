import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';

class AddEditPage extends StatefulWidget {
  final StorageService storage;
  final Transaction? transaction;

  const AddEditPage({super.key, required this.storage, this.transaction});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _descCtrl;
  late DateTime _date;

  bool get _isEditing => widget.transaction != null;

  static const _defaultCategories = [
    '股票',
    '基金',
    '加密货币',
    '期货',
    '房产',
    '创业',
    '借钱不还了',
    '发红包',
    '随礼',
    '瞎投资',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountCtrl = TextEditingController(
      text: tx != null ? tx.amount.toStringAsFixed(2) : '',
    );
    _categoryCtrl = TextEditingController(text: tx?.category ?? '');
    _descCtrl = TextEditingController(text: tx?.description ?? '');
    _date = tx?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? '编辑亏损' : '记录亏损'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: RepaintBoundary(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildAmountField(),
                      const SizedBox(height: 16),
                      _buildCategoryField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
      decoration: const InputDecoration(
        labelText: '亏损金额',
        prefixText: '¥ ',
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return '请输入金额';
        if (double.tryParse(v) == null || double.parse(v) <= 0) {
          return '请输入有效金额';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _categoryCtrl,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: '分类',
            hintText: '选择或输入分类',
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _defaultCategories
              .map((c) => GestureDetector(
                    onTap: () => setState(() => _categoryCtrl.text = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _categoryCtrl.text == c
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descCtrl,
      minLines: 2,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: '备注',
        hintText: '可选',
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '日期',
          suffixIcon: Icon(Icons.calendar_today_rounded,
              size: 18, color: Colors.white38),
        ),
        child: Text(
          DateFormat('yyyy-MM-dd').format(_date),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              _isEditing ? '保存修改' : '记录亏损',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tx = Transaction(
      id: widget.transaction?.id ?? _uuid.v4(),
      amount: double.parse(_amountCtrl.text),
      category: _categoryCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date: _date,
      createdAt: widget.transaction?.createdAt,
    );
    await widget.storage.save(tx);
    if (mounted) Navigator.pop(context, true);
  }
}
