import 'dart:io';

class Register {
  final File image;
  final String name;
  final String phone;
  final String bio;
  final double price;

  Register({
    required this.image,
    required this.name,
    required this.phone,
    required this.bio,
    required this.price,
  });

  Register copyWith({
    File? image,
    String? name,
    String? phone,
    String? bio,
    double? price,
  }) {
    return Register(
      image: image ?? this.image,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'phone': phone,
      'bio': bio,
      'price': price,
    };
  }

  factory Register.fromMap(Map<String, dynamic> map) {
    return Register(
      image: map['image'],
      name: map['name'],
      phone: map['phone'],
      bio: map['bio'],
      price: map['price'],
    );
  }
}