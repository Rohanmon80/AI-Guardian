enum EmergencyType {
  danger,
  following,
  accident,
  injury,
  lost,
  lowBattery,
  unknown,
}

enum ActionType {
  call,
  message,
  findSafePlace,
  findHospital,
  giveGuidance,
  none,
}

class SituationResult {
  final bool isEmergency;
  final EmergencyType type;
  final ActionType action;
  final String? requestedContact;
  final String urgency;
  final String guidance;

  const SituationResult({
    required this.isEmergency,
    required this.type,
    required this.action,
    this.requestedContact,
    required this.urgency,
    required this.guidance,
  });
}

class SituationEngine {
  SituationResult analyze(String text) {
    final input = text.toLowerCase().trim();

    final isEmergency =
    _containsAny(input, [
      'danger',
      'help me',
      'emergency',
      'save me',
      'scared',
      'afraid',
      'unsafe',
      'attack',
      'threat',
      'following',
      'accident',
      'injured',
      'hurt',
      'lost',
    ]);

    if (!isEmergency) {
      return const SituationResult(
        isEmergency: false,
        type: EmergencyType.unknown,
        action: ActionType.none,
        urgency: 'LOW',
        guidance: 'I am listening. Tell me what is happening.',
      );
    }

    // FOLLOWING
    if (_containsAny(input, [
      'following me',
      'someone is following',
      'being followed',
      'person following',
      'chasing me',
      'someone is chasing',
    ])) {
      return SituationResult(
        isEmergency: true,
        type: EmergencyType.following,
        action: ActionType.findSafePlace,
        requestedContact: _extractContact(input),
        urgency: 'HIGH',
        guidance:
        'Stay calm. Do not confront the person. '
            'Move toward a crowded, well-lit public place. '
            'I can help you find a nearby safe location.',
      );
    }

    // ACCIDENT
    if (_containsAny(input, [
      'accident',
      'crashed',
      'crash',
      'vehicle accident',
      'bike accident',
      'car accident',
    ])) {
      return SituationResult(
        isEmergency: true,
        type: EmergencyType.accident,
        action: ActionType.findHospital,
        requestedContact: _extractContact(input),
        urgency: 'CRITICAL',
        guidance:
        'If you can move safely, move away from immediate danger. '
            'I can help you contact your trusted person and find a nearby hospital.',
      );
    }

    // INJURY
    if (_containsAny(input, [
      'injured',
      'i am hurt',
      'im hurt',
      'bleeding',
      'hurt badly',
    ])) {
      return SituationResult(
        isEmergency: true,
        type: EmergencyType.injury,
        action: ActionType.findHospital,
        requestedContact: _extractContact(input),
        urgency: 'CRITICAL',
        guidance:
        'Stay as safe and still as possible if moving could make the injury worse. '
            'I can help you contact your trusted person and find medical assistance.',
      );
    }

    // LOST + BATTERY
    if (_containsAny(input, [
      'lost',
      'cannot find my way',
      'dont know where i am',
      'do not know where i am',
    ]) &&
        _containsAny(input, [
          'battery',
          'percent',
          '%',
          'dying',
          'almost dead',
        ])) {
      return SituationResult(
        isEmergency: true,
        type: EmergencyType.lowBattery,
        action: ActionType.findSafePlace,
        requestedContact: _extractContact(input),
        urgency: 'HIGH',
        guidance:
        'Your battery may be limited. I will prioritize emergency '
            'communication and help you find a nearby safe location.',
      );
    }

    // LOST
    if (_containsAny(input, [
      'lost',
      'cannot find my way',
      'dont know where i am',
      'do not know where i am',
    ])) {
      return SituationResult(
        isEmergency: true,
        type: EmergencyType.lost,
        action: ActionType.findSafePlace,
        requestedContact: _extractContact(input),
        urgency: 'HIGH',
        guidance:
        'Stay in a safe public area. I can use your location to '
            'help identify an appropriate nearby place.',
      );
    }

    // GENERAL DANGER
    return SituationResult(
      isEmergency: true,
      type: EmergencyType.danger,
      action: _containsAny(input, [
        'call',
      ])
          ? ActionType.call
          : ActionType.giveGuidance,
      requestedContact: _extractContact(input),
      urgency: 'HIGH',
      guidance:
      'Stay calm. Move toward a safe and populated area. '
          'I will help you contact your trusted person and determine the next safe action.',
    );
  }

  String? _extractContact(String input) {
    const contacts = [
      'mom',
      'mother',
      'dad',
      'father',
      'sister',
      'brother',
      'friend',
    ];

    for (final contact in contacts) {
      if (input.contains(contact)) {
        return contact;
      }
    }

    return null;
  }

  bool _containsAny(String input, List<String> keywords) {
    for (final keyword in keywords) {
      if (input.contains(keyword)) {
        return true;
      }
    }

    return false;
  }
}