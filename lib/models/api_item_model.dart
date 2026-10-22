class ApiItemModel {
  final String id;
  final String title;
  final String category;

  ApiItemModel({
    required this.id,
    required this.title,
    required this.category,
  });

  factory ApiItemModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id') || !json.containsKey('title') || json['title'] == null) {
      throw const FormatException('JSON Invalid: Missing required fields');
    }
    return ApiItemModel(
      id: json['id'].toString(),
      title: json['title'].toString(),
      category: json['category']?.toString() ?? 'Uncategorized',
    );
  }
}