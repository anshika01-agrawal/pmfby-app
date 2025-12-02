import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firebase_auth_service.dart';
import 'language_settings_screen.dart';

class OfficerSettingsScreen extends StatefulWidget {
  const OfficerSettingsScreen({super.key});

  @override
  State<OfficerSettingsScreen> createState() => _OfficerSettingsScreenState();
}

class _OfficerSettingsScreenState extends State<OfficerSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _darkMode = false;
  bool _biometricAuth = false;
  String _defaultView = 'dashboard';
  String _reportFrequency = 'weekly';
  bool _showTutorials = true;
  
  // Profile editing state
  bool _isEditingProfile = false;
  final _nameController = TextEditingController(text: 'Officer Name');
  final _emailController = TextEditingController(text: 'officer@pmfby.gov.in');
  final _phoneController = TextEditingController(text: '+91 9876543210');
  
  @override
  void initState() {
    super.initState();
    // Load current theme state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        _darkMode = themeProvider.isDarkMode;
      });
    });
  }
  
  @override
  void initState() {
    super.initState();
    // Load current theme state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        _darkMode = themeProvider.isDarkMode;
      });
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Officer Settings',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.indigo.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showHelpDialog(context),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.indigo.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildProfileSection(),
                  const SizedBox(height: 24),

                  // System Settings
                  _buildSettingSection(
                    'System Settings',
                    Icons.settings,
                    [
                      _buildSwitchTile(
                        'Dark Mode',
                        'Switch to dark theme',
                        Icons.dark_mode,
                        _darkMode,
                        (value) async {
                          setState(() => _darkMode = value);
                          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                          await themeProvider.setThemeMode(value);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value ? 'Dark mode enabled' : 'Light mode enabled',
                                ),
                                backgroundColor: value ? Colors.grey.shade800 : Colors.green.shade700,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      _buildListTile(
                        'Language',
                        'Change application language',
                        Icons.language,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageSettingsScreen(),
                          ),
                        ),
                      ),
                      _buildDropdownTile(
                        'Default View',
                        'Set startup screen',
                        Icons.home,
                        _defaultView,
                        {
                          'dashboard': 'Dashboard',
                          'claims': 'Claims',
                          'analytics': 'Analytics',
                          'reports': 'Reports',
                        },
                        (value) => setState(() => _defaultView = value!),
                      ),
                      _buildSwitchTile(
                        'Show Tutorials',
                        'Display help tutorials',
                        Icons.school,
                        _showTutorials,
                        (value) => setState(() => _showTutorials = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notification Settings
                  _buildSettingSection(
                    'Notifications',
                    Icons.notifications,
                    [
                      _buildSwitchTile(
                        'Push Notifications',
                        'Receive app notifications',
                        Icons.notifications_active,
                        _notificationsEnabled,
                        (value) => setState(() => _notificationsEnabled = value),
                      ),
                      _buildSwitchTile(
                        'Email Notifications',
                        'Get updates via email',
                        Icons.email,
                        _emailNotifications,
                        (value) => setState(() => _emailNotifications = value),
                      ),
                      _buildSwitchTile(
                        'SMS Notifications',
                        'Receive SMS alerts',
                        Icons.sms,
                        _smsNotifications,
                        (value) => setState(() => _smsNotifications = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Workflow Settings
                  _buildSettingSection(
                    'Workflow Settings',
                    Icons.work_outline,
                    [
                      _buildDropdownTile(
                        'Report Frequency',
                        'How often to generate reports',
                        Icons.schedule,
                        _reportFrequency,
                        {
                          'daily': 'Daily',
                          'weekly': 'Weekly',
                          'monthly': 'Monthly',
                        },
                        (value) => setState(() => _reportFrequency = value!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Security Settings
                  _buildSettingSection(
                    'Security',
                    Icons.security,
                    [
                      _buildSwitchTile(
                        'Biometric Authentication',
                        'Use fingerprint/face unlock',
                        Icons.fingerprint,
                        _biometricAuth,
                        (value) => setState(() => _biometricAuth = value),
                      ),
                      _buildListTile(
                        'Change Password',
                        'Update your password',
                        Icons.lock,
                        () => _showChangePasswordDialog(context),
                      ),
                      _buildListTile(
                        'Session Management',
                        'Manage active sessions',
                        Icons.devices,
                        () => _showSessionsDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Data & Privacy
                  _buildSettingSection(
                    'Data & Privacy',
                    Icons.privacy_tip,
                    [
                      _buildListTile(
                        'Export Data',
                        'Download your data',
                        Icons.download,
                        () => _exportData(),
                      ),
                      _buildListTile(
                        'Privacy Policy',
                        'View privacy policy',
                        Icons.policy,
                        () => _showPrivacyPolicy(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.indigo.shade100,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.indigo.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _isEditingProfile ? _buildEditableProfile() : _buildStaticProfile(),
              ),
              IconButton(
                onPressed: _toggleEditProfile,
                icon: Icon(
                  _isEditingProfile ? Icons.check : Icons.edit,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
          if (_isEditingProfile) ..[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelEditProfile,
                    child: Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                    ),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.indigo.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo.shade600),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.roboto(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.indigo.shade700,
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo.shade600),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.roboto(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo.shade600),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.roboto(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.indigo.shade600),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Text(
              '₹${value.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade700,
              ),
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 20,
            activeColor: Colors.indigo.shade700,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save Settings',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetSettings,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.indigo.shade700,
              side: BorderSide(color: Colors.indigo.shade700),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset to Defaults',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Profile editing methods
  Widget _buildStaticProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _nameController.text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          'District Officer, Ludhiana',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          _emailController.text,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          _phoneController.text,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableProfile() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Officer Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  void _toggleEditProfile() {
    setState(() {
      _isEditingProfile = !_isEditingProfile;
    });
  }

  void _cancelEditProfile() {
    setState(() {
      _isEditingProfile = false;
      // Reset controllers to original values
      _nameController.text = 'Officer Name';
      _emailController.text = 'officer@pmfby.gov.in';
      _phoneController.text = '+91 9876543210';
    });
  }

  void _saveProfile() {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter officer name'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter email address'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter phone number'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    
    setState(() {
      _isEditingProfile = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _editProfile() {
    setState(() {
      _isEditingProfile = true;
    });
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _notificationsEnabled = true;
      _emailNotifications = true;
      _smsNotifications = false;
      _darkMode = false;
      _biometricAuth = false;
      _defaultView = 'dashboard';
      _reportFrequency = 'weekly';
      _showTutorials = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings reset to defaults!'),
        backgroundColor: Colors.orange.shade700,
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data export started. You will receive an email when ready.'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: Text('Privacy policy content will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.indigo.shade700),
            SizedBox(width: 8),
            Text('Settings Help'),
          ],
        ),
        content: Text(
          'This page allows you to customize your officer dashboard experience. '
          'Change notification preferences, workflow settings, and security options to '
          'match your working style.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password changed successfully!')),
              );
            },
            child: Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showSessionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Active Sessions'),
        content: Text('Session management feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}