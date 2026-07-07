import '../Api_services/urls.dart';

class ApiMediaUrlResolver {
  const ApiMediaUrlResolver._();

  static String resolve(String? imageUrl) {
    final rawUrl = imageUrl?.trim() ?? '';
    if (rawUrl.isEmpty) return '';

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return rawUrl;

    if (!uri.hasScheme) {
      return _resolveRelativeUrl(rawUrl);
    }

    if (_isLocalhost(uri)) {
      return _replaceHostWithApiHost(uri).toString();
    }

    return rawUrl;
  }

  static String _resolveRelativeUrl(String rawUrl) {
    final apiBaseUri = Uri.parse(Urls.baseUrl);
    final normalizedPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';

    return Uri(
      scheme: apiBaseUri.scheme,
      host: apiBaseUri.host,
      port: apiBaseUri.hasPort ? apiBaseUri.port : 0,
      path: normalizedPath,
    ).toString();
  }

  static bool _isLocalhost(Uri uri) {
    return uri.host == 'localhost' || uri.host == '127.0.0.1';
  }

  static Uri _replaceHostWithApiHost(Uri uri) {
    final apiBaseUri = Uri.parse(Urls.baseUrl);

    return Uri(
      scheme: apiBaseUri.scheme,
      host: apiBaseUri.host,
      port: apiBaseUri.hasPort ? apiBaseUri.port : 0,
      path: uri.path,
      query: uri.hasQuery ? uri.query : null,
      fragment: uri.hasFragment ? uri.fragment : null,
    );
  }
}
