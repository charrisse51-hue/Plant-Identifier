import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_projects/color/app_colors.dart';

import '../Text/about/about_page.dart';
import '../Text/help and support/help_and_support_page.dart';
import '../Text/privacy policy/privacy_policy_page.dart';
import '../Text/terms of use/terms_of_use_page.dart';
import '../welcome/welcome_page.dart';
import 'account_page_model.dart';
import 'edit_account_details_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late AccountPageModel model;

  @override
  void initState() {
    super.initState();
    model = AccountPageModel();
    model.loadUserData();
  }

  void _showPhotoOptionsSheet(BuildContext context, AccountPageModel model) {
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
                    model.pickProfilePhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.image, color: Color(0xFF48CF88)),
                  title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    model.pickProfilePhoto(ImageSource.gallery);
                  },
                ),
                if (model.profileImagePath != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.trash2, color: Color(0xFFEF5350)),
                    title: const Text('Remove Photo', style: TextStyle(color: Color(0xFFEF5350))),
                    onTap: () {
                      Navigator.pop(ctx);
                      model.removeProfilePhoto();
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
    return ChangeNotifierProvider.value(
      value: model,
      child: Consumer<AccountPageModel>(
        builder: (context, model, child) {
          final displayName = (model.firstName.isNotEmpty || model.lastName.isNotEmpty)
              ? "${model.firstName} ${model.lastName}".trim()
              : "";

          return Scaffold(
            backgroundColor: AppColors.surfaceA0,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.surfaceA0,
                elevation: 0,
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    color: AppColors.surfaceA30.withValues(alpha: 0.6),
                    height: 1,
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Profile Header: Avatar 📷, User Name, Email ────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Centered Avatar with Camera Button
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
                                  child: model.profileImagePath != null &&
                                          File(model.profileImagePath!).existsSync()
                                      ? Image.file(
                                          File(model.profileImagePath!),
                                          fit: BoxFit.cover,
                                          width: 96,
                                          height: 96,
                                        )
                                      : Container(
                                          color: model.getRandomDarkColor(),
                                          alignment: Alignment.center,
                                          child: Text(
                                            model.initials,
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
                                  onTap: () => _showPhotoOptionsSheet(context, model),
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
                        const SizedBox(height: 14),

                        // User Name
                        Text(
                          displayName.isNotEmpty ? displayName : "Plant Enthusiast",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // User Email
                        Text(
                          model.emailText.isNotEmpty ? model.emailText : "user@email.com",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Divider ───────────────────────────────────────────────
                  Container(
                    height: 1,
                    color: AppColors.surfaceA30.withValues(alpha: 0.6),
                  ),

                  // ── Gardening Activity Section ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gardening Activity",
                          style: TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatCard(
                              title: "Plants Scanned",
                              count: model.scannedCount,
                              isLoading: model.isLoadingStats,
                            ),
                            _buildStatCard(
                              title: "Plants Owned",
                              count: model.ownedCount,
                              isLoading: model.isLoadingStats,
                            ),
                            _buildStatCard(
                              title: "Plants Saved",
                              count: model.savedCount,
                              isLoading: model.isLoadingStats,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Divider ───────────────────────────────────────────────
                  Container(
                    height: 1,
                    color: AppColors.surfaceA30.withValues(alpha: 0.6),
                  ),

                  // ── Action Items ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildActionTile(
                          icon: LucideIcons.user,
                          title: 'Edit Account Details',
                          onTap: () async {
                            await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditAccountDetailsPage(),
                              ),
                            );
                            await model.loadUserData();
                          },
                        ),
                        _buildActionTile(
                          icon: LucideIcons.info,
                          title: 'About',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AboutPage()),
                          ),
                        ),
                        _buildActionTile(
                          icon: LucideIcons.circleHelp,
                          title: 'Help & Support',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HelpSupportPage()),
                          ),
                        ),
                        _buildActionTile(
                          icon: LucideIcons.fileText,
                          title: 'Terms of Use',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TermsOfUsePage()),
                          ),
                        ),
                        _buildActionTile(
                          icon: LucideIcons.shieldCheck,
                          title: 'Privacy Policy',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                          ),
                        ),
                        _buildActionTile(
                          icon: LucideIcons.logOut,
                          iconColor: const Color(0xFFEF5350),
                          title: 'Log Out',
                          titleColor: const Color(0xFFEF5350),
                          onTap: () async {
                            await model.logout(
                              context,
                              () async {
                                final prefs = await SharedPreferences.getInstance();
                                final rememberedEmail = prefs.getString('remembered_email');
                                final rememberMe = prefs.getBool('remember_me') ?? false;
                                await prefs.clear();
                                if (rememberMe && rememberedEmail != null && rememberedEmail.isNotEmpty) {
                                  await prefs.setBool('remember_me', true);
                                  await prefs.setString('remembered_email', rememberedEmail);
                                }
                              },
                              () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const WelcomePage()),
                                (route) => false,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required bool isLoading,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF19221C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E3D34)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF48CF88),
                    ),
                  )
                : Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      leading: Icon(
        icon,
        color: iconColor ?? Colors.white.withValues(alpha: 0.85),
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.white.withValues(alpha: 0.35),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
