class ContentVersionResponse {
  final int totalSize;
  final bool done;
  final List<ContentVersion> records;

  ContentVersionResponse({
    required this.totalSize,
    required this.done,
    required this.records,
  });

  factory ContentVersionResponse.fromJson(Map<String, dynamic> json) {
    return ContentVersionResponse(
      totalSize: json['totalSize'] ?? 0,
      done: json['done'] ?? true,
      records: (json['records'] as List?)
          ?.map((e) => ContentVersion.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ContentVersion {
  final String? id;
  final String? fileExtension;
  final String? versionData;

  ContentVersion({
    this.id,
    this.fileExtension,
    this.versionData,
  });

  factory ContentVersion.fromJson(Map<String, dynamic> json) {
    return ContentVersion(
      id: json['Id'],
      fileExtension: json['FileExtension'],
      versionData: json['VersionData'],
    );
  }
}