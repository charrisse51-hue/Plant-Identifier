import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_projects/color/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/user_auth_api.dart';

class EditAccountDetailsPage extends StatefulWidget {
  const EditAccountDetailsPage({super.key});

  @override
  State<EditAccountDetailsPage> createState() => _EditAccountDetailsPageState();
}

class _EditAccountDetailsPageState extends State<EditAccountDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  int _userId = 0;
  String _originalEmail = '';
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _showPasswordSection = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _loadInitialUserData();
  }

  Future<void> _loadInitialUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
      _firstNameController.text = prefs.getString('first_name') ?? '';
      _lastNameController.text = prefs.getString('last_name') ?? '';
      _originalEmail = prefs.getString('email') ?? '';
      _emailController.text = _originalEmail;
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_showPasswordSection && _newPasswordController.text.isNotEmpty) {
      if (_currentPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your current password to change password.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New passwords do not match.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final result = await UserAuthApi.updateUserAccount(
      userId: _userId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _originalEmail.isNotEmpty ? _originalEmail : _emailController.text.trim(),
      newEmail: _emailController.text.trim(),
      currentPassword: _showPasswordSection && _currentPasswordController.text.isNotEmpty
          ? _currentPasswordController.text
          : null,
      newPassword: _showPasswordSection && _newPasswordController.text.isNotEmpty
          ? _newPasswordController.text
          : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final user = result['user'];
      final prefs = await SharedPreferences.getInstance();
      if (user is Map<String, dynamic>) {
        await prefs.setString('first_name', user['first_name'] ?? _firstNameController.text.trim());
        await prefs.setString('last_name', user['last_name'] ?? _lastNameController.text.trim());
        await prefs.setString('email', user['email'] ?? _emailController.text.trim());
      } else {
        await prefs.setString('first_name', _firstNameController.text.trim());
        await prefs.setString('last_name', _lastNameController.text.trim());
        await prefs.setString('email', _emailController.text.trim());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account details updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      final errorMsg = result['errors'] is Map
          ? (result['errors']['error'] ?? result['errors']['non_field_errors'] ?? result['message'] ?? 'Failed to update account.')
          : result['message'] ?? 'Failed to update account.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', picked.path);
        setState(() {
          _profileImagePath = picked.path;
        });
      }
    } catch (e) {
      debugPrint('[_EditAccountDetailsPageState] Failed to pick profile photo: $e');
    }
  }

  Future<void> _removeProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    setState(() {
      _profileImagePath = null;
    });
  }

  void _showPhotoOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2621),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.camera, color: Color(0xFF48CF88)),
                  title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickProfilePhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.image, color: Color(0xFF48CF88)),
                  title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickProfilePhoto(ImageSource.gallery);
                  },
                ),
                if (_profileImagePath != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.trash2, color: Color(0xFFEF5350)),
                    title: const Text('Remove Photo', style: TextStyle(color: Color(0xFFEF5350))),
                    onTap: () {
                      Navigator.pop(ctx);
                      _removeProfilePhoto();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = (_firstNameController.text.isNotEmpty || _lastNameController.text.isNotEmpty)
        ? "${_firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : ''}${_lastNameController.text.isNotEmpty ? _lastNameController.text[0].toUpperCase() : ''}"
        : "U";

    return Scaffold(
      backgroundColor: AppColors.surfaceA0,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceA0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Account Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.surfaceA30,
            height: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF48CF88).withValues(alpha: 0.65),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _profileImagePath != null &&
                                  File(_profileImagePath!).existsSync()
                              ? Image.file(
                                  File(_profileImagePath!),
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 96,
                                )
                              : Container(
                                  color: AppColors.primaryDark10,
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showPhotoOptionsSheet,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF19221C),
                                width: 2.5,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.camera,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // First Name Field
                _buildLabel('First Name'),
                TextFormField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hintText: 'Enter your first name',
                    icon: LucideIcons.user,
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter your first name' : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Last Name Field
                _buildLabel('Last Name'),
                TextFormField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hintText: 'Enter your last name',
                    icon: LucideIcons.user,
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter your last name' : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Email Field
                _buildLabel('Email Address'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hintText: 'Enter your email',
                    icon: LucideIcons.mail,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password toggle
                InkWell(
                  onTap: () {
                    setState(() {
                      _showPasswordSection = !_showPasswordSection;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceA10,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceA30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(LucideIcons.keyRound, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _showPasswordSection
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showPasswordSection) ...[
                  const SizedBox(height: 16),
                  _buildLabel('Current Password'),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(
                      hintText: 'Enter current password',
                      icon: LucideIcons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent ? LucideIcons.eyeOff : LucideIcons.eye,
                          color: Colors.white60,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('New Password'),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(
                      hintText: 'Enter new password (min 6 characters)',
                      icon: LucideIcons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? LucideIcons.eyeOff : LucideIcons.eye,
                          color: Colors.white60,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Confirm New Password'),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(
                      hintText: 'Confirm new password',
                      icon: LucideIcons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye,
                          color: Colors.white60,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark10,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.surfaceA50, fontSize: 14),
      filled: true,
      fillColor: AppColors.surfaceA10,
      prefixIcon: Icon(icon, color: AppColors.surfaceA50, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.surfaceA30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryDark10, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
