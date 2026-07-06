class OptionModel {
  final String value;
  final Map<String, String> label;

  OptionModel({required this.value, required this.label});

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      value: json['value'] ?? '',
      label: Map<String, String>.from(json['label'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {"value": value, "label": label};
  }
}
