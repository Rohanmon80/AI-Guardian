import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Emergency contacts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Choose who AI Guardian should contact during an emergency.',
            style: TextStyle(
              color: Colors.white54,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 25),

          _ContactCard(
            name: 'Mom',
            number: '+91 XXXXX XXXXX',
            primary: true,
          ),

          _ContactCard(
            name: 'Dad',
            number: '+91 XXXXX XXXXX',
            primary: false,
          ),

          _ContactCard(
            name: 'Sister',
            number: '+91 XXXXX XXXXX',
            primary: false,
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('ADD TRUSTED CONTACT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.15),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String name;
  final String number;
  final bool primary;

  const _ContactCard({
    required this.name,
    required this.number,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
            child: Text(
              name[0],
              style: const TextStyle(
                color: Color(0xFF8B84FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (primary) ...[
                      const SizedBox(width: 8),
                      const Text(
                        'PRIMARY',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF8B84FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle,
            color: Color(0xFF6C63FF),
          ),
        ],
      ),
    );
  }
}