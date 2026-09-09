import 'package:flutter/material.dart';

import '../widgets/guardian_mic_button.dart';
import 'contacts_screen.dart';
import 'emergency_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startEmergency(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmergencyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF00B8D9),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Guardian',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Situation-aware safety companion',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people_alt_outlined),
                  ),
                ],
              ),

              const Spacer(),

              const Text(
                'I am here with you.',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Tell me what is happening.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 45),

              GuardianMicButton(
                onPressed: () => _startEmergency(context),
              ),

              const SizedBox(height: 25),

              const Text(
                'TAP TO SPEAK',
                style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 55),

              // Quick status
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF11141B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatusItem(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: 'Ready',
                    ),
                    _StatusItem(
                      icon: Icons.battery_5_bar_rounded,
                      title: 'Battery',
                      value: '—',
                    ),
                    _StatusItem(
                      icon: Icons.wifi_rounded,
                      title: 'Network',
                      value: 'Ready',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatusItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 23,
          color: Colors.white70,
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}