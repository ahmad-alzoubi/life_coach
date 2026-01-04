class Intro {
  final String title;
  final String description;
  final String image;

  Intro({required this.title, required this.description, required this.image});

  factory Intro.fromJson(Map<String, dynamic> json) {
    return Intro(
      title: json['title'],
      description: json['description'],
      image: json['image'],
    );
  }
}