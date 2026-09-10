import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'device_info_service.dart';
import 'situation_engine.dart';
import 'trusted_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
void main() {
  runApp(const AIGuardianApp());
}

class AIGuardianApp extends StatelessWidget {
  const AIGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Guardian',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07090D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _spokenText = '';

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
      },
    );

    if (!available) {
      return;
    }

    setState(() {
      _isListening = true;
      _spokenText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    setState(() {
      _isListening = false;
    });

    final result = SituationEngine().analyze(_spokenText);

    if (result.isEmergency) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmergencyScreen(
            spokenText: _spokenText,
            result: result,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 25),

              // HEADER
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF00C6FF),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 28,
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
                ],
              ),

              const Spacer(),

              const Text(
                'I am here with you.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _isListening
                    ? 'Listening...'
                    : 'Tell me what is happening.',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 30),

              // SPOKEN TEXT
              if (_spokenText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11141B),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '"$_spokenText"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.white70,
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              // MICROPHONE
              GestureDetector(
                onTap: _isListening
                    ? _stopListening
                    : _startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isListening ? 175 : 155,
                  height: _isListening ? 175 : 155,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6C63FF),
                        Color(0xFF00B8D9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF)
                            .withOpacity(0.35),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    size: 62,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final result = SituationEngine().analyze(
                      'I am in danger, please help me',
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmergencyScreen(
                          spokenText: 'I am in danger, please help me',
                          result: result,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.warning_rounded),
                  label: const Text(
                    'QUICK EMERGENCY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(
                      color: Colors.redAccent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),

              Text(
                _isListening
                    ? 'TAP TO STOP'
                    : 'TAP TO SPEAK',
                style: const TextStyle(
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),

              const Spacer(),

              // STATUS
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF11141B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    StatusItem(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: 'Ready',
                    ),
                    StatusItem(
                      icon: Icons.battery_5_bar_rounded,
                      title: 'Battery',
                      value: '—',
                    ),
                    StatusItem(
                      icon: Icons.wifi_rounded,
                      title: 'Network',
                      value: 'Ready',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TrustedContactsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people_alt_rounded),
                  label: const Text(
                    'TRUSTED CONTACTS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatusItem({
    super.key,
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

class EmergencyScreen extends StatefulWidget {
  final String spokenText;
  final SituationResult result;

  const EmergencyScreen({
    super.key,
    required this.spokenText,
    required this.result,
  });

  @override
  State<EmergencyScreen> createState() =>
      _EmergencyScreenState();
}
class _EmergencyScreenState extends State<EmergencyScreen> {
  DeviceInfo? _deviceInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }


  Future<void> _loadDeviceInfo() async {
    try {
      final info = await DeviceInfoService().getDeviceInfo();

      if (!mounted) return;

      setState(() {
        _deviceInfo = info;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }
  Future<void> _findSafePlace() async {
    final location = _deviceInfo?.location;

    if (location == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location is unavailable'),
        ),
      );
      return;
    }

    String placeType;
    String placeLabel;

    switch (widget.result.type) {
      case EmergencyType.accident:
      case EmergencyType.injury:
        placeType = 'hospital';
        placeLabel = 'nearest hospital';

        break;

      case EmergencyType.lost:
      case EmergencyType.lowBattery:
        placeType = 'public place';
        placeLabel = 'safe public place';

        break;

      case EmergencyType.following:
      case EmergencyType.danger:
      case EmergencyType.unknown:
        placeType = 'police station';
        placeLabel = 'nearest police station';

        break;
    }

    final lat = location.latitude;
    final lon = location.longitude;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
          '&query=${Uri.encodeComponent('$placeType near $lat,$lon')}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening $placeLabel...'),
        ),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Maps'),
        ),
      );
    }
  }
  String _getAdaptiveMode() {
    final battery = _deviceInfo?.battery ?? 100;
    final network = _deviceInfo?.network ?? 'Unavailable';
    final location = _deviceInfo?.location;

    final hasNetwork =
        network != 'No connection' && network != 'Unavailable';

    if (battery <= 10 && !hasNetwork) {
      return 'CRITICAL OFFLINE MODE';
    }

    if (battery <= 20) {
      return 'LOW BATTERY MODE';
    }

    if (!hasNetwork) {
      return 'OFFLINE MODE';
    }

    if (location == null) {
      return 'LOCATION LIMITED MODE';
    }

    return 'FULL EMERGENCY MODE';
  }

  String _getAdaptiveMessage() {
    switch (_getAdaptiveMode()) {
      case 'CRITICAL OFFLINE MODE':
        return 'Battery and network are critical. Prioritize immediate local safety and conserve device power.';

      case 'LOW BATTERY MODE':
        return 'Battery is low. AI Guardian prioritizes essential emergency actions and location sharing.';

      case 'OFFLINE MODE':
        return 'Network is unavailable. Follow local emergency guidance and move toward a safe public location.';

      case 'LOCATION LIMITED MODE':
        return 'Location is unavailable. Emergency actions can continue, but location cannot be included reliably.';

      default:
        return 'Device conditions are good. Full emergency assistance is available.';
    }
  }
  Widget _packetRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _callPrimaryContact() async {
    final prefs = await SharedPreferences.getInstance();

    final names = prefs.getStringList('contact_names') ?? [];
    final phones = prefs.getStringList('contact_phones') ?? [];
    final primaryIndex = prefs.getInt('primary_contact') ?? 0;

    if (phones.isEmpty || primaryIndex >= phones.length) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No primary trusted contact configured.',
          ),
        ),
      );

      return;
    }

    final phone = phones[primaryIndex];
    final name = names.length > primaryIndex
        ? names[primaryIndex]
        : 'Trusted contact';

    final uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling $name...'),
        ),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open phone dialer'),
        ),
      );
    }
  }
  Future<void> _prepareEmergencyAlert() async {
    final prefs = await SharedPreferences.getInstance();

    final names = prefs.getStringList('contact_names') ?? [];
    final phones = prefs.getStringList('contact_phones') ?? [];

    if (phones.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add trusted contacts first.'),
        ),
      );

      return;
    }

    final location = _deviceInfo?.location;

    final locationText = location != null
        ? '${location.latitude.toStringAsFixed(5)}, '
        '${location.longitude.toStringAsFixed(5)}'
        : 'Location unavailable';

    final batteryText = _deviceInfo != null
        ? '${_deviceInfo!.battery}%'
        : 'Unavailable';

    final networkText =
        _deviceInfo?.network ?? 'Unavailable';

    final message = '''
🚨 AI GUARDIAN EMERGENCY

Situation: ${widget.result.type.name.toUpperCase()}
Urgency: ${widget.result.urgency}

Message:
"${widget.spokenText}"

Location: $locationText
Battery: $batteryText
Network: $networkText

AI Guidance:
${widget.result.guidance}
''';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text('Emergency Alert'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alert will be prepared for:',
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...List.generate(
                    names.length < phones.length
                        ? names.length
                        : phones.length,
                        (index) => Padding(
                      padding:
                      const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '✓ ${names[index]}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF11141B),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await SharePlus.instance.share(
                  ShareParams(
                    text: message,
                    subject: 'AI Guardian Emergency Alert',
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('PREPARE ALERT'),
            ),
          ],
        );
      },
    );
  }
  Widget _timelineItem(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: Colors.greenAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      appBar: AppBar(
        title: const Text('Emergency Mode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF26151A),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.redAccent.withOpacity(0.4),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.redAccent,
                    size: 38,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'EMERGENCY DETECTED',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'AI Guardian is analyzing your situation.',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'What you said',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF11141B),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF6C63FF),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'AI UNDERSTANDING',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Situation: ${widget.result.type.name.toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Urgency: ${widget.result.urgency}',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Requested contact: '
                        '${widget.result.requestedContact ?? 'None'}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Recommended action: '
                        '${widget.result.action.name}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(17),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF11141B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '"${widget.spokenText}"',
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: _callPrimaryContact,
              child: ActionCard(
                icon: Icons.phone_rounded,
                title: 'Primary Contact',
                subtitle:
                widget.result.requestedContact ?? 'Trusted contact',
                status: 'CALL',
                iconColor: Colors.greenAccent,
              ),
            ),

            ActionCard(
              icon: Icons.location_on_rounded,
              title: 'Location',
              subtitle: _deviceInfo?.location != null
                  ? '${_deviceInfo!.location!.latitude.toStringAsFixed(5)}, '
                  '${_deviceInfo!.location!.longitude.toStringAsFixed(5)}'
                  : 'Location unavailable',
              status: _loading
                  ? 'CHECKING'
                  : (_deviceInfo?.location != null
                  ? 'AVAILABLE'
                  : 'UNAVAILABLE'),
              iconColor: Colors.blueAccent,
            ),

            ActionCard(
              icon: Icons.battery_5_bar_rounded,
              title: 'Battery',
              subtitle: _deviceInfo != null
                  ? '${_deviceInfo!.battery}% remaining'
                  : 'Reading battery...',
              status: _loading ? 'CHECKING' : 'READY',
              iconColor: Colors.orangeAccent,
            ),

            ActionCard(
              icon: Icons.wifi_rounded,
              title: 'Network',
              subtitle:
              _deviceInfo?.network ?? 'Checking connection...',
              status: _loading ? 'CHECKING' : 'AVAILABLE',
              iconColor: Colors.cyanAccent,
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF11141B),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF6C63FF),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'AI GUIDANCE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    widget.result.guidance,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

        const SizedBox(height: 15),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF11141B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.orangeAccent.withOpacity(0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.orangeAccent,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'ADAPTIVE EMERGENCY MODE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                _getAdaptiveMode(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _getAdaptiveMessage(),
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),


        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF11141B),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.timeline_rounded,
                    color: Color(0xFF6C63FF),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'AI RESPONSE TIMELINE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _timelineItem(
                Icons.mic_rounded,
                'Understood',
                'Voice input captured',
              ),

              _timelineItem(
                Icons.psychology_rounded,
                'Analyzed',
                'Situation classified as ${widget.result.type.name}',
              ),

              _timelineItem(
                Icons.memory_rounded,
                'Context checked',
                'Battery, network and location evaluated',
              ),

              _timelineItem(
                Icons.auto_awesome_rounded,
                'Adapted',
                _getAdaptiveMode(),
              ),

              _timelineItem(
                Icons.shield_rounded,
                'Ready to act',
                'Emergency assistance prepared',
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _prepareEmergencyAlert,
            icon: const Icon(Icons.send_rounded),
            label: const Text(
              'ALERT TRUSTED CONTACTS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.redAccent.withOpacity(0.6),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),


            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _findSafePlace,
                icon: const Icon(Icons.map_rounded),
                label: const Text(
                  'FIND SAFE PLACE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(17),
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

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color iconColor;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          Text(
            status,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}