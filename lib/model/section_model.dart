class SectionModel {
  final String key;
  final Map<String, String> label;
  final int order;

  SectionModel({required this.key, required this.label, required this.order});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      key: json['key'],
      label: Map<String, String>.from(json['label']),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"key": key, "label": label, "order": order};
  }
}
