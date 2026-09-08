class AccountListRes {
  final String id;
  final String name;

  AccountListRes({
    required this.id,
    required this.name,
  });

  factory AccountListRes.fromJson(Map<String, dynamic> json) {
    return AccountListRes(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
    );
  }
}

class Accounts {
  final int totalSize;
  final bool done;
  final List<AccountListRes> records;

  Accounts({
    required this.totalSize,
    required this.done,
    required this.records,
  });

  factory Accounts.fromJson(Map<String, dynamic> json) {
    return Accounts(
      totalSize: json['totalSize'] ?? 0,
      done: json['done'] ?? true,
      records: (json['records'] as List?)
          ?.map((e) => AccountListRes.fromJson(e))
          .toList() ??
          [],
    );
  }
}