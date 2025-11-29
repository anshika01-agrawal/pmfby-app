import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/user_profile.dart';
import 'package:intl/intl.dart';

enum OfficerLevel {
  national,
  state,
  district,
}

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  int _selectedIndex = 0;
  OfficerLevel _officerLevel = OfficerLevel.district; // Demo: District officer
  String _selectedState = 'Punjab';
  String _selectedDistrict = 'Ludhiana';

  // Demo statistics data
  final Map<String, dynamic> _stats = {
    'total_claims': 1247,
    'pending_claims': 342,
    'approved_claims': 785,
    'rejected_claims': 120,
    'total_farmers': 5680,
    'active_policies': 4532,
    'total_premium': 125400000,
    'total_payout': 89500000,
    'crop_loss_reports': 456,
    'pending_assessments': 89,
    'avg_claim_time': 12.5, // days
    'approval_rate': 86.5, // percentage
  };

  final List<Map<String, dynamic>> _recentClaims = [
    {
      'id': 'CLM2024001',
      'farmer': 'Ram Singh',
      'crop': 'Wheat',
      'amount': 45000,
      'status': 'pending',
      'date': DateTime(2024, 11, 20),
      'district': 'Ludhiana',
    },
    {
      'id': 'CLM2024002',
      'farmer': 'Sita Devi',
      'crop': 'Rice',
      'amount': 68000,
      'status': 'approved',
      'date': DateTime(2024, 11, 19),
      'district': 'Ludhiana',
    },
    {
      'id': 'CLM2024003',
      'farmer': 'Mohan Kumar',
      'crop': 'Cotton',
      'amount': 32000,
      'status': 'under_review',
      'date': DateTime(2024, 11, 18),
      'district': 'Patiala',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildOverviewScreen(),
      _buildClaimsManagementScreen(),
      _buildAnalyticsScreen(),
      _buildReportsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Claims',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewScreen() {
    return Container(
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
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: Colors.indigo.shade700,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Officer Dashboard',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getOfficerLevelText(),
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.indigo.shade700,
                        Colors.indigo.shade500,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: 20,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _getLocationText(),
                              style: GoogleFonts.roboto(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _showLevelSelector,
                              icon: const Icon(Icons.tune, color: Colors.white, size: 16),
                              label: Text(
                                'Change',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),

            // Quick Stats Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Metrics',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          'Total Claims',
                          _stats['total_claims'].toString(),
                          Icons.assignment,
                          Colors.blue,
                          '+12% from last month',
                        ),
                        _buildStatCard(
                          'Pending Claims',
                          _stats['pending_claims'].toString(),
                          Icons.pending_actions,
                          Colors.orange,
                          'Requires attention',
                        ),
                        _buildStatCard(
                          'Active Farmers',
                          _stats['total_farmers'].toString(),
                          Icons.people,
                          Colors.green,
                          '${_stats['active_policies']} policies',
                        ),
                        _buildStatCard(
                          'Approval Rate',
                          '${_stats['approval_rate']}%',
                          Icons.check_circle,
                          Colors.purple,
                          'Industry average: 82%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Weather & Satellite Section (Placeholder)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Environmental Monitoring',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWeatherPlaceholder(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSatellitePlaceholder(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recent Claims
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Claims',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _selectedIndex = 1),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._recentClaims.take(3).map((claim) => _buildClaimCard(claim)),
                  ],
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'Review Claims',
                            Icons.rate_review,
                            Colors.blue,
                            () => setState(() => _selectedIndex = 1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            'View Analytics',
                            Icons.bar_chart,
                            Colors.purple,
                            () => setState(() => _selectedIndex = 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'Export Report',
                            Icons.file_download,
                            Colors.green,
                            () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            'Field Inspection',
                            Icons.location_searching,
                            Colors.orange,
                            () {},
                          ),
                        ),
                      ],
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

  Widget _buildClaimsManagementScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Claims Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.grey.shade100,
            child: Row(
              children: [
                _buildFilterChip('All', _stats['total_claims']),
                _buildFilterChip('Pending', _stats['pending_claims']),
                _buildFilterChip('Approved', _stats['approved_claims']),
                _buildFilterChip('Rejected', _stats['rejected_claims']),
              ],
            ),
          ),

          // Claims List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recentClaims.length,
              itemBuilder: (context, index) {
                return _buildDetailedClaimCard(_recentClaims[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Period Selector
            Row(
              children: [
                Text(
                  'Period: ',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Week'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Month'),
                  selected: false,
                  onSelected: (selected) {},
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Year'),
                  selected: false,
                  onSelected: (selected) {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Claims Trend Chart Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Claims Trend Chart',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Chart library integration pending',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Crop-wise Distribution
            Text(
              'Crop-wise Claims Distribution',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCropDistributionCard('Wheat', 345, Colors.amber),
            _buildCropDistributionCard('Rice', 289, Colors.green),
            _buildCropDistributionCard('Cotton', 198, Colors.blue),
            _buildCropDistributionCard('Sugarcane', 156, Colors.orange),
            _buildCropDistributionCard('Others', 259, Colors.grey),

            const SizedBox(height: 24),

            // Performance Metrics
            Text(
              'Performance Metrics',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Avg. Processing Time',
                    '${_stats['avg_claim_time']} days',
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Total Payout',
                    '₹${(_stats['total_payout'] / 10000000).toStringAsFixed(1)}Cr',
                    Icons.currency_rupee,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports & Export',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            'Monthly Claims Report',
            'Complete claims data for the month',
            Icons.calendar_month,
            Colors.blue,
          ),
          _buildReportCard(
            'Financial Summary',
            'Premium and payout statistics',
            Icons.account_balance,
            Colors.green,
          ),
          _buildReportCard(
            'Farmer Database',
            'Complete farmer registry',
            Icons.people,
            Colors.orange,
          ),
          _buildReportCard(
            'Crop Loss Analysis',
            'Detailed loss assessment reports',
            Icons.agriculture,
            Colors.red,
          ),
          _buildReportCard(
            'Performance Dashboard',
            'Officer and department metrics',
            Icons.assessment,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  // Helper Widgets

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Weather API',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Integration Pending',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time weather data',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatellitePlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.satellite_alt, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Satellite API',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Integration Pending',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crop monitoring data',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim) {
    Color statusColor = _getStatusColor(claim['status']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.assignment, color: statusColor),
        ),
        title: Text(
          claim['farmer'],
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${claim['crop']} • ₹${claim['amount']}',
          style: GoogleFonts.roboto(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            _getStatusLabel(claim['status']),
            style: GoogleFonts.roboto(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
        onTap: () => _showClaimDetails(claim),
      ),
    );
  }

  Widget _buildDetailedClaimCard(Map<String, dynamic> claim) {
    Color statusColor = _getStatusColor(claim['status']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  claim['id'],
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _getStatusLabel(claim['status']),
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  claim['farmer'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.agriculture, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('Crop: ${claim['crop']}', style: GoogleFonts.roboto(fontSize: 13)),
                const SizedBox(width: 16),
                Icon(Icons.currency_rupee, size: 14, color: Colors.grey.shade600),
                Text('₹${claim['amount']}', style: GoogleFonts.roboto(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('${claim['district']}', style: GoogleFonts.roboto(fontSize: 13)),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy').format(claim['date']),
                  style: GoogleFonts.roboto(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showClaimDetails(claim),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.rate_review, size: 16),
                    label: const Text('Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: FilterChip(
          label: Text('$label ($count)'),
          selected: false,
          onSelected: (selected) {},
        ),
      ),
    );
  }

  Widget _buildCropDistributionCard(String crop, int count, Color color) {
    final total = _stats['total_claims'];
    final percentage = (count / total * 100).toStringAsFixed(1);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.agriculture, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: count / total,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$percentage%',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: GoogleFonts.roboto(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {},
        ),
      ),
    );
  }

  // Helper Methods

  String _getOfficerLevelText() {
    switch (_officerLevel) {
      case OfficerLevel.national:
        return 'National Level Officer';
      case OfficerLevel.state:
        return 'State Level Officer';
      case OfficerLevel.district:
        return 'District Level Officer';
    }
  }

  String _getLocationText() {
    switch (_officerLevel) {
      case OfficerLevel.national:
        return 'All India';
      case OfficerLevel.state:
        return _selectedState;
      case OfficerLevel.district:
        return '$_selectedDistrict, $_selectedState';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under Review';
      default:
        return 'Unknown';
    }
  }

  void _showLevelSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Officer Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<OfficerLevel>(
              title: const Text('National Level'),
              subtitle: const Text('View all India data'),
              value: OfficerLevel.national,
              groupValue: _officerLevel,
              onChanged: (value) {
                setState(() => _officerLevel = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<OfficerLevel>(
              title: const Text('State Level'),
              subtitle: const Text('View state-specific data'),
              value: OfficerLevel.state,
              groupValue: _officerLevel,
              onChanged: (value) {
                setState(() => _officerLevel = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<OfficerLevel>(
              title: const Text('District Level'),
              subtitle: const Text('View district-specific data'),
              value: OfficerLevel.district,
              groupValue: _officerLevel,
              onChanged: (value) {
                setState(() => _officerLevel = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Claims'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Claims'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Pending Only'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Approved Only'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Rejected Only'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showClaimDetails(Map<String, dynamic> claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Claim Details',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text('Claim ID: ${claim['id']}', style: GoogleFonts.roboto()),
              Text('Farmer: ${claim['farmer']}', style: GoogleFonts.roboto()),
              Text('Crop: ${claim['crop']}', style: GoogleFonts.roboto()),
              Text('Amount: ₹${claim['amount']}', style: GoogleFonts.roboto()),
              Text('District: ${claim['district']}', style: GoogleFonts.roboto()),
              Text(
                'Date: ${DateFormat('dd MMM yyyy').format(claim['date'])}',
                style: GoogleFonts.roboto(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.indigo.shade700,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
