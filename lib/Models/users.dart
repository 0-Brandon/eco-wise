import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String name;
  final String uid;
  final String email;
  final Map<String, dynamic>? lessons;
  final GeoPoint? location;
  final int ecopoints;
  final List<String> friends;
  final Map<String, dynamic>? achievements;
  final String imageURL;

  UserModel({
    required this.name,
    required this.uid,
    required this.email,
    this.lessons,
    this.location,
    this.ecopoints = 0,
    List<String>? friends,
    this.achievements,
    this.imageURL = '',
  }) : friends = friends ?? [];

  factory UserModel.fromFirestore(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      name: data['name'],
      uid: doc.id,
      email: data['email'],
      lessons: data['lessons'],
      location: data['location'],
      ecopoints: data['ecopoints'],
      friends: data['friends'],
      achievements: data['achievements'],
      imageURL: data['imageURL'],
    );
  }
  Map<String, dynamic> toFirestore(){
    return {
      'name': name,
      'uid': uid,
      'email': email,
      'lessons':lessons,
      'location':location,
      'ecopoints':ecopoints,
      'friends': friends,
      'achievements': achievements,
      'imageURL': imageURL,
    };
  }
}