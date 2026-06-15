class ItemModel {
  final String? id;
  final String title;
  final String location;
  final String description;
  final String status;
  final String date;
  final String contact;
  final String imageUrl;
  final String? reportedBy;

  ItemModel({
    this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.status,
    required this.date,
    required this.contact,
    required this.imageUrl,
    this.reportedBy,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map, String id) {
    return ItemModel(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? '',
      date: map['date'] ?? '',
      contact: map['contact'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      reportedBy: map['reportedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'description': description,
      'status': status,
      'date': date,
      'contact': contact,
      'imageUrl': imageUrl,
      'reportedBy': reportedBy,
    };
  }
}