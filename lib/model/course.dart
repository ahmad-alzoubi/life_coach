import 'package:coach_life/model/coach.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String image;
  final String price;
  final String coach;
  final String contentType;
  final String contentPath;
  final bool isPurchased;
  final Coach coachDetails;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.coach,
    required this.contentType,
    required this.contentPath,
    required this.isPurchased,
    required this.coachDetails,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      image: json['image'] ?? '',
      price: json['price'].toString(),
      coach: json['coach'],
      contentType: json['content_type'],
      contentPath: json['content_url'],
      isPurchased: json['is_purchased'] ?? false,
      coachDetails: Coach.fromJson(json['coachDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'coach': coach,
      'content_type': contentType,
      'content_url': contentPath,
      'is_purchased': isPurchased,
      'coachDetails': coachDetails.toJson(),
    };
  }
}
