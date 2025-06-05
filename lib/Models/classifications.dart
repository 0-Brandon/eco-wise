import 'package:cloud_firestore/cloud_firestore.dart';

class ClassificationModel{
  final String user;
  final Timestamp time;
  final bool correct;
  final String type;
  final String imageURL;

  ClassificationModel({
    required this.user,
    required this.time,
    required this.correct,
    required this.type,
    this.imageURL = '',
  });

  factory ClassificationModel.fromFirestore(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClassificationModel(
      user: data['user'],
      time: data['time'],
      correct: data['correct'],
      type: data['type'],
      imageURL: data['imageURL'],
    );
  }
  Map<String, dynamic> toFirestore(){
    return {
      'user': user,
      'time': time,
      'correct': correct,
      'type':type,
      'imageURL': imageURL,
    };
  }
}