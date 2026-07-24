import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/crops.dart';
import '../../state/game_provider.dart';
import '../../state/notebook_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_sheet.dart';

final _accent = moduleTheme(ModuleId.notebook).color;

const _types = [
  ('flowering', 'Flowering date'),
  ('disease-score', 'Disease score (1-9)'),
  ('yield', 'Yield'),
  ('height', 'Plant height'),
  ('general', 'General observation'),
];

class FieldNotebookScreen extends StatefulWidget {
  const FieldNotebookScreen({super.key});

  @override
  State<FieldNotebookScreen> createState() => _FieldNotebookScreenState();
}

class _FieldNotebookScreenState extends State<FieldNotebookScreen> {
  String cropId = crops.first.id;
  String observationType = 'general';
  final valueController = TextEditingController();
  final notesController = TextEditingController();
  String? imagePath;
  bool showReport = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (file != null) setState(() => imagePath = file.path);
  }

  void _submit() {
    if (valueController.text.trim().isEmpty) return;
    context.read<NotebookProvider>().addEntry(
          cropId: cropId,
          date: DateTime.now().toIso8601String().substring(0, 10),
          observationType: observationType,
          value: valueController.text.trim(),
          notes: notesController.text.trim(),
          imagePath: imagePath,
        );
    context.read<GameProvider>().addXp(5, 'Recorded a field notebook observation');
    setState(() {
      valueController.clear();
      notesController.clear();
      imagePath = null;
    });
  }

  void _showEntryDetails(NotebookEntry e) {
    showDetailSheet(
      context,
      title: _types.firstWhere((t) => t.$1 == e.observationType).$2,
      subtitle: '${crops.firstWhere((c) => c.id == e.cropId).name} · ${e.date}',
      icon: Icons.edit_note,
      accentColor: _accent,
      children: [
        if (e.imagePath != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.md), child: Image.file(File(e.imagePath!), height: 180, width: double.infinity, fit: BoxFit.cover)),
          ),
        DetailSection(label: 'Value', text: e.value),
        if (e.notes.isNotEmpty) DetailSection(label: 'Notes', text: e.notes),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<NotebookProvider>().entries;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Record real observations from your virtual field trials.', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('New Observation'),
                DropdownButtonFormField<String>(
                  initialValue: cropId,
                  isExpanded: true,
                  items: [for (final c in crops) DropdownMenuItem(value: c.id, child: Text('${c.emoji} ${c.name}', overflow: TextOverflow.ellipsis))],
                  onChanged: (v) => setState(() => cropId = v!),
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: observationType,
                  isExpanded: true,
                  items: [for (final t in _types) DropdownMenuItem(value: t.$1, child: Text(t.$2, overflow: TextOverflow.ellipsis))],
                  onChanged: (v) => setState(() => observationType = v!),
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 8),
                TextField(controller: valueController, decoration: const InputDecoration(hintText: 'Measured value', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, size: 16),
                  label: Text(imagePath != null ? 'Image attached' : 'Attach image'),
                ),
                const SizedBox(height: 8),
                TextField(controller: notesController, maxLines: 2, decoration: const InputDecoration(hintText: 'Notes...', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                ElevatedButton.icon(onPressed: _submit, icon: const Icon(Icons.edit, size: 16), label: const Text('Save Entry')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Entries (${entries.length})', style: AppText.sectionTitle),
              OutlinedButton.icon(
                onPressed: () => setState(() => showReport = !showReport),
                icon: const Icon(Icons.description, size: 16),
                label: Text(showReport ? 'Hide' : 'Report'),
              ),
            ],
          ),
          if (showReport) _buildReport(entries),
          const SizedBox(height: AppSpacing.sm),
          if (entries.isEmpty) const Text('No entries yet — record your first observation above.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: InkWell(
                  onTap: () => _showEntryDetails(e),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (e.imagePath != null) ...[
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(e.imagePath!), width: 44, height: 44, fit: BoxFit.cover)),
                        const SizedBox(width: 10),
                      ] else ...[
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: _accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.edit_note, color: _accent, size: 20),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(crops.firstWhere((c) => c.id == e.cropId).emoji),
                              const SizedBox(width: 4),
                              Expanded(child: Text(_types.firstWhere((t) => t.$1 == e.observationType).$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis)),
                              Pill(e.date),
                            ]),
                            Text(e.value, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16, color: AppColors.bad),
                        onPressed: () => context.read<NotebookProvider>().removeEntry(e.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReport(List<NotebookEntry> entries) {
    final byCrop = <String, int>{};
    for (final e in entries) {
      byCrop[e.cropId] = (byCrop[e.cropId] ?? 0) + 1;
    }
    return AppCard(
      accentColor: _accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle('Auto-generated Summary Report'),
          Text('Total observations: ${entries.length}', style: AppText.body),
          const SizedBox(height: 6),
          for (final entry in byCrop.entries) Text('• ${crops.firstWhere((c) => c.id == entry.key).name}: ${entry.value} observations', style: AppText.caption),
        ],
      ),
    );
  }
}
