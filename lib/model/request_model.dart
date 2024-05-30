class BookingModel {
  final String title;
  final String description;
  final DateTime createdAt;
  final String requesterName; 
  final String requesterId; 
  final String workerId;
  String status;

  BookingModel({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.requesterName,
    required this.requesterId,
    required this.workerId,
    this.status = 'en cours',
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']), 
      requesterName: map['requesterName'],
      requesterId: map['requesterId'],
      workerId: map['workerId'],
      status: map['status'] ?? 'en cours',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(), 
      'requesterName': requesterName,
      'requesterId': requesterId,
      'workerId': workerId,
      'status': status,
    };
  }
}
