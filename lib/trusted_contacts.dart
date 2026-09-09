import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrustedContact {
  final String name;
  final String phone;
  final bool isPrimary;

  const TrustedContact({
    required this.name,
    required this.phone,
    this.isPrimary = false,
  });

  String get displayPhone => phone;
}

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() =>
      _TrustedContactsScreenState();
}

class _TrustedContactsScreenState
    extends State<TrustedContactsScreen> {
  List<TrustedContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final names = prefs.getStringList('contact_names') ?? [];
    final phones = prefs.getStringList('contact_phones') ?? [];
    final primaryIndex = prefs.getInt('primary_contact') ?? 0;

    final contacts = <TrustedContact>[];

    for (int i = 0; i < names.length && i < phones.length; i++) {
      contacts.add(
        TrustedContact(
          name: names[i],
          phone: phones[i],
          isPrimary: i == primaryIndex,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'contact_names',
      _contacts.map((contact) => contact.name).toList(),
    );

    await prefs.setStringList(
      'contact_phones',
      _contacts.map((contact) => contact.phone).toList(),
    );

    final primaryIndex = _contacts.indexWhere(
          (contact) => contact.isPrimary,
    );

    await prefs.setInt(
      'primary_contact',
      primaryIndex < 0 ? 0 : primaryIndex,
    );
  }

  Future<void> _addContact() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Trusted Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Mom',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+91XXXXXXXXXX',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(context, true);
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final shouldBePrimary = _contacts.isEmpty;

    setState(() {
      _contacts.add(
        TrustedContact(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          isPrimary: shouldBePrimary,
        ),
      );
    });

    await _saveContacts();
  }

  Future<void> _deleteContact(int index) async {
    final wasPrimary = _contacts[index].isPrimary;

    setState(() {
      _contacts.removeAt(index);

      if (wasPrimary && _contacts.isNotEmpty) {
        final first = _contacts[0];

        _contacts[0] = TrustedContact(
          name: first.name,
          phone: first.phone,
          isPrimary: true,
        );
      }
    });

    await _saveContacts();
  }

  Future<void> _setPrimary(int index) async {
    setState(() {
      _contacts = List.generate(
        _contacts.length,
            (i) => TrustedContact(
          name: _contacts[i].name,
          phone: _contacts[i].phone,
          isPrimary: i == index,
        ),
      );
    });

    await _saveContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'People AI Guardian can contact',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _contacts.isEmpty
                  ? const Center(
                child: Text(
                  'No trusted contacts yet.\nAdd someone you trust.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF11141B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: contact.isPrimary
                            ? const Color(0xFF6C63FF)
                            .withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF)
                                .withOpacity(0.15),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF8B83FF),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                contact.displayPhone,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              if (contact.isPrimary)
                                const Padding(
                                  padding: EdgeInsets.only(
                                    top: 5,
                                  ),
                                  child: Text(
                                    'PRIMARY CONTACT',
                                    style: TextStyle(
                                      color:
                                      Colors.greenAccent,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'primary') {
                              _setPrimary(index);
                            } else if (value == 'delete') {
                              _deleteContact(index);
                            }
                          },
                          itemBuilder: (context) => [
                            if (!contact.isPrimary)
                              const PopupMenuItem(
                                value: 'primary',
                                child: Text(
                                  'Set as primary',
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _addContact,
                icon: const Icon(Icons.person_add_rounded),
                label: const Text(
                  'ADD TRUSTED CONTACT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}