class Review {
  final String parkingId;
  final String rate; // keeping it as String as per your specification
  final String review;
  final String userId;

  Review({
    required this.parkingId,
    required this.rate,
    required this.review,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'parkingId': parkingId,
      'rate': rate,
      'review': review,
      'userId': userId,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      parkingId: map['parkingId'] as String,
      rate: map['rate'] as String,
      review: map['review'] as String,
      userId: map['userId'] as String,
    );
  }
}
