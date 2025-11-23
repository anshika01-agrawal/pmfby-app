import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/insurance_claim.dart';

class ClaimsListScreen extends StatefulWidget {
  const ClaimsListScreen({super.key});

  @override
  State<ClaimsListScreen> createState() => _ClaimsListScreenState();
}

class _ClaimsListScreenState extends State<ClaimsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Demo claims data - in production, fetch from Firebase/MongoDB
  List<InsuranceClaim> _getDemoClaims(String status) {
    final now = DateTime.now();
    
    if (status == 'active') {
      return [
        InsuranceClaim(
          id: 'CLM001',
          farmerId: 'F001',
          farmerName: 'राज कुमार',
          cropType: 'गेहूं (Wheat)',
          damageReason: 'बाढ़ (Flood)',
          description: 'भारी बारिश के कारण खेत में पानी भर गया',
          imageUrls: [],
          estimatedLossPercentage: 65,
          claimAmount: 45000,
          status: ClaimStatus.underReview,
          incidentDate: now.subtract(const Duration(days: 15)),
          submittedAt: now.subtract(const Duration(days: 12)),
        ),
        InsuranceClaim(
          id: 'CLM002',
          farmerId: 'F001',
          farmerName: 'राज कुमार',
          cropType: 'धान (Rice)',
          damageReason: 'कीट/रोग (Pest/Disease)',
          description: 'भूरा धब्बा रोग से फसल प्रभावित',
          imageUrls: [],
          estimatedLossPercentage: 40,
          claimAmount: 28000,
          status: ClaimStatus.submitted,
          incidentDate: now.subtract(const Duration(days: 8)),
          submittedAt: now.subtract(const Duration(days: 5)),
        ),
      ];
    } else if (status == 'approved') {
      return [
        InsuranceClaim(
          id: 'CLM003',
          farmerId: 'F001',
          farmerName: 'राज कुमार',
          cropType: 'बाजरा (Millet)',
          damageReason: 'सूखा (Drought)',
          description: 'लंबे समय तक बारिश न होने से फसल सूख गई',
          imageUrls: [],
          estimatedLossPercentage: 80,
          claimAmount: 52000,
          status: ClaimStatus.approved,
          incidentDate: now.subtract(const Duration(days: 45)),
          submittedAt: now.subtract(const Duration(days: 42)),
          reviewedAt: now.subtract(const Duration(days: 30)),
          approvedAmount: '52000',
          reviewerComments: 'दावा सत्यापित और स्वीकृत',
        ),
      ];
    } else {
      return [
        InsuranceClaim(
          id: 'CLM004',
          farmerId: 'F001',
          farmerName: 'राज कुमार',
          cropType: 'मक्का (Maize)',
          damageReason: 'ओलावृष्टि (Hailstorm)',
          description: 'ओलावृष्टि से फसल को नुकसान',
          imageUrls: [],
          estimatedLossPercentage: 90,
          claimAmount: 65000,
          status: ClaimStatus.paid,
          incidentDate: now.subtract(const Duration(days: 90)),
          submittedAt: now.subtract(const Duration(days: 85)),
          reviewedAt: now.subtract(const Duration(days: 70)),
          approvedAmount: '65000',
        ),
        InsuranceClaim(
          id: 'CLM005',
          farmerId: 'F001',
          farmerName: 'राज कुमार',
          cropType: 'सोयाबीन (Soybean)',
          damageReason: 'तूफान (Storm)',
          description: 'तेज आंधी से फसल गिर गई',
          imageUrls: [],
          estimatedLossPercentage: 55,
          claimAmount: 38000,
          status: ClaimStatus.paid,
          incidentDate: now.subtract(const Duration(days: 120)),
          submittedAt: now.subtract(const Duration(days: 115)),
          reviewedAt: now.subtract(const Duration(days: 100)),
          approvedAmount: '38000',
        ),
        InsuranceClaim(
          id: 'CLM006',
          farmerId: 'F001',
          farmerName: 'राज कुमार',
          cropType: 'कपास (Cotton)',
          damageReason: 'कीट/रोग (Pest/Disease)',
          description: 'पत्ती मोड़ रोग से नुकसान',
          imageUrls: [],
          estimatedLossPercentage: 30,
          claimAmount: 18000,
          status: ClaimStatus.rejected,
          incidentDate: now.subtract(const Duration(days: 60)),
          submittedAt: now.subtract(const Duration(days: 55)),
          reviewedAt: now.subtract(const Duration(days: 40)),
          reviewerComments: 'नुकसान बीमा कवरेज सीमा से कम',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'मेरे दावे',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'सक्रिय'),
            Tab(text: 'स्वीकृत'),
            Tab(text: 'पिछले'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/file-claim'),
            tooltip: 'नया दावा दर्ज करें',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClaimsList('active'),
          _buildClaimsList('approved'),
          _buildClaimsList('history'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/file-claim'),
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.add),
        label: Text(
          'नया दावा',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildClaimsList(String status) {
    final claims = _getDemoClaims(status);

    if (claims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'active'
                  ? 'कोई सक्रिय दावा नहीं'
                  : status == 'approved'
                      ? 'कोई स्वीकृत दावा नहीं'
                      : 'कोई पिछला दावा नहीं',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'नया दावा दर्ज करने के लिए + बटन दबाएं',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh claims data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: claims.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildStatsCard(status);
          }
          final claim = claims[index - 1];
          return _buildClaimCard(claim);
        },
      ),
    );
  }

  Widget _buildStatsCard(String status) {
    final activeClaims = _getDemoClaims('active');
    final approvedClaims = _getDemoClaims('approved');
    final historyClaims = _getDemoClaims('history');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'दावा सारांश',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                activeClaims.length.toString(),
                'सक्रिय',
                Icons.pending_actions,
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildStatItem(
                approvedClaims.length.toString(),
                'स्वीकृत',
                Icons.check_circle,
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildStatItem(
                historyClaims.length.toString(),
                'कुल',
                Icons.history,
              ),
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
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildClaimCard(InsuranceClaim claim) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showClaimDetails(claim),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(claim.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getStatusIcon(claim.status),
                        color: _getStatusColor(claim.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            claim.cropType,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'दावा #${claim.id}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(claim.status),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'कारण: ${claim.damageReason}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'तिथि: ${DateFormat('dd MMM yyyy').format(claim.incidentDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.percent, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'नुकसान: ${claim.estimatedLossPercentage?.toStringAsFixed(0) ?? 'N/A'}%',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${claim.claimAmount?.toStringAsFixed(0) ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                if (claim.status == ClaimStatus.rejected && claim.reviewerComments != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            claim.reviewerComments!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ClaimStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(status),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return Colors.grey;
      case ClaimStatus.submitted:
        return Colors.blue;
      case ClaimStatus.underReview:
        return Colors.orange;
      case ClaimStatus.approved:
        return Colors.green;
      case ClaimStatus.rejected:
        return Colors.red;
      case ClaimStatus.paid:
        return Colors.teal;
    }
  }

  IconData _getStatusIcon(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return Icons.edit;
      case ClaimStatus.submitted:
        return Icons.send;
      case ClaimStatus.underReview:
        return Icons.pending;
      case ClaimStatus.approved:
        return Icons.check_circle;
      case ClaimStatus.rejected:
        return Icons.cancel;
      case ClaimStatus.paid:
        return Icons.account_balance_wallet;
    }
  }

  String _getStatusText(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return 'मसौदा';
      case ClaimStatus.submitted:
        return 'प्रस्तुत';
      case ClaimStatus.underReview:
        return 'समीक्षाधीन';
      case ClaimStatus.approved:
        return 'स्वीकृत';
      case ClaimStatus.rejected:
        return 'अस्वीकृत';
      case ClaimStatus.paid:
        return 'भुगतान किया';
    }
  }

  void _showClaimDetails(InsuranceClaim claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(claim.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(claim.status),
                      color: _getStatusColor(claim.status),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claim.cropType,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'दावा #${claim.id}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(claim.status),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('नुकसान का कारण', claim.damageReason, Icons.warning_amber),
              _buildDetailRow('घटना की तारीख', DateFormat('dd MMMM yyyy').format(claim.incidentDate), Icons.calendar_today),
              _buildDetailRow('दावा दर्ज', DateFormat('dd MMMM yyyy').format(claim.submittedAt), Icons.send),
              if (claim.reviewedAt != null)
                _buildDetailRow('समीक्षा तिथि', DateFormat('dd MMMM yyyy').format(claim.reviewedAt!), Icons.rate_review),
              _buildDetailRow('अनुमानित नुकसान', '${claim.estimatedLossPercentage?.toStringAsFixed(0) ?? 'N/A'}%', Icons.percent),
              _buildDetailRow('दावा राशि', '₹${claim.claimAmount?.toStringAsFixed(0) ?? 'N/A'}', Icons.currency_rupee),
              if (claim.approvedAmount != null)
                _buildDetailRow('स्वीकृत राशि', '₹${claim.approvedAmount}', Icons.check_circle),
              const SizedBox(height: 16),
              if (claim.description.isNotEmpty) ...[
                Text(
                  'विवरण',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    claim.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (claim.reviewerComments != null) ...[
                Text(
                  'समीक्षक टिप्पणियाँ',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: claim.status == ClaimStatus.rejected 
                        ? Colors.red.shade50 
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: claim.status == ClaimStatus.rejected 
                          ? Colors.red.shade200 
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    claim.reviewerComments!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('बंद करें'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
}
