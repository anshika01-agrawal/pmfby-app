import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../settings/language_settings_screen.dart';
import '../../../providers/language_provider.dart';
import '../../../localization/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LanguageProvider>(
      builder: (context, authProvider, languageProvider, child) {
        final user = authProvider.currentUser;
        final lang = languageProvider.currentLanguage;
        
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.get('profile', 'profile', lang))),
            body: const Center(child: Text('No user data available')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            slivers: [
              // Profile Header with Gradient
              SliverAppBar(
                expandedHeight: 240,
                floating: false,
                pinned: true,
                backgroundColor: Colors.green.shade700,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.green.shade700,
                          Colors.green.shade500,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.role == 'farmer' 
                              ? '👨‍🌾 ${AppStrings.get('profile', 'farmer', lang)}' 
                              : '👔 ${AppStrings.get('profile', 'official', lang)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Information Card
                      _buildInfoCard(
                        title: AppStrings.get('profile', 'contact_information', lang),
                        icon: Icons.contact_phone,
                        children: [
                          _buildInfoRow(Icons.phone, AppStrings.get('profile', 'phone', lang), user.phone),
                          _buildInfoRow(Icons.email, AppStrings.get('profile', 'email', lang), user.email),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Location/Department Card
                      if (user.role == 'farmer') ...[
                        _buildInfoCard(
                          title: AppStrings.get('profile', 'location_details', lang),
                          icon: Icons.location_on,
                          children: [
                            _buildInfoRow(Icons.home, AppStrings.get('profile', 'village', lang), user.village ?? 'Not specified'),
                            _buildInfoRow(Icons.location_city, AppStrings.get('profile', 'district', lang), user.district ?? 'Not specified'),
                            _buildInfoRow(Icons.map, AppStrings.get('profile', 'state', lang), user.state ?? 'Not specified'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: AppStrings.get('profile', 'farm_information', lang),
                          icon: Icons.agriculture,
                          children: [
                            _buildInfoRow(
                              Icons.landscape,
                              AppStrings.get('profile', 'farm_size', lang),
                              user.farmSize != null ? '${user.farmSize} acres' : 'Not specified',
                            ),
                            _buildInfoRow(
                              Icons.badge,
                              'Aadhaar',
                              user.aadharNumber != null && user.aadharNumber!.length >= 4
                                  ? '****-****-${user.aadharNumber!.substring(user.aadharNumber!.length - 4)}'
                                  : 'Not provided',
                            ),
                            if (user.cropTypes != null && user.cropTypes!.isNotEmpty)
                              _buildChipRow(Icons.eco, 'Crops', user.cropTypes!),
                          ],
                        ),
                      ] else ..[
                        _buildInfoCard(
                          title: AppStrings.get('profile', 'official_details', lang),
                          icon: Icons.work,
                          children: [
                            _buildInfoRow(Icons.badge, 'Official ID', user.officialId ?? 'Not assigned'),
                            _buildInfoRow(Icons.business_center, 'Designation', user.designation ?? 'Not specified'),
                            _buildInfoRow(Icons.business, 'Department', user.department ?? 'Not specified'),
                            _buildInfoRow(Icons.location_city, 'Assigned District', user.assignedDistrict ?? 'Not assigned'),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Statistics Card (for farmers)
                      if (user.role == 'farmer')
                        _buildStatsCard(),

                      const SizedBox(height: 16),

                      // Settings Options
                      _buildInfoCard(
                        title: AppStrings.get('profile', 'settings_support', lang),
                        icon: Icons.settings,
                        children: [
                          _buildActionTile(
                            icon: Icons.edit,
                            title: AppStrings.get('profile', 'edit_profile', lang),
                            subtitle: 'Update your information',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit feature coming soon!')),
                              );
                            },
                          ),
                          _buildActionTile(
                            icon: Icons.lock,
                            title: AppStrings.get('profile', 'change_password', lang),
                            subtitle: 'Update your security settings',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password change coming soon!')),
                              );
                            },
                          ),
                          _buildActionTile(
                            icon: Icons.notifications,
                            title: AppStrings.get('profile', 'notifications', lang),
                            subtitle: 'Manage notification preferences',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notification settings coming soon!')),
                              );
                            },
                          ),
                          _buildActionTile(
                            icon: Icons.language,
                            title: AppStrings.get('actions', 'change_language', lang),
                            subtitle: 'Select your preferred language',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LanguageSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildActionTile(
                            icon: Icons.help_outline,
                            title: AppStrings.get('profile', 'help_support', lang),
                            subtitle: 'Get help and contact support',
                            onTap: () {
                              _showHelpDialog(lang);
                            },
                          ),
                          const Divider(height: 32),
                          _buildActionTile(
                            icon: Icons.logout,
                            title: AppStrings.get('profile', 'logout', lang),
                            subtitle: 'Sign out from your account',
                            isDestructive: true,
                            onTap: () {
                              _showLogoutDialog(lang);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Version Info
                      Center(
                        child: Text(
                          'Krishi Bandhu - PMFBY v2.0.0',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'PMFBY - Pradhan Mantri Fasal Bima Yojana',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(IconData icon, String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.green.shade700),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((crop) => Chip(
              label: Text(
                crop,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              backgroundColor: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<LanguageProvider>(
            builder: (context, langProvider, child) => Text(
              AppStrings.get('profile', 'your_statistics', langProvider.currentLanguage),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('2', 'Active\nClaims', Icons.pending_actions),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildStatItem('5', 'Photos\nTaken', Icons.camera_alt),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildStatItem('8', 'Total\nClaims', Icons.history),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? Colors.red : Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? Colors.red : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.get('profile', 'help_support', lang),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Helpline'),
              subtitle: const Text('1800-123-4567 (Toll Free)'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.green),
              title: const Text('Email'),
              subtitle: const Text('support@krashibandhu.gov.in'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.green),
              title: const Text('Website'),
              subtitle: const Text('www.pmfby.gov.in'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('dashboard', 'close', lang)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.get('profile', 'logout', lang),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(AppStrings.get('profile', 'are_you_sure_logout', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('profile', 'cancel', lang)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppStrings.get('profile', 'logout', lang)),
          ),
        ],
      ),
    );
  }
}
