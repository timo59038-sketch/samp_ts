import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:samp_ts/firebase_options.dart';

void main() {
  test('Dart Firebase options match the registered Android app', () {
    final config =
        jsonDecode(File('android/app/google-services.json').readAsStringSync())
            as Map<String, dynamic>;
    final client = (config['client'] as List).single as Map<String, dynamic>;
    final info = config['project_info'] as Map<String, dynamic>;
    final options = DefaultFirebaseOptions.android;
    expect(options.projectId, 'sampts-ea8c4');
    expect(options.projectId, info['project_id']);
    expect(options.messagingSenderId, info['project_number']);
    expect(options.appId, client['client_info']['mobilesdk_app_id']);
    expect(options.apiKey, client['api_key'][0]['current_key']);
    expect(
      client['client_info']['android_client_info']['package_name'],
      'com.samparts.samp_ts',
    );
  });
}
