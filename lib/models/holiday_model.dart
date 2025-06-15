class HolidayModel {
  final String name;
  final String date;

  HolidayModel({required this.name, required this.date});

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      name: json['name'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
