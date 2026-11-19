/// Represents a civic issue report stored in MongoDB (`fixmytown.reports`).
///
/// Matches `backend/models/Report.js`:
/// `_id`, `title`, `description`, `category`, `imageUrl`, `status`,
/// `user`, `state`, `area`, `createdAt`, `updatedAt`.
class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String status;
  final String userId;
  final String state;
  final String? area;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.status,
    required this.userId,
    required this.state,
    this.area,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    // Handle `user` being either an ObjectId string or a populated user map.
    String parsedUserId = '';
    final rawUser = json['user'];
    if (rawUser is String) {
      parsedUserId = rawUser;
    } else if (rawUser is Map<String, dynamic>) {
      parsedUserId = (rawUser['_id'] ?? rawUser['id'] ?? '').toString();
    }

    return Report(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'other').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      userId: parsedUserId,
      state: (json['state'] ?? '').toString(),
      area: json['area'] != null && json['area'].toString().trim().isNotEmpty
          ? json['area'].toString().trim()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'status': status,
      'user': userId,
      'state': state,
      if (area != null) 'area': area,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
