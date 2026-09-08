class ContentDocumentLinkResponse {
  final int totalSize;
  final bool done;
  final List<ContentDocumentLink> records;

  ContentDocumentLinkResponse({
    required this.totalSize,
    required this.done,
    required this.records,
  });

  factory ContentDocumentLinkResponse.fromJson(Map<String, dynamic> json) {
    return ContentDocumentLinkResponse(
      totalSize: json['totalSize'] ?? 0,
      done: json['done'] ?? true,
      records: (json['records'] as List?)
          ?.map((e) => ContentDocumentLink.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ContentDocumentLink {
  final String? contentDocumentId;
  final ContentDocument? contentDocument;

  ContentDocumentLink({
    this.contentDocumentId,
    this.contentDocument,
  });

  factory ContentDocumentLink.fromJson(Map<String, dynamic> json) {
    return ContentDocumentLink(
      contentDocumentId: json['ContentDocumentId'],
      contentDocument: json['ContentDocument'] != null
          ? ContentDocument.fromJson(json['ContentDocument'])
          : null,
    );
  }
}

class ContentDocument {
  final String? title;
  final String? fileExtension;
  final String? fileType;
  final int? contentSize;
  final String? contentModifiedDate;
  final String? lastModifiedDate;
  final ContentOwner? owner;
  final String? description;

  ContentDocument({
    this.title,
    this.fileExtension,
    this.fileType,
    this.contentSize,
    this.contentModifiedDate,
    this.lastModifiedDate,
    this.owner,
    this.description,
  });

  factory ContentDocument.fromJson(Map<String, dynamic> json) {
    return ContentDocument(
      title: json['Title'],
      fileExtension: json['FileExtension'],
      fileType: json['FileType'],
      contentSize: json['ContentSize'],
      contentModifiedDate: json['ContentModifiedDate'],
      lastModifiedDate: json['LastModifiedDate'],
      owner: json['Owner'] != null ? ContentOwner.fromJson(json['Owner']) : null,
      description: json['Description'],
    );
  }
}

class ContentOwner {
  final String? id;
  final String? name;

  ContentOwner({
    this.id,
    this.name,
  });

  factory ContentOwner.fromJson(Map<String, dynamic> json) {
    return ContentOwner(
      id: json['Id'],
      name: json['Name'],
    );
  }
}