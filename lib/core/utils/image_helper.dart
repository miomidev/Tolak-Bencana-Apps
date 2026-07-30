import '../config/app_config.dart';

String resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  final serverOrigin = AppConfig.baseUrl.replaceAll(RegExp(r'/api/?$'), '');

  if (url.startsWith('http://localhost')) {
    return url.replaceFirst('http://localhost', serverOrigin);
  }

  if (!url.startsWith('http')) {
    return '$serverOrigin/storage/$url';
  }

  return url;
}
