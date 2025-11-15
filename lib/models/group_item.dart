class GroupItem {
  final String id;
  final String name;
  final String code;
  final String? lastMessage;
  final int unread;

  GroupItem({
    required this.id,
    required this.name,
    required this.code,
    this.lastMessage,
    this.unread = 0,
  });

  factory GroupItem.fromJson(Map<String, dynamic> json) {
    return GroupItem(
      id: json['id'].toString(),
      name: json['name'] as String,
      code: json['code'].toString(),
      lastMessage: json['lastMessage'] as String?,
      unread: json['unread'] as int? ?? 0,
    );
  }
}
