import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_profile.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/auto_sync_service.dart';
import '../../claims/claims_list_screen.dart';
import '../../schemes/schemes_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../satellite/satellite_monitoring_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  UserProfile? _userProfile;
  bool _isLoading = true;
  int _pendingUploadsCount = 0;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _loadPendingUploads();
      _startAutoSync();
    });
  }

  void _startAutoSync() {
    final autoSyncService = context.read<AutoSyncService>();
    final connectivityService = context.read<ConnectivityService>();
    autoSyncService.startPeriodicSync(connectivityService);
  }

  @override
  void dispose() {
    final autoSyncService = context.read<AutoSyncService>();
    autoSyncService.stopPeriodicSync();
    super.dispose();
  }

  Future<void> _loadPendingUploads() async {
    final count = await _localStorageService.getPendingUploadsCount();
    if (mounted) {
      setState(() => _pendingUploadsCount = count);
    }
  }

  Future<void> _loadUserProfile() async {
    final authService = context.read<FirebaseAuthService>();
    final firestoreService = FirestoreService();
    
    if (authService.currentUser != null) {
      final profile = await firestoreService.getUserProfile(
        authService.currentUser!.uid,
      );
      
      // If profile doesn't exist, create a default one with Anshika's details
      if (profile == null) {
        final newProfile = UserProfile(
          uid: authService.currentUser!.uid,
          name: 'Anshika',
          phoneNumber: authService.currentUser!.phoneNumber ?? '',
          email: 'anshika@krashibandhu.in',
          village: 'Jaitpur',
          district: 'Barabanki',
          state: 'Uttar Pradesh',
          crops: ['धान (Rice)', 'गेहूं (Wheat)', 'गन्ना (Sugarcane)'],
          landAreaAcres: 5.0,
        );
        await firestoreService.createUserProfile(newProfile);
        setState(() {
          _userProfile = newProfile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeScreen(),
      const ClaimsListScreen(),
      const SchemesScreen(),
      const SatelliteMonitoringScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer Support FAB
                FloatingActionButton(
                  heroTag: 'support',
                  onPressed: _showHelpDialog,
                  backgroundColor: Colors.blue.shade700,
                  child: const Icon(Icons.support_agent, size: 28),
                ),
                const SizedBox(height: 12),
                // Camera FAB
                FloatingActionButton.extended(
                  heroTag: 'camera',
                  onPressed: () => context.push('/camera'),
                  label: const Text('Capture Image'),
                  icon: const Icon(Icons.camera_alt_rounded),
                  backgroundColor: Colors.green.shade700,
                ),
              ],
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF138808),
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          backgroundColor: Colors.white,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'होम',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'दावे',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: 'योजनाएं',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.satellite_outlined),
            activeIcon: Icon(Icons.satellite),
            label: 'उपग्रह',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'प्रोफाइल',
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF138808),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PMFBY',
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'प्रधानमंत्री फसल बीमा योजना',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF9933),
                        const Color(0xFFFFFFFF),
                        const Color(0xFF138808),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Icon(
                          Icons.agriculture,
                          size: 200,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 80, right: 16, bottom: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'नमस्ते, ${_userProfile?.name ?? "किसान"} 🙏',
                              style: GoogleFonts.notoSans(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'आज का मौसम: धूप ☀️',
                              style: GoogleFonts.notoSans(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Offline Indicator Banner
            SliverToBoxAdapter(
              child: Consumer<ConnectivityService>(
                builder: (context, connectivityService, child) {
                  if (connectivityService.isOnline) {
                    return const SizedBox.shrink();
                  }
                  
                  return Material(
                    color: Colors.orange.shade600,
                    child: InkWell(
                      onTap: () => context.push('/upload-status'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ऑफलाइन मोड',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _pendingUploadsCount > 0
                                        ? '$_pendingUploadsCount फोटो सिंक के लिए बाकी'
                                        : 'इंटरनेट से कनेक्ट होने पर डेटा सिंक होगा',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '5.0 एकड़',
                        'कुल भूमि',
                        Icons.landscape,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '3',
                        'फसलें',
                        Icons.eco,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '2',
                        'सक्रिय दावे',
                        Icons.pending_actions,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Action Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push('/capture-image'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'फसल की फोटो लें',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Capture Crop Image with GPS',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // PMFBY Info Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: InkWell(
                  onTap: () => context.push('/pmfby-info'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9933), Color(0xFF138808)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PMFBY के बारे में जानें',
                                style: GoogleFonts.notoSansDevanagari(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'योजना, प्रीमियम, हेल्पलाइन नंबर',
                                style: GoogleFonts.notoSansDevanagari(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions Grid
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _buildActionCard(
                    'नया दावा दर्ज करें',
                    'File New Claim',
                    Icons.add_circle_outline,
                    Colors.blue,
                    () => context.push('/file-claim'),
                  ),
                  _buildActionCard(
                    'मेरे दावे',
                    'My Claims',
                    Icons.history,
                    Colors.orange,
                    () => context.push('/claims'),
                  ),
                  _buildActionCard(
                    'बीमा योजनाएं',
                    'Insurance Schemes',
                    Icons.policy,
                    Colors.purple,
                    () => setState(() => _selectedIndex = 2),
                  ),
                  _buildActionCardWithBadge(
                    'अपलोड स्टेटस',
                    'Upload Status',
                    Icons.cloud_upload,
                    Colors.indigo,
                    () => context.push('/upload-status'),
                    _pendingUploadsCount,
                  ),
                  _buildActionCard(
                    'फसल नुकसान सूचना',
                    'Crop Loss Intimation',
                    Icons.report_problem,
                    Colors.red.shade700,
                    () => context.push('/crop-loss-intimation'),
                  ),
                  _buildActionCard(
                    'प्रीमियम कैलकुलेटर',
                    'Premium Calculator',
                    Icons.calculate_outlined,
                    Colors.green.shade600,
                    () => context.push('/premium-calculator'),
                  ),
                  _buildActionCard(
                    'मदद केंद्र',
                    'Help Center',
                    Icons.help_outline,
                    Colors.teal,
                    () => _showHelpDialog(),
                  ),
                ]),
              ),
            ),

            // Recent Activity
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'हाल की गतिविधि (Recent Activity)',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivityTile(
                      'फोटो अपलोड की गई',
                      '2 घंटे पहले',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildActivityTile(
                      'AI विश्लेषण पूर्ण',
                      '3 घंटे पहले',
                      Icons.analytics,
                      Colors.blue,
                    ),
                    _buildActivityTile(
                      'दावा स्वीकृत',
                      '1 दिन पहले',
                      Icons.verified,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String titleHindi,
    String titleEnglish,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                titleHindi,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                titleEnglish,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCardWithBadge(
    String titleHindi,
    String titleEnglish,
    IconData icon,
    Color color,
    VoidCallback onTap,
    int badgeCount,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                titleHindi,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                titleEnglish,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.support_agent, color: Colors.green.shade700, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ग्राहक सहायता',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Customer Support',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            
            // Phone Support Card
            InkWell(
              onTap: () => _makePhoneCall('14447'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'कृषि रक्षक पोर्टल',
                            style: GoogleFonts.notoSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Call 14447',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Toll-Free Helpline',
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue.shade700,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // WhatsApp Support Card
            InkWell(
              onTap: () => _openWhatsApp('7065514447'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366), // WhatsApp green
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PMFBY व्हाट्सएप चैटबॉट',
                            style: GoogleFonts.notoSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chat: 7065514447',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'WhatsApp Support',
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green.shade700,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Additional Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.amber.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'सेवा समय: सोमवार-शुक्रवार, 9 AM - 6 PM\nService Hours: Monday-Friday, 9 AM - 6 PM',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'बंद करें',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('कॉल नहीं की जा सकती: $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('त्रुटि: कॉल करने में विफल'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // WhatsApp URL with country code
    final String whatsappUrl = 'https://wa.me/91$phoneNumber';
    final Uri whatsappUri = Uri.parse(whatsappUrl);
    
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('व्हाट्सएप खोलने में विफल'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('त्रुटि: व्हाट्सएप खोलने में विफल'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
