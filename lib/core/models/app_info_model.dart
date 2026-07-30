class AppInfoModel {
  final String id;
  final String appName;
  final String description;
  final String developer;
  final String website;
  final String supportEmail;
  final String privacyPolicyUrl;
  final String? privacyPolicyContent;
  final String termsUrl;
  final String? termsContent;

  AppInfoModel({
    required this.id,
    required this.appName,
    required this.description,
    required this.developer,
    required this.website,
    required this.supportEmail,
    required this.privacyPolicyUrl,
    this.privacyPolicyContent,
    required this.termsUrl,
    this.termsContent,
  });

  factory AppInfoModel.fromJson(Map<String, dynamic> json) {
    return AppInfoModel(
      id: json['id'] ?? '',
      appName: json['app_name'] ?? '',
      description: json['description'] ?? '',
      developer: json['developer'] ?? '',
      website: json['website'] ?? '',
      supportEmail: json['support_email'] ?? '',
      privacyPolicyUrl: json['privacy_policy_url'] ?? '',
      privacyPolicyContent: json['privacy_policy_content'] as String?,
      termsUrl: json['terms_url'] ?? '',
      termsContent: json['terms_content'] as String?,
    );
  }
}
