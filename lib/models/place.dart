class Place {
  final String name;
  final String category;
  final String description;
  final String location;
  final String contact;
  final String image;

  Place({
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.contact,
    required this.image,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      category: json['category'],
      description: json['description'],
      location: json['location'],
      contact: json['contact'],
      image: json['image'],
    );
  }
}