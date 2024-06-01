class BookingModel {
  // Champs de la classe BookingModel
  final String title;
  final String description;
  final DateTime createdAt;
  final String requesterName;
  final String requesterId;
  final String workerId;
  String status;

  // Constructeur de la classe BookingModel
  BookingModel({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.requesterName,
    required this.requesterId,
    required this.workerId,
    this.status = 'en cours',  // Statut par défaut de la réservation
  });

  // Factory constructor pour créer une instance de BookingModel à partir d'une carte (map)
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),  // Conversion de la chaîne en DateTime
      requesterName: map['requesterName'],
      requesterId: map['requesterId'],
      workerId: map['workerId'],
      status: map['status'] ?? 'en cours',  // Utilisation du statut par défaut si non fourni
    );
  }

  // Méthode pour convertir une instance de BookingModel en une carte (map)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),  // Conversion de DateTime en chaîne ISO 8601
      'requesterName': requesterName,
      'requesterId': requesterId,
      'workerId': workerId,
      'status': status,
    };
  }
}
