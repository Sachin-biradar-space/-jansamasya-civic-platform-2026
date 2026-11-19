import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Screen 5: Report Issue Screen
///
/// Submits civic issue reports to the existing `POST /api/user/report` endpoint
/// using `multipart/form-data` (`title`, `description`, `category`, and optional `image`).
///
/// Note on Location/Area: The existing backend (`userController.createReport`)
/// automatically tags `report.state` and `report.area` from the logged-in user's
/// JWT profile. An optional specific landmark field is appended cleanly into
/// `description` when provided so no unsupported API fields are invented.
class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationNoteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedCategory;
  File? _selectedImage;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _locationNoteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (pickedFile == null) return;

      final lower = pickedFile.path.toLowerCase();
      if (!lower.endsWith('.jpg') &&
          !lower.endsWith('.jpeg') &&
          !lower.endsWith('.png')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a .jpg, .jpeg, or .png image file.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }

      setState(() {
        _selectedImage = File(pickedFile.path);
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to pick image: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final token = authService.token;
    if (token == null || token.isEmpty) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    // Combine optional street/landmark detail into description without
    // inventing unsupported fields in the existing backend schema.
    final rawDescription = _descriptionController.text.trim();
    final locationNote = _locationNoteController.text.trim();
    final finalDescription = locationNote.isNotEmpty
        ? 'Location: $locationNote\n\n$rawDescription'
        : rawDescription;

    try {
      await authService.apiService.createReport(
        token: token,
        title: _titleController.text.trim(),
        description: finalDescription,
        category: _selectedCategory!,
        imageFile: _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Civic issue report submitted successfully!'),
          backgroundColor: Color(0xFF15803D),
        ),
      );

      // Clear form and navigate to My Reports to view the new submission.
      _titleController.clear();
      _locationNoteController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedImage = null;
      });
      Navigator.of(context).pushReplacementNamed('/my-reports');
    } on UnauthorizedException catch (e) {
      await authService.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Failed to submit report. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatTitleCase(String text) {
    if (text.trim().isEmpty) return '';
    return text
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final primaryBlue = Theme.of(context).colorScheme.primary;

    final registeredRegion = [
      if (user?.area != null && user!.area!.isNotEmpty)
        _formatTitleCase(user.area!),
      if (user?.state != null && user!.state.isNotEmpty)
        _formatTitleCase(user.state),
    ].join(', ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Report Civic Issue'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner showing automatic state/area tagging by backend
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registered Region: ${registeredRegion.isNotEmpty ? registeredRegion : 'From Account Profile'}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Your state and area are automatically attached to this report by the server.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _titleController,
                          label: 'Issue Title *',
                          hintText: 'e.g., Large pothole on MG Road near City Mall',
                          prefixIcon: Icons.title,
                          enabled: !_isSubmitting,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an issue title';
                            }
                            if (value.trim().length < 5) {
                              return 'Title should be at least 5 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category dropdown matching backend & web categories
                        const Text(
                          'Category *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          isExpanded: true,
                          hint: const Text(
                            'Select issue category',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.category_outlined,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFD1D5DB),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFD1D5DB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 1.8,
                              ),
                            ),
                          ),
                          items: ApiConfig.reportCategories
                              .map(
                                (cat) => DropdownMenuItem<String>(
                                  value: cat['value'],
                                  child: Text(cat['label']!),
                                ),
                              )
                              .toList(),
                          onChanged: _isSubmitting
                              ? null
                              : (value) =>
                                    setState(() => _selectedCategory = value),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an issue category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _locationNoteController,
                          label: 'Specific Street / Landmark (Optional)',
                          hintText: 'e.g., Opposite Central Bus Stand, Ward 12',
                          prefixIcon: Icons.place_outlined,
                          enabled: !_isSubmitting,
                          helperText:
                              'Included in the report details to help municipal teams locate the issue.',
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _descriptionController,
                          label: 'Detailed Description *',
                          hintText:
                              'Describe the problem, how long it has existed, and any safety concerns...',
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          enabled: !_isSubmitting,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please describe the civic issue';
                            }
                            if (value.trim().length < 10) {
                              return 'Please provide at least 10 characters of detail';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Image Upload Section
                        const Text(
                          'Photo Evidence (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Accepted formats: JPG, JPEG, PNG',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (_selectedImage != null) ...[
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    tooltip: 'Remove photo',
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => setState(
                                            () => _selectedImage = null,
                                          ),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _pickImage(ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_outlined,
                                  size: 19,
                                ),
                                label: const Text('Gallery'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _pickImage(ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 19,
                                ),
                                label: const Text('Camera'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        CustomButton(
                          label: 'Submit Report',
                          icon: Icons.send_outlined,
                          isLoading: _isSubmitting,
                          onPressed: _handleSubmit,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
