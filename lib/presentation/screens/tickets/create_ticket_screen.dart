import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_card.dart';

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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Tiket berhasil dibuat',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: ModernTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gagal membuat tiket: $e',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: ModernTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
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
              // Info Card
              InfoCard(
                title: 'Informasi Tiket',
                description: 'Lengkapi formulir di bawah untuk membuat tiket bantuan',
                icon: Icons.info_outline,
                iconColor: ModernTheme.info,
              ),
              const SizedBox(height: 24),

              // Title
              AppInput(
                controller: _titleCtrl,
                label: 'Judul Tiket *',
                hint: 'Contoh: Printer lantai 2 tidak berfungsi',
                prefixIcon: Icons.title_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                  if (v.trim().length < 5) return 'Minimal 5 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              AppInput(
                controller: _descCtrl,
                label: 'Deskripsi Masalah *',
                hint: 'Jelaskan masalah secara detail',
                prefixIcon: Icons.description_outlined,
                type: AppInputType.multiline,
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Deskripsi wajib diisi';
                  if (v.trim().length < 10) return 'Minimal 10 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location (Optional)
              AppInput(
                controller: _locationCtrl,
                label: 'Lokasi',
                hint: 'Contoh: Lantai 2, Ruang Meeting',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              // Category
              AppDropdown<String>(
                label: 'Kategori Utama *',
                hint: 'Pilih kategori',
                initialValue: _category,
                prefixIcon: Icons.category_rounded,
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
                AppDropdown<String>(
                  label: 'Sub Kategori *',
                  hint: 'Pilih sub kategori',
                  initialValue: _subCategory,
                  prefixIcon: Icons.subdirectory_arrow_left_rounded,
                  items: _subCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _subCategory = v),
                  validator: (v) => v == null ? 'Pilih sub kategori' : null,
                ),
                const SizedBox(height: 16),
              ],

              // Priority
              const Text(
                'Prioritas',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _priorityLabels.entries.map((entry) {
                  final key = entry.key;
                  final label = entry.value;
                  final isSelected = _priority == key;
                  final color = ModernTheme.getPriorityColor(key);
                  return InkWell(
                    onTap: () => setState(() => _priority = key),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color : ModernTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: color,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPriorityIcon(key),
                            size: 16,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Attachments Section
              _buildAttachmentsSection(),
              const SizedBox(height: 24),

              // Submit Button
              AppButton(
                text: _uploading ? 'Mengunggah...' : _loading ? 'Memproses...' : 'Kirim Tiket',
                onPressed: (_loading || _uploading) ? null : _submit,
                isLoading: _loading || _uploading,
                isGradient: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ModernTheme.stone200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lampiran',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                ),
              ),
              if (_files.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ModernTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_files.length} file',
                    style: GoogleFonts.plusJakartaSans(
                      color: ModernTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan gambar atau dokumen terkait',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: ModernTheme.stone500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_loading || _uploading) ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: Text(
                    'Kamera',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_loading || _uploading) ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(
                    'Galeri',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_loading || _uploading) ? null : _pickFile,
                  icon: const Icon(Icons.attach_file_rounded, size: 18),
                  label: Text(
                    'File',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_files.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
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
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: ModernTheme.stone300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
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
                                        style: GoogleFonts.plusJakartaSans(fontSize: 10),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removeFile(i),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: ModernTheme.error,
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
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'low':
        return Icons.arrow_downward_rounded;
      case 'medium':
        return Icons.remove_rounded;
      case 'high':
        return Icons.arrow_upward_rounded;
      case 'critical':
        return Icons.priority_high_rounded;
      default:
        return Icons.help_outline;
    }
  }
}
