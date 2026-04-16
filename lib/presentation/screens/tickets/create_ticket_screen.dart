import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/repositories/ticket_repository.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'IT';
  String? _subCategory;
  String _priority = 'medium';
  final List<File> _files = [];
  bool _loading = false;

  final _repo = TicketRepository();

  final _categories = {
    'IT': ['Hardware', 'Software', 'Network', 'Email', 'Access', 'Lainnya'],
    'Facility': ['AC', 'CCTV', 'Kebersihan', 'Lainnya'],
    'HR': ['Cuti', 'Lembur', 'Payroll', 'Lainnya'],
    'Finance': ['Reimbursement', 'Invoice', 'Lainnya'],
  };

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    final f = await ImagePicker().pickImage(source: src, imageQuality: 80, maxWidth: 1920);
    if (f != null) setState(() => _files.add(File(f.path)));
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (r != null) {
      for (final f in r.files) {
        if (f.path != null) setState(() => _files.add(File(f.path!)));
      }
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final t = await _repo.createTicket(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        category: _subCategory ?? _category,
        priority: _priority,
      );
      if (_files.isNotEmpty) {
        for (final f in _files) {
          try {
            final ext = f.path.split('.').last.toLowerCase();
            final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
            final storagePath = '${t.id}/$fileName';
            final bytes = await f.readAsBytes();
            final contentType = _ct(ext);

            // Upload ke Supabase Storage & dapat public URL
            try {
              final fileUrl = await SupabaseService.uploadFile(
                bucket: 'ticket-attachments',
                path: storagePath,
                fileBytes: bytes,
                contentType: contentType,
              );

              // Simpan record ke database via API
              await _repo.saveAttachmentMetadata(
                ticketId: t.id,
                fileUrl: fileUrl,
                fileName: fileName,
                fileType: contentType,
              );
            } catch (uploadError) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Upload gagal: $uploadError'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal upload gambar: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiket berhasil dibuat')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _ct(String ext) {
    const m = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png', 'pdf': 'application/pdf'};
    return m[ext] ?? 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: isDark ? AppTheme.white : AppTheme.black),
          onPressed: () => context.pop(),
        ),
        title: Text('Buat Tiket', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              _Lbl('Judul Tiket', isDark),
              const SizedBox(height: 8),
              _TF(
                ctrl: _title,
                hint: 'Contoh: Printer tidak berfungsi',
                isDark: isDark,
                validator: (v) {
                  if (v == null || v.trim().length < 5) return 'Minimal 5 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Deskripsi
              _Lbl('Deskripsi', isDark),
              const SizedBox(height: 8),
              _TF(
                ctrl: _desc,
                hint: 'Jelaskan masalah secara detail',
                isDark: isDark,
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().length < 10) return 'Minimal 10 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Kategori
              _Lbl('Kategori', isDark),
              const SizedBox(height: 8),
              _Dropdown<String>(
                value: _category,
                isDark: isDark,
                items: _categories.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() { _category = v!; _subCategory = null; }),
              ),
              const SizedBox(height: 12),
              if ((_categories[_category] ?? []).isNotEmpty) ...[
                _Lbl('Sub Kategori', isDark),
                const SizedBox(height: 8),
                _Dropdown<String>(
                  value: _subCategory,
                  isDark: isDark,
                  hint: 'Pilih sub kategori',
                  items: (_categories[_category] ?? []).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _subCategory = v),
                ),
                const SizedBox(height: 18),
              ],

              // Prioritas
              _Lbl('Prioritas', isDark),
              const SizedBox(height: 10),
              Row(
                children: ['low', 'medium', 'high', 'critical'].map((p) {
                  final sel = _priority == p;
                  final color = AppTheme.priorityColor(p);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.priorityBgColor(p, isDark: isDark) : (isDark ? AppTheme.dark1 : AppTheme.surface0),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: sel ? color : (isDark ? AppTheme.dark3 : AppTheme.surface2), width: sel ? 1 : 0.5),
                        ),
                        child: Center(
                          child: Text(
                            AppTheme.priorityLabel(p),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: sel ? color : (isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Lampiran
              _Lbl('Lampiran', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.dark1 : AppTheme.surface0,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _AttachBtn(label: 'Kamera', icon: Icons.camera_alt_outlined, isDark: isDark, onTap: () => _pickImage(ImageSource.camera)),
                        const SizedBox(width: 8),
                        _AttachBtn(label: 'Galeri', icon: Icons.photo_library_outlined, isDark: isDark, onTap: () => _pickImage(ImageSource.gallery)),
                        const SizedBox(width: 8),
                        _AttachBtn(label: 'File', icon: Icons.attach_file_rounded, isDark: isDark, onTap: _pickFile),
                      ],
                    ),
                    if (_files.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_files.length, (i) {
                          final f = _files[i];
                          final isImg = ['jpg', 'jpeg', 'png'].any((e) => f.path.endsWith(e));
                          return Stack(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.dark2 : AppTheme.surface1,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
                                ),
                                child: isImg
                                    ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(f, fit: BoxFit.cover))
                                    : Icon(Icons.insert_drive_file_outlined, size: 28, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(() => _files.removeAt(i)),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(color: AppTheme.priorityHigh, shape: BoxShape.circle),
                                    child: const Icon(Icons.close_rounded, size: 12, color: AppTheme.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.white : AppTheme.black,
                    foregroundColor: isDark ? AppTheme.black : AppTheme.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? AppTheme.black : AppTheme.white))
                      : const Text('Kirim Tiket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Lbl extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Lbl(this.text, this.isDark);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
  );
}

class _TF extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isDark;
  final int maxLines;
  final String? Function(String?)? validator;
  const _TF({required this.ctrl, required this.hint, required this.isDark, this.maxLines = 1, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? AppTheme.dark2 : AppTheme.surface0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppTheme.white : AppTheme.black, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.priorityHigh, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.priorityHigh, width: 1.5)),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T? value;
  final bool isDark;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _Dropdown({required this.value, required this.isDark, required this.items, required this.onChanged, this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark2 : AppTheme.surface0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null ? Text(hint!, style: TextStyle(fontSize: 14, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary)) : null,
          items: items,
          onChanged: onChanged,
          dropdownColor: isDark ? AppTheme.dark2 : AppTheme.surface0,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black),
          isExpanded: true,
        ),
      ),
    );
  }
}

class _AttachBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _AttachBtn({required this.label, required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.dark2 : AppTheme.surface1,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}