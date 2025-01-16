class OperatingSystemData {
  final String name;
  final String version;
  final String build;
  final String platform;
  final String platformLike;
  final String arch;

  OperatingSystemData({
    required this.name,
    required this.version,
    required this.build,
    required this.platform,
    required this.platformLike,
    required this.arch,
  });

  factory OperatingSystemData.fromJson(Map<String, dynamic> json) {
    return OperatingSystemData(
      name: json['name'],
      version: json['version'],
      build: json['build'],
      platform: json['platform'],
      platformLike: json['platform_like'],
      arch: json['arch'],
    );
  }
}
