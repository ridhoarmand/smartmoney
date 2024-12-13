import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _copyURLToClipboard(BuildContext context) async {
    const url = 'https://github.com/ridhoarmand/smartmoney';
    await Clipboard.setData(const ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GitHub repository URL copied to clipboard'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Logo and Title
          const SizedBox(height: 20),
          const Image(
            image: AssetImage('assets/logo.png'),
            height: 100,
          ),
          const SizedBox(height: 16),
          const Text(
            'Smart Money',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Project Description
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Project Akhir kegiatan Kampus Merdeka, Studi Independen dari Kemendikbud dan IOS & Android Mobile Developer by PT Mojadi Aplikasi Indonesia atau MojadiApp/MojadiPro',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Team Members
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team Members',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTeamMember(
                    'Putri Cahyaning Tyas',
                    'ITSNU Pekalongan',
                  ),
                  _buildTeamMember(
                    'Ridho Armansyah',
                    'Universitas Amikom Purwokerto',
                  ),
                  _buildTeamMember(
                    'Mayhikal Ferdiananta',
                    'Universitas Pembangunan Nasional "Veteran" Jawa Timur',
                  ),
                  _buildTeamMember(
                    'Erditya Eka Pratama',
                    'Universitas Teknologi Mataram',
                  ),
                  _buildTeamMember(
                    'Muhamad Ridho Dwi Putra',
                    'Universitas Ahmad Dahlan',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tech Stack
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tech Stack',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTechItem(Icons.flutter_dash, 'Flutter'),
                  _buildTechItem(Icons.security, 'Firebase Auth'),
                  _buildTechItem(Icons.storage, 'Firebase Firestore'),
                  _buildTechItem(Icons.cloud_upload, 'Firebase Storage'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // GitHub Repository
          Card(
            child: ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Source Code'),
              subtitle: const Text('github.com/ridhoarmand/smartmoney'),
              onTap: () => _copyURLToClipboard(context), // Fixed here
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String university) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  university,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
