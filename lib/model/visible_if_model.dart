class VisibleIfModel {
  final String field;
  final String op;
  final dynamic value;

  VisibleIfModel({
    required this.field,
    required this.op,
    required this.value,
  });

  factory VisibleIfModel.fromJson(Map<String, dynamic> json) {
    return VisibleIfModel(
      field: json['field'],
      op: json['op'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "field": field,
      "op": op,
      "value": value,
    };
  }
}
