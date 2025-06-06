import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/users.dart';

class DBUserProfile {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static Future<bool> writeUserModel(UserModel user) async{
    try{
      await db.collection('users').doc(user.uid).set(user.toFirestore(), SetOptions(merge:true));
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }
  static Future<UserModel?> readUserModel (String uid) async {
    try {
      final userDoc = await db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;
    }
    catch(e){
      print(e);
      return null;
    }
  }

  static Future<bool> deleteUserModel(String uid) async{
    try {
      await db.collection('users').doc(uid).delete();
      return true;
    }
    catch(e){
      print(e);
      return false;
    }
  }
}