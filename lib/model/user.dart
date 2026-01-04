import 'package:coach_life/model/coach_attributes.dart';
import 'package:coach_life/model/media.dart';

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? phone;
  final String? type;
  final String? bio;
  final String? price;
  final List<Media>? media;
  final String? createdAt;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.type,
    this.bio,
    this.price,
    this.media,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      password: json['password']?.toString(),
      phone: json['phone']?.toString(),
      type: json['type']?.toString(),
      bio: json['bio']?.toString(),
      price: json['price']?.toString(),
      media: json['media'] != null
          ? List<Media>.from(json['media'].map((x) => Media.fromJson(x)))
          : null,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'type': type,
      'bio': bio,
      'price': price,
      'media': media?.map((x) => x.toJson()).toList(),
      'created_at': createdAt,
    };
  }
}
