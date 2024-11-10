class Parked {
  final String parking;
  final bool exit;
  final DateTime time;
  final String user;
  Parked({
    required this.parking,
    required this.exit,
    required this.time,
    required this.user,
  });

  factory Parked.fromJson(Map<String, dynamic> json) {
    return Parked(
      parking: json['parking_id'],
      exit: json['exit'],
      time: DateTime.parse(json['time']),
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parking_id': parking,
      'exit': exit,
      'time': time.toIso8601String(),
      'user': user,
    };
  }
}
