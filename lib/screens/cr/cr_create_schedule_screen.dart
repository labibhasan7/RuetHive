import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/state/user_provider.dart';
import '../../core/ui/spacing.dart';

// CR CREATE SCHEDULE SCREEN

class CRCreateScheduleScreen extends ConsumerStatefulWidget {
  const CRCreateScheduleScreen({super.key});

  @override
  ConsumerState<CRCreateScheduleScreen> createState() =>
      _CRCreateScheduleScreenState();
}

class _CRCreateScheduleScreenState
    extends ConsumerState<CRCreateScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDay = 'Monday';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 20);
  int _selectedColorIndex = 0;
  bool _isSubmitting = false;

  final _subjectCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _teacherCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const _colors = [
    Colors.blue, Colors.green, Colors.orange,
    Colors.purple, Colors.red, Colors.teal,
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _codeCtrl.dispose();
    _teacherCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // TODO: Firestore write
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post schedule. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Schedule'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded,
                      color: colorScheme.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'You can only post schedules for ${ref.watch(currentUserProvider).academicSummary}',
                      style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Day selector
            Text('Day',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _days.map((day) {
                  final sel = _selectedDay == day;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(day.substring(0, 3)),
                      selected: sel,
                      onSelected: (_) => setState(() => _selectedDay = day),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Subject
            _field(
                ctrl: _subjectCtrl,
                label: 'Subject *',
                hint: 'e.g. Data Structures'),
            const SizedBox(height: AppSpacing.md),
            _field(
                ctrl: _codeCtrl,
                label: 'Course Code *',
                hint: 'e.g. CSE-2101'),
            const SizedBox(height: AppSpacing.md),
            _field(
                ctrl: _teacherCtrl,
                label: 'Teacher *',
                hint: 'e.g. Dr. A. Rahman'),
            const SizedBox(height: AppSpacing.md),
            _field(
                ctrl: _roomCtrl, label: 'Room *', hint: 'e.g. Room 302'),
            const SizedBox(height: AppSpacing.lg),

            // Time pickers
            Text('Time',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                    child: _timePicker('Start Time', _startTime,
                            () => _pickTime(true), colorScheme)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                    child: _timePicker('End Time', _endTime,
                            () => _pickTime(false), colorScheme)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Color picker
            Text('Color',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _colors.asMap().entries.map((e) {
                final sel = _selectedColorIndex == e.key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColorIndex = e.key),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                      border: sel
                          ? Border.all(
                          color: colorScheme.onSurface, width: 3)
                          : null,
                    ),
                    child: sel
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Text('Post Schedule',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null,
    );
  }

  Widget _timePicker(
      String label, TimeOfDay time, VoidCallback onTap, ColorScheme cs) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, color: cs.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12, color: cs.onSurfaceVariant)),
                Text(time.format(context),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// CR CREATE NOTICE SCREEN

// Supported attachment types with metadata
class _AttachmentType {
  final String label;
  final IconData icon;
  final Color color;
  final List<String> extensions;

  const _AttachmentType({
    required this.label,
    required this.icon,
    required this.color,
    required this.extensions,
  });
}

// A single picked attachment
class _Attachment {
  final String name;
  final String extension;
  final int? sizeBytes;

  _Attachment({
    required this.name,
    required this.extension,
    this.sizeBytes,
  });

  String get sizeLabel {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '${sizeBytes}B';
    if (sizeBytes! < 1024 * 1024) return '${(sizeBytes! / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class CRCreateNoticeScreen extends ConsumerStatefulWidget {
  const CRCreateNoticeScreen({super.key});

  @override
  ConsumerState<CRCreateNoticeScreen> createState() =>
      _CRCreateNoticeScreenState();
}

class _CRCreateNoticeScreenState extends ConsumerState<CRCreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _scope = 'section';
  bool _isUrgent = false;
  bool _isSubmitting = false;
  final List<_Attachment> _attachments = [];

  // Attachment type definitions
  static const _attachmentTypes = [
    _AttachmentType(
      label: 'Image',
      icon: Icons.image_rounded,
      color: Color(0xFF4CAF50),
      extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'],
    ),
    _AttachmentType(
      label: 'PDF',
      icon: Icons.picture_as_pdf_rounded,
      color: Color(0xFFEF5350),
      extensions: ['pdf'],
    ),
    _AttachmentType(
      label: 'Document',
      icon: Icons.description_rounded,
      color: Color(0xFF1E88E5),
      extensions: ['doc', 'docx', 'odt', 'rtf'],
    ),
    _AttachmentType(
      label: 'Text',
      icon: Icons.text_snippet_rounded,
      color: Color(0xFF757575),
      extensions: ['txt', 'md'],
    ),
    _AttachmentType(
      label: 'Any File',
      icon: Icons.attach_file_rounded,
      color: Color(0xFF9C27B0),
      extensions: [],
    ),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  //  Pick file of a specific type
  Future<void> _pickFile(_AttachmentType type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: type.extensions.isEmpty ? FileType.any : FileType.custom,
        allowedExtensions: type.extensions.isEmpty ? null : type.extensions,
      );

      if (result != null && mounted) {
        setState(() {
          for (final file in result.files) {
            // Avoid duplicates
            final alreadyAdded = _attachments.any((a) => a.name == file.name);
            if (!alreadyAdded) {
              _attachments.add(_Attachment(
                name: file.name,
                extension: file.extension ?? '',
                sizeBytes: file.size,
              ));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick file: $e')),
        );
      }
    }
  }

  //  Show bottom sheet to choose attachment type
  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Add Attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(ctx).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose the type of file you want to attach',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Type grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              children: _attachmentTypes.map((type) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFile(type);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: type.color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(type.icon, color: type.color, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: type.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Get icon & color for a file extensions
  ({IconData icon, Color color}) _fileStyle(String ext) {
    final lower = ext.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(lower)) {
      return (icon: Icons.image_rounded, color: const Color(0xFF4CAF50));
    }
    if (lower == 'pdf') {
      return (icon: Icons.picture_as_pdf_rounded, color: const Color(0xFFEF5350));
    }
    if (['doc', 'docx', 'odt', 'rtf'].contains(lower)) {
      return (icon: Icons.description_rounded, color: const Color(0xFF1E88E5));
    }
    if (['txt', 'md'].contains(lower)) {
      return (icon: Icons.text_snippet_rounded, color: const Color(0xFF757575));
    }
    return (icon: Icons.attach_file_rounded, color: const Color(0xFF9C27B0));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // TODO: Firestore write
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _attachments.isEmpty
                  ? 'Notice posted successfully!'
                  : 'Notice posted with ${_attachments.length} attachment${_attachments.length > 1 ? 's' : ''}!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post notice. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const orange = Color(0xFFFF9800);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Notice'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, color: orange, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Section notices are visible to Section ${ref.watch(currentUserProvider).section} only. '
                          'Department notices are visible to all ${ref.watch(currentUserProvider).department} ${ref.watch(currentUserProvider).batch.split(' ').first}.',
                      style: const TextStyle(fontSize: 13, color: orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            //  Scope selector
            Text('Scope',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Radio<String>(
                  value: 'section',
                  groupValue: _scope,
                  onChanged: (v) => setState(() => _scope = v!),
                ),
                Text('Section ${ref.watch(currentUserProvider).section} only'),
                const SizedBox(width: AppSpacing.lg),
                Radio<String>(
                  value: 'department',
                  groupValue: _scope,
                  onChanged: (v) => setState(() => _scope = v!),
                ),
                Text(
                  '${ref.watch(currentUserProvider).department} '
                      '${ref.watch(currentUserProvider).batch.split(' ').first}',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            //  Urgent toggle
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: _isUrgent
                        ? Colors.red.withValues(alpha: 0.5)
                        : colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: _isUrgent,
                onChanged: (v) => setState(() => _isUrgent = v),
                title: const Text('Mark as Urgent'),
                subtitle: const Text(
                    'Urgent notices appear at the top with a red badge'),
                secondary: Icon(
                  Icons.warning_rounded,
                  color: _isUrgent ? Colors.red : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            //  Title
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. Lab Rescheduled',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Title is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),

            //  Body
            TextFormField(
              controller: _bodyCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Body *',
                hintText: 'Write your notice here...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Body is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),

            //  Attachments section
            Row(
              children: [
                Text(
                  'Attachments',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (_attachments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_attachments.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Add attachment button
            InkWell(
              onTap: _showAttachmentPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.primary.withValues(alpha: 0.04),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Add Attachment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Supported type icons
                    Row(
                      children: const [
                        Icon(Icons.image_rounded,
                            size: 16, color: Color(0xFF4CAF50)),
                        SizedBox(width: 4),
                        Icon(Icons.picture_as_pdf_rounded,
                            size: 16, color: Color(0xFFEF5350)),
                        SizedBox(width: 4),
                        Icon(Icons.description_rounded,
                            size: 16, color: Color(0xFF1E88E5)),
                        SizedBox(width: 4),
                        Icon(Icons.text_snippet_rounded,
                            size: 16, color: Color(0xFF757575)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Attached files list
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ..._attachments.asMap().entries.map((entry) {
                final i = entry.key;
                final att = entry.value;
                final style = _fileStyle(att.extension);

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                        colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      // File type icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                        Icon(style.icon, color: style.color, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // File name + size
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              att.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (att.sizeLabel.isNotEmpty)
                              Text(
                                att.sizeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Extension badge
                      if (att.extension.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: style.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            att.extension.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: style.color,
                            ),
                          ),
                        ),
                      const SizedBox(width: AppSpacing.sm),

                      // Remove button
                      IconButton(
                        onPressed: () =>
                            setState(() => _attachments.removeAt(i)),
                        icon: Icon(Icons.close_rounded,
                            size: 18, color: colorScheme.error),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Submit button
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: orange,
                padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _attachments.isEmpty
                        ? 'Post Notice'
                        : 'Post Notice  •  ${_attachments.length} file${_attachments.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
