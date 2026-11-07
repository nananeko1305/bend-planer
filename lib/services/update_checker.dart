import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

/// The download page: it always offers the newest APK, named after its
/// version, with the install steps, so a QR code already handed out never
/// goes stale. (Installs up to 1.3.1 link straight to the fixed-name APK,
/// which every release still carries.)
const String kDownloadPageUrl = 'https://nananeko1305.github.io/bend-planer/';

/// Latest release as published by CI to GitHub Pages (`version.json`).
class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.build,
    required this.downloadUrl,
  });

  final String version;
  final int build;
  final String downloadUrl;

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) => ReleaseInfo(
    version: json['version'] as String,
    build: (json['build'] as num).toInt(),
    downloadUrl: json['url'] as String,
  );
}

/// Orders two `major.minor.patch` versions: negative when [a] is older,
/// zero when they match, positive when [a] is newer. Missing or
/// unreadable parts count as zero, so a malformed version is simply old.
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
    for (var i = 0; i < 3; i++)
      int.tryParse(v.split('.').elementAtOrNull(i)?.split('-').first ?? '') ??
          0,
  ];
  final left = parts(a);
  final right = parts(b);
  for (var i = 0; i < 3; i++) {
    if (left[i] != right[i]) return left[i] - right[i];
  }
  return 0;
}

sealed class UpdateResult {
  const UpdateResult();
}

class UpdateAvailable extends UpdateResult {
  const UpdateAvailable(this.release, this.currentVersion);
  final ReleaseInfo release;
  final String currentVersion;
}

class UpToDate extends UpdateResult {
  const UpToDate();
}

class UpdateCheckFailed extends UpdateResult {
  const UpdateCheckFailed(this.error);
  final Object error;
}

/// Compares this app's version with the newest release CI published to
/// GitHub Pages. The build number is Android's own version code and says nothing
/// about what changed, so it is not what decides.
class UpdateChecker {
  UpdateChecker._();
  static final UpdateChecker instance = UpdateChecker._();

  static final Uri _versionUrl = Uri.parse(
    'https://nananeko1305.github.io/bend-planer/version.json',
  );
  static const _timeout = Duration(seconds: 8);

  Future<PackageInfo> currentApp() => PackageInfo.fromPlatform();

  Future<UpdateResult> check() async {
    try {
      final app = await currentApp();
      final release = await latest();
      return compareVersions(release.version, app.version) > 0
          ? UpdateAvailable(release, app.version)
          : const UpToDate();
    } catch (e) {
      return UpdateCheckFailed(e);
    }
  }

  /// The newest release, as published. The owner's "required version" is
  /// taken from it.
  Future<ReleaseInfo> latest() async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      // Cache-buster: Pages is served through a CDN with a short max-age.
      final url = _versionUrl.replace(
        queryParameters: {'t': '${DateTime.now().millisecondsSinceEpoch}'},
      );
      final request = await client.getUrl(url).timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('version.json: HTTP ${response.statusCode}');
      }
      final body = await response.transform(utf8.decoder).join();
      return ReleaseInfo.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }
}
