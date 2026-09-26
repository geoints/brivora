import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

import '../../domain/models/estimate_item.dart';
import '../providers/estimate_provider.dart';
import '../widgets/add_estimate_item_dialog.dart';
import '../widgets/estimate_category_section.dart';
import '../widgets/estimate_summary_card.dart';
import '../../../projects/domain/models/project.dart';
import '../../../../core/services/pdf_share_service.dart';

class EstimateScreen extends StatefulWidget {
  final Project project;

  const EstimateScreen({super.key, required this.project});

  @override
  State<EstimateScreen> createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<EstimateProvider>().listenToProjectEstimates(
        widget.project.id,
      );
    });
  }

  @override
  void dispose() {
    context.read<EstimateProvider>().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Смета'),
        centerTitle: false,
        actions: [
          Consumer<EstimateProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'Экспорт в PDF',
                onPressed: provider.items.isNotEmpty
                    ? () => _exportToPdf(provider)
                    : null,
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add),
      ),

      body: Consumer<EstimateProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(provider.error!, textAlign: TextAlign.center),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EstimateSummaryCard(provider: provider),
                const SizedBox(height: 16),
                _buildShareButtons(provider),
                const SizedBox(height: 20),
                _buildCategoryFilters(provider),
                const SizedBox(height: 16),
                ...EstimateItem.categories.map((category) {
                  final categoryItems = provider.categoryItems(category);

                  return EstimateCategorySection(
                    title: EstimateItem.categoryTitle(category),
                    total: categoryItems.fold(
                      0.0,
                      (sum, item) => sum + item.totalPrice,
                    ),
                    items: categoryItems,
                    onEdit: (item) {
                      _showAddOrEditDialog(item: item);
                    },
                    onDelete: (item) {
                      _confirmDelete(item);
                    },
                  );
                }),
                if (provider.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      'Добавьте первую позицию сметы для проекта.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShareButtons(EstimateProvider provider) {
    final enabled = provider.items.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Отправить клиенту', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'PDF-файл готовится автоматически',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: enabled ? () => _sharePdfTo('whatsapp', provider) : null,
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: enabled ? () => _sharePdfTo('telegram', provider) : null,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Telegram'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(EstimateProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(provider, 'all', 'Все'),
        for (final category in EstimateItem.categories)
          _buildFilterChip(
            provider,
            category,
            EstimateItem.categoryTitle(category),
          ),
      ],
    );
  }

  Widget _buildFilterChip(
    EstimateProvider provider,
    String category,
    String label,
  ) {
    final selected = provider.selectedCategory == category;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        provider.setCategoryFilter(category);
      },
    );
  }

  Future<void> _showAddOrEditDialog({EstimateItem? item}) async {
    final provider = context.read<EstimateProvider>();

    final result = await showDialog<EstimateItem>(
      context: context,
      builder: (_) {
        return AddEstimateItemDialog(
          projectId: widget.project.id,
          existingItem: item,
        );
      },
    );

    if (result == null) return;

    try {
      if (item == null) {
        await provider.addEstimateItem(result);
      } else {
        await provider.updateEstimateItem(result);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении позиции: $e')),
      );
    }
  }

  Future<void> _confirmDelete(EstimateItem item) async {
    final provider = context.read<EstimateProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Удалить позицию'),
          content: const Text('Вы уверены, что хотите удалить эту позицию?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await provider.deleteEstimateItem(item.id);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении позиции: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<Uint8List> _buildPdf(EstimateProvider provider) async {
    final pdf = pw.Document();

    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final pdfTheme = pw.ThemeData.withFont(base: regularFont, bold: boldFont);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pdfTheme,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'Смета проекта: ${widget.project.title}',
            style: pw.TextStyle(font: boldFont, fontSize: 24),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Дата: ${_formatDate(DateTime.now())}', style: pw.TextStyle(font: regularFont, fontSize: 11)),
          pw.SizedBox(height: 20),
          pw.Text(
            'Общая стоимость: ${EstimateItem.formatMoney(provider.grandTotal)}',
            style: pw.TextStyle(font: boldFont, fontSize: 17),
          ),
          pw.SizedBox(height: 14),
          pw.Text('Материалы: ${EstimateItem.formatMoney(provider.totalMaterials)}', style: pw.TextStyle(font: regularFont, fontSize: 11)),
          pw.Text('Работа: ${EstimateItem.formatMoney(provider.totalLabor)}', style: pw.TextStyle(font: regularFont, fontSize: 11)),
          pw.Text('Доставка: ${EstimateItem.formatMoney(provider.totalDelivery)}', style: pw.TextStyle(font: regularFont, fontSize: 11)),
          pw.Text('Инструменты: ${EstimateItem.formatMoney(provider.totalTools)}', style: pw.TextStyle(font: regularFont, fontSize: 11)),
          pw.Text('Прочее: ${EstimateItem.formatMoney(provider.totalOther)}', style: pw.TextStyle(font: regularFont, fontSize: 11)),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Название', 'Кол-во', 'Ед.', 'Цена', 'Сумма'],
            data: provider.items.map((item) => [
              item.name,
              item.quantity.toStringAsFixed(2),
              item.unit,
              EstimateItem.formatMoney(item.unitPrice),
              EstimateItem.formatMoney(item.totalPrice),
            ]).toList(),
            headerStyle: pw.TextStyle(font: boldFont, fontSize: 10),
            cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.3),
              4: const pw.FlexColumnWidth(1.3),
            },
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Документ сформирован в Brivora',
            style: pw.TextStyle(font: regularFont, fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> _sharePdfTo(String target, EstimateProvider provider) async {
    try {
      final bytes = await _buildPdf(provider);
      final safeProjectName = widget.project.title
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .replaceAll(' ', '_');
      final fileName = 'smeta_$safeProjectName.pdf';

      await PdfShareService.shareToApp(
        target: target,
        fileName: fileName,
        bytes: bytes,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final message = e.code == 'APP_NOT_INSTALLED'
          ? target == 'whatsapp'
              ? 'WhatsApp не установлен на устройстве.'
              : 'Telegram не установлен на устройстве.'
          : 'Не удалось отправить PDF: ${e.message ?? e.code}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отправить PDF: $e')),
      );
    }
  }

  Future<void> _exportToPdf(EstimateProvider provider) async {
    try {
      final bytes = await _buildPdf(provider);
      final safeProjectName = widget.project.title
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .replaceAll(' ', '_');
      final fileName = 'smeta_$safeProjectName.pdf';

      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось создать PDF: $e')),
      );
    }
  }
}
