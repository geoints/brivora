import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/repositories/payment_receipt_repository.dart';
import '../../domain/models/payment_receipt.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final _repository = PaymentReceiptRepository();
  bool _isUploading = false;

  static const _dateFormat = 'dd.MM.yyyy';

  Future<void> _addReceipt() async {
    final details = await _showReceiptDetailsDialog();
    if (details == null || !mounted) return;

    FilePickerResult? selection;
    try {
      selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );
    } catch (error) {
      _showMessage('Не удалось открыть выбор файла: $error');
      return;
    }

    if (selection == null || selection.files.isEmpty || !mounted) return;
    final file = selection.files.single;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) {
      _showMessage('Не удалось прочитать файл. Попробуйте выбрать его ещё раз.');
      return;
    }

    final extension = (file.extension ?? '').toLowerCase();
    if (!PaymentReceiptRepository.allowedContentTypes.containsKey(extension)) {
      _showMessage('Поддерживаются только PDF, JPG и PNG.');
      return;
    }
    if (bytes.isEmpty || bytes.length > PaymentReceiptRepository.maxFileBytes) {
      _showMessage('Размер файла должен быть не более 15 МБ.');
      return;
    }

    setState(() => _isUploading = true);
    try {
      await _repository.uploadReceipt(
        projectId: widget.projectId,
        fileName: file.name,
        bytes: bytes,
        extension: extension,
        paidAt: details.paidAt,
        amount: details.amount,
        bank: details.bank,
        comment: details.comment,
      );
      if (mounted) _showMessage('Чек добавлен');
    } catch (error) {
      if (mounted) _showMessage('Не удалось добавить чек: $error');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<_ReceiptDetails?> _showReceiptDetailsDialog() async {
    final amountController = TextEditingController();
    final bankController = TextEditingController();
    final commentController = TextEditingController();
    DateTime paidAt = DateTime.now();

    try {
      return await showDialog<_ReceiptDetails>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Данные об оплате'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Сумма (₸), необязательно',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bankController,
                    decoration: const InputDecoration(
                      labelText: 'Банк, необязательно',
                      hintText: 'Kaspi, Halyk…',
                      prefixIcon: Icon(Icons.account_balance_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Дата оплаты'),
                    subtitle: Text(DateFormat(_dateFormat).format(paidAt)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: paidAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                      );
                      if (picked != null) {
                        setDialogState(() => paidAt = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Назначение / комментарий',
                      hintText: 'Например, аванс за ремонт',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PDF, JPG или PNG · до 15 МБ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  final rawAmount = amountController.text.trim().replaceAll(
                    ' ',
                    '',
                  ).replaceAll(',', '.');
                  final amount = rawAmount.isEmpty
                      ? null
                      : double.tryParse(rawAmount);
                  if (rawAmount.isNotEmpty &&
                      (amount == null || amount < 0 || amount > 1000000000000)) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Введите корректную сумму оплаты.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    _ReceiptDetails(
                      amount: amount,
                      bank: bankController.text,
                      comment: commentController.text,
                      paidAt: paidAt,
                    ),
                  );
                },
                child: const Text('Продолжить'),
              ),
            ],
          ),
        ),
      );
    } finally {
      amountController.dispose();
      bankController.dispose();
      commentController.dispose();
    }
  }

  Future<void> _openReceipt(PaymentReceipt receipt) async {
    try {
      final url = await _repository.getDownloadUrl(receipt);
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) _showMessage('Не удалось открыть документ.');
    } catch (error) {
      if (mounted) _showMessage('Не удалось открыть чек: $error');
    }
  }

  Future<void> _confirmDelete(PaymentReceipt receipt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить чек?'),
        content: Text('Документ «${receipt.fileName}» будет удалён из объекта.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repository.deleteReceipt(receipt);
      if (mounted) _showMessage('Чек удалён');
    } catch (error) {
      if (mounted) _showMessage('Не удалось удалить чек: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatMoney(double amount) =>
      '${NumberFormat('#,##0.##', 'ru_RU').format(amount)} ₸';

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} КБ';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Чеки и оплаты')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _addReceipt,
        icon: _isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.attach_file_rounded),
        label: Text(_isUploading ? 'Загрузка…' : 'Добавить чек'),
      ),
      body: StreamBuilder<List<PaymentReceipt>>(
        stream: _repository.watchProjectReceipts(widget.projectId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Не удалось загрузить чеки: ${snapshot.error}'),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final receipts = snapshot.data ?? const <PaymentReceipt>[];
          if (receipts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 34,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Пока нет чеков',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Прикрепляйте подтверждения переводов, чтобы хранить историю оплат прямо в объекте.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _isUploading ? null : _addReceipt,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Добавить первый чек'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: receipts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              final isPdf = receipt.contentType == 'application/pdf';
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    receipt.amount == null
                        ? receipt.fileName
                        : _formatMoney(receipt.amount!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat(_dateFormat).format(receipt.paidAt)}'
                          '${receipt.bank.isEmpty ? '' : ' · ${receipt.bank}'}',
                        ),
                        if (receipt.comment.isNotEmpty)
                          Text(
                            receipt.comment,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          '${isPdf ? 'PDF' : 'Изображение'} · ${_formatSize(receipt.sizeBytes)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isThreeLine: receipt.comment.isNotEmpty,
                  onTap: () => _openReceipt(receipt),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Действия с чеком',
                    onSelected: (value) {
                      if (value == 'open') _openReceipt(receipt);
                      if (value == 'delete') _confirmDelete(receipt);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'open',
                        child: ListTile(
                          leading: Icon(Icons.open_in_new_rounded),
                          title: Text('Открыть'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline_rounded),
                          title: Text('Удалить'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReceiptDetails {
  const _ReceiptDetails({
    required this.amount,
    required this.bank,
    required this.comment,
    required this.paidAt,
  });

  final double? amount;
  final String bank;
  final String comment;
  final DateTime paidAt;
}
