class Inspection {
  int? id;
  String propertyName;
  String description;
  String rating;
  double latitude;
  double longitude;
  String dateCreated;
  List<String> photos;

  Inspection({
    this.id,
    required this.propertyName,
    required this.description,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.dateCreated,
    required this.photos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_name': propertyName,
      'description': description,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'date_created': dateCreated,
      'photos': photos.join(','),
    };
  }

  factory Inspection.fromMap(Map<String, dynamic> map) {
    return Inspection(
      id: map['id'],
      propertyName: map['property_name'],
      description: map['description'],
      rating: map['rating'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      dateCreated: map['date_created'],
      photos: map['photos'].split(','),
    );
  }
}
