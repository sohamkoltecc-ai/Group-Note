import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPageHeader('Class & Study Groups', '12 Channels Joined'),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildGroupCategory('Official Course Groups', [
                  _buildGroupRow(
                    'Data Structures FY',
                    '142 Members',
                    Icons.code_rounded,
                    const Color(0xFF2563EB),
                  ),
                  _buildGroupRow(
                    'Database Systems (DBMS)',
                    '138 Members',
                    Icons.storage_rounded,
                    const Color(0xFF0284C7),
                  ),
                  _buildGroupRow(
                    'IoT & Sensor Systems',
                    '120 Members',
                    Icons.developer_board_rounded,
                    const Color(0xFF0D9488),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildGroupCategory('Study & Project Channels', [
                  _buildGroupRow(
                    'Coding Club Exam Prep',
                    '18 Members',
                    Icons.terminal_rounded,
                    const Color(0xFF4F46E5),
                  ),
                  _buildGroupRow(
                    'Group Note Mini-Project Team',
                    '5 Members',
                    Icons.laptop_mac_rounded,
                    const Color(0xFF7C3AED),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildGroupRow(
    String name,
    String members,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          members,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: const StadiumBorder(),
          ),
          child: const Text(
            'Open',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
