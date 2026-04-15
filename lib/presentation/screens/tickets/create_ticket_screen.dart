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
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _category = 'IT';
  String _priority = 'medium';
  final List<File> _files = [];
  bool _loading = false;
  bool _uploading = false;
  final _repo = TicketRepository();

  final Map<String, List<String>> _categories = {
    'IT': ['Hardware', 'Software', 'Network', 'Email', 'Access', 'Lainnya'],
    'Facility': ['AC', 'CCTV', 'Kebersihan', 'Lainnya'],
    'HR': ['Cuti', 'Lembur', 'Payroll', 'Lainnya'],
    'Finance': ['Reimbursement', 'Invoice', 'Lainnya'],
  };

  final Map<String, String> _priorityLabels = {
    'low': 'Rendah',
    'medium': 'Sedang',
    'high': 'Tinggi',
    'critical': 'Kritis',
  };

  final Map<String, Color> _priorityColors = {
    'low': Colors.green,
    'medium': Colors.orange,
    'high': Colors.red,
    'critical': const Color(0xFF7F1D1D),
  };

  String? _subCategory;

  List<String> get _subCategories => _categories[_category] ?? [];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (file != null) {
      setState(() => _files.add(File(file.path)));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      for (final file in result.files) {
        if (file.path != null) {
          setState(() => _files.add(File(file.path!)));
        }
      }
    }
  }

  Future<List<String>> _uploadFiles(String ticketId) async {
    final urls = <String>[];
    setState(() => _uploading = true);

    for (final file in _files) {
      try {
        final extension = file.path.split('.').last.toLowerCase();
        final fileName = '$ticketId/${DateTime.now().millisecondsSinceEpoch}.$extension';

        final bytes = await file.readAsBytes();
        final url = await SupabaseService.uploadFile(
          bucket: 'ticket-attachments',
          path: fileName,
          fileBytes: bytes,
          contentType: _getContentType(extension),
        );
        urls.add(url);
      } catch (e) {
        debugPrint('Upload error: $e');
      }
    }

    setState(() => _uploading = false);
    return urls;
  }

  String _getContentType(String extension) {
    const types = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    };
    return types[extension] ?? 'application/octet-stream';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // Create ticket
      final ticket = await _repo.createTicket(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _subCategory ?? _category,
        priority: _priority,
      );

      // Upload attachments
      if (_files.isNotEmpty) {
        await _uploadFiles(ticket.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil dibuat'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat tiket: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tiket Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Judul Tiket *',
                  prefixIcon: Icon(Icons.title),
                  hintText: 'Contoh: Printer lantai 2 tidak berfungsi',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                  if (v.trim().length < 5) return 'Minimal 5 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Masalah *',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Jelaskan masalah secara detail',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Deskripsi wajib diisi';
                  if (v.trim().length < 10) return 'Minimal 10 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location (Optional)
              TextFormField(
                controller: _locationCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'Contoh: Lantai 2, Ruang Meeting',
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori Utama *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  setState(() {
                    _category = v!;
                    _subCategory = null;
                  });
                },
              ),
              const SizedBox(height: 8),

              // Sub Category
              if (_subCategories.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _subCategory,
                  decoration: const InputDecoration(
                    labelText: 'Sub Kategori *',
                    prefixIcon: Icon(Icons.subdirectory_arrow_left),
                  ),
                  items: _subCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _subCategory = v),
                  validator: (v) => v == null ? 'Pilih sub kategori' : null,
                ),
                const SizedBox(height: 16),
              ],

              // Priority
              const Text('Prioritas', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _priorityLabels.entries.map((entry) {
                  final key = entry.key;
                  final label = entry.value;
                  final color = _priorityColors[key] ?? Colors.grey;
                  return ChoiceChip(
                    label: Text(label),
                    selected: _priority == key,
                    selectedColor: color.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _priority == key ? color : AppTheme.textSecondaryColor,
                      fontWeight: _priority == key ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: color),
                    onSelected: (_) => setState(() => _priority = key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Attachments Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lampiran (Opsional)', style: TextStyle(fontWeight: FontWeight.w500)),
                        if (_files.isNotEmpty)
                          Text('${_files.length} file', style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _loading || _uploading ? null : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Kamera'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(90, 36)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _loading || _uploading ? null : () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Galeri'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(90, 36)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _loading || _uploading ? null : _pickFile,
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text('File'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(90, 36)),
                        ),
                      ],
                    ),
                    if (_files.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _files.length,
                          itemBuilder: (_, i) {
                            final file = _files[i];
                            final isImage = file.path.endsWith('.jpg') ||
                                file.path.endsWith('.jpeg') ||
                                file.path.endsWith('.png');
                            return Container(
                              width: 90,
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: isImage
                                          ? Image.file(file, fit: BoxFit.cover, width: 88, height: 88)
                                          : Container(
                                              width: 88,
                                              height: 88,
                                              padding: const EdgeInsets.all(8),
                                              child: Center(
                                                child: Text(
                                                  file.path.split('/').last,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 10),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeFile(i),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: (_loading || _uploading) ? null : _submit,
                child: _uploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Mengunggah...'),
                        ],
                      )
                    : _loading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Memproses...'),
                            ],
                          )
                        : const Text('Kirim Tiket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
