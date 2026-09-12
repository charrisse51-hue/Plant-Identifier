import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? _activeBaseUrl;

/// Initialize saved working base URL from persistent storage
Future<void> initApiConfig() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('active_api_base_url');
    if (saved != null && saved.isNotEmpty) {
      _activeBaseUrl = saved;
      debugPrint('Loaded active API Base URL from storage: $_activeBaseUrl');
    }
  } catch (e) {
    debugPrint('Failed to load active API Base URL: $e');
  }
}

/// Call this whenever an API call succeeds on a given host so all subsequent
/// requests across the app immediately use the working host without timeout delays.
void setWorkingBaseUrl(String url) {
  if (url.isNotEmpty && _activeBaseUrl != url) {
    _activeBaseUrl = url;
    debugPrint('API Base URL updated to: $_activeBaseUrl');
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('active_api_base_url', url);
    }).catchError((_) {});
  }
}

/// Compile-time configurable backend URL:
/// Pass --dart-define=BACKEND_URL=https://your-backend.onrender.com during flutter build
const String _injectedBackendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');

/// Default public production backend URL on cloud hosting.
/// Leave empty for local development, or set this to your exact deployed Render/cloud URL.
const String defaultProductionBackendUrl = '';

String get productionBackendUrl {
  if (_injectedBackendUrl.isNotEmpty) {
    return _injectedBackendUrl.trim().replaceAll(RegExp(r'/+$'), '');
  }
  if (defaultProductionBackendUrl.isNotEmpty) {
    return defaultProductionBackendUrl.trim().replaceAll(RegExp(r'/+$'), '');
  }
  return '';
}

List<String> get apiBaseUrls {
  final prodUrl = productionBackendUrl;
  final List<String> urls = [];

  // Always prioritize the public cloud URL first so the app works globally
  // from any phone on mobile data or external Wi-Fi without laptop connection.
  if (prodUrl.isNotEmpty) {
    urls.add(prodUrl);
  }

  if (kIsWeb) {
    urls.addAll([
      'http://127.0.0.1:8000',
      'http://localhost:8000',
      'http://192.168.1.6:8000',
    ]);
  } else if (Platform.isAndroid) {
    urls.addAll([
      'http://192.168.1.6:8000', // Wi-Fi LAN address for physical phone on home Wi-Fi
      'http://10.0.2.2:8000',    // Android Emulator loopback
      'http://127.0.0.1:8000',   // USB / adb reverse
      'http://localhost:8000',
      'http://10.0.3.2:8000',    // Genymotion
    ]);
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    urls.addAll([
      'http://127.0.0.1:8000',
      'http://localhost:8000',
      'http://192.168.1.6:8000',
    ]);
  } else if (Platform.isIOS) {
    urls.addAll([
      'http://192.168.1.6:8000',
      'http://127.0.0.1:8000',
      'http://localhost:8000',
    ]);
  } else {
    urls.addAll([
      'http://192.168.1.6:8000',
      'http://127.0.0.1:8000',
      'http://localhost:8000',
      'http://10.0.2.2:8000',
    ]);
  }

  // If a working base URL has been discovered, prioritize it first
  if (_activeBaseUrl != null && urls.contains(_activeBaseUrl)) {
    return [
      _activeBaseUrl!,
      ...urls.where((u) => u != _activeBaseUrl),
    ];
  } else if (_activeBaseUrl != null) {
    return [_activeBaseUrl!, ...urls];
  }

  return urls;
}

String get apiBaseUrl => _activeBaseUrl ?? apiBaseUrls.first;

const List<String> ollamaBaseUrls = [
  'http://127.0.0.1:11434',
  'http://localhost:11434',
  'http://10.0.2.2:11434',
  'http://192.168.1.6:11434',
];

String get ollamaBaseUrl => ollamaBaseUrls.first;
