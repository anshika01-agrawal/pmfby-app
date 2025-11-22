import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CROPIC Dashboard'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              // Background image temporarily commented out due to image decode issues
              // Uncomment once assets/images/background.png is properly added
              // image: DecorationImage(
              //   image: const AssetImage("assets/images/background.png"),
              //   fit: BoxFit.cover,
              //   colorFilter: ColorFilter.mode(
              //     Colors.black.withOpacity(0.1),
              //     BlendMode.dstATop,
              //   ),
              // ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: const <Widget>[
                DashboardCard(
                  title: 'File a Complaint',
                  icon: Icons.add_photo_alternate_rounded,
                ),
                DashboardCard(
                  title: 'My Complaints',
                  icon: Icons.history_rounded,
                ),
                DashboardCard(
                  title: 'Insurance Schemes',
                  icon: Icons.document_scanner_rounded,
                ),
                DashboardCard(
                  title: 'My Profile',
                  icon: Icons.person_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/camera'),
        label: const Text('Capture Crop Image'),
        icon: const Icon(Icons.camera_alt_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (title == 'My Profile') {
            context.push('/profile');
          } else if (title == 'My Complaints') {
            context.push('/complaints');
          }
          // Add navigation for other cards as needed
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 50.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
