import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ruethive/services/onesignal.dart';
import '../../core/ui/spacing.dart';
import '../../core/utils/validators.dart';
import 'package:ruethive/models/notice_model.dart';
import 'package:ruethive/services/firestore.dart';

// ATTACHMENT HELPERS
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
    if (sizeBytes! < 1024 * 1024) {
      return '${(sizeBytes! / 1024).toStringAsFixed(1)}KB';
    }
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// ADMIN CREATE NOTICE SCREEN
class AdminCreateNoticeScreen extends StatefulWidget {
  const AdminCreateNoticeScreen({super.key});

  @override
  State<AdminCreateNoticeScreen> createState() =>
      _AdminCreateNoticeScreenState();
}

class _AdminCreateNoticeScreenState extends State<AdminCreateNoticeScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _bodyCtrl   = TextEditingController();

  String _scope           = 'department';
  String _selectedSection = 'A';
  String _selectedBatch   = '23';
  bool _isUrgent          = false;
  bool _isSubmitting      = false;
  final List<_Attachment> _attachments = [];

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

  // Audience label

  String get _audienceLabel {
    switch (_scope) {
      case 'section':
        return 'CSE $_selectedBatch • Section $_selectedSection only';
      case 'batch':
        return 'All of CSE Batch $_selectedBatch';
      case 'department':
        return 'Entire CSE Department';
      case 'university':
        return 'All RUET Students & Staff';
      default:
        return '';
    }
  }

  //File picking

  Future<void> _pickFile(_AttachmentType type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: type.extensions.isEmpty ? FileType.any : FileType.custom,
        allowedExtensions:
        type.extensions.isEmpty ? null : type.extensions,
      );
      if (result != null && mounted) {
        setState(() {
          for (final file in result.files) {
            final alreadyAdded =
            _attachments.any((a) => a.name == file.name);
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

  ({IconData icon, Color color}) _fileStyle(String ext) {
    final lower = ext.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(lower)) {
      return (icon: Icons.image_rounded, color: const Color(0xFF4CAF50));
    }
    if (lower == 'pdf') {
      return (
      icon: Icons.picture_as_pdf_rounded,
      color: const Color(0xFFEF5350)
      );
    }
    if (['doc', 'docx', 'odt', 'rtf'].contains(lower)) {
      return (
      icon: Icons.description_rounded,
      color: const Color(0xFF1E88E5)
      );
    }
    if (['txt', 'md'].contains(lower)) {
      return (
      icon: Icons.text_snippet_rounded,
      color: const Color(0xFF757575)
      );
    }
    return (
    icon: Icons.attach_file_rounded,
    color: const Color(0xFF9C27B0)
    );
  }

  // Submit

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    try {
      final item = NoticeItem(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _bodyCtrl.text.trim(),
        time: TimeOfDay.now().format(context),
        date: DateTime.now(),
        postedBy: "CR",
        type: _isUrgent
            ? NoticeType.urgent
            : _scope == 'section'
            ? NoticeType.section
            : NoticeType.department,
      );

      await FirestoreService().uploadNotice(item);
        await Onesignal().sendPushNotification(
      _titleCtrl.text.trim(),
      _bodyCtrl.text.trim(),
    );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _attachments.isEmpty
                  ? 'Notice posted successfully!'
                  : 'Notice posted with ${_attachments.length} '
                  'attachment${_attachments.length > 1 ? 's' : ''}!',
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

  // Build

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Notice'),
        centerTitle: false,
        actions: [
          // Admin badge
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ADMIN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Audience summary banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.group_rounded,
                      color: colorScheme.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audience',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          _audienceLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Scope selector
            Text(
              'Post To',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _scopeChip('section', 'Specific Section',
                    Icons.person_rounded, colorScheme),
                _scopeChip('batch', 'Entire Batch',
                    Icons.groups_rounded, colorScheme),
                _scopeChip('department', 'Department',
                    Icons.school_rounded, colorScheme),
                _scopeChip('university', 'University-Wide',
                    Icons.account_balance_rounded, colorScheme),
              ],
            ),

            // Section / Batch pickers
            if (_scope == 'section' || _scope == 'batch') ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Batch',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.xs),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['21', '22', '23', '24'].map((b) {
                              final sel = _selectedBatch == b;
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: AppSpacing.xs),
                                child: ChoiceChip(
                                  label: Text(b),
                                  selected: sel,
                                  onSelected: (_) =>
                                      setState(() => _selectedBatch = b),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_scope == 'section') ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Section',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant)),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: ['A', 'B', 'C', 'D'].map((s) {
                              final sel = _selectedSection == s;
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: AppSpacing.xs),
                                child: ChoiceChip(
                                  label: Text(s),
                                  selected: sel,
                                  onSelected: (_) =>
                                      setState(() => _selectedSection = s),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // Urgent toggle
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
                  color: _isUrgent
                      ? Colors.red
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. Mid-Term Exam Schedule',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => AppValidators.title(v),
            ),
            const SizedBox(height: AppSpacing.md),

            // Body
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
              validator: (v) => AppValidators.bodyText(v),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Attachments header
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
                      color: colorScheme.onSurfaceVariant),
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
                    const Row(
                      children: [
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
                final i   = entry.key;
                final att = entry.value;
                final style = _fileStyle(att.extension);

                return Container(
                  margin:
                  const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(style.icon,
                            color: style.color, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.sm),
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
                      IconButton(
                        onPressed: () => setState(
                                () => _attachments.removeAt(i)),
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
                        : 'Post Notice  •  ${_attachments.length} '
                        'file${_attachments.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Scope chip widget

  Widget _scopeChip(
      String value, String label, IconData icon, ColorScheme cs) {
    final selected = _scope == value;
    return GestureDetector(
      onTap: () => setState(() => _scope = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}