import 'package:flutter/foundation.dart';

class PlanEntitlementKeys {
  static const chat = 'chat';
  static const voice = 'voice';
  static const video = 'video';
  static const toolsAudio = 'tools_audio';
  static const toolsImage = 'tools_image';
  static const toolsVideo = 'tools_video';
  static const docs = 'docs';
  static const sections = 'sections';
  static const devbox = 'devbox';
}

@immutable
class FeatureGateDefinition {
  const FeatureGateDefinition({
    required this.key,
    required this.label,
    required this.description,
  });

  final String key;
  final String label;
  final String description;
}

@immutable
class FeatureGateStatus {
  const FeatureGateStatus({
    required this.definition,
    required this.isEnabled,
  });

  final FeatureGateDefinition definition;
  final bool isEnabled;
}

const featureGateCatalog = [
  FeatureGateDefinition(
    key: PlanEntitlementKeys.chat,
    label: 'Chat core',
    description: 'Topic chats, prompts, and history tools.',
  ),
  FeatureGateDefinition(
    key: PlanEntitlementKeys.voice,
    label: 'Voice sessions',
    description: 'Live or studio audio conversations.',
  ),
  FeatureGateDefinition(
    key: PlanEntitlementKeys.video,
    label: 'Video avatars',
    description: 'Photo or video-based avatar sessions.',
  ),
  FeatureGateDefinition(
    key: PlanEntitlementKeys.toolsAudio,
    label: 'Audio tools',
    description: 'STT/TTS and audio enhancement tools.',
  ),
  FeatureGateDefinition(
    key: PlanEntitlementKeys.toolsImage,
    label: 'Image tools',
    description: 'Image generation and remixing utilities.',
  ),
  FeatureGateDefinition(
    key: PlanEntitlementKeys.toolsVideo,
    label: 'Video tools',
    description: 'Video creation and enhancement features.',
  ),
  FeatureGateDefinition(
    key: PlanEntitlementKeys.docs,
    label: 'Docs & files',
    description: 'Document parsing and storage workflows.',
  ),
  FeatureGateDefinition(
    key: PlanEntitlementKeys.sections,
    label: 'Sections builder',
    description: 'Custom Hobby/Study/Work spaces.',
  ),
  FeatureGateDefinition(
    key: PlanEntitlementKeys.devbox,
    label: 'Developer DevBox',
    description: 'Paid dev container access in Work.',
  ),
];

List<FeatureGateStatus> buildFeatureGateStatuses(
  Map<String, bool> entitlements,
) {
  return featureGateCatalog
      .map(
        (definition) => FeatureGateStatus(
          definition: definition,
          isEnabled: entitlements[definition.key] ?? false,
        ),
      )
      .toList();
}
