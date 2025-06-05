import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/users.dart';

class DBUserProfile {
  static StreamSubscription? _userStream;
  static Future<bool> writeUserModel(UserModel user) async{
    bool success = false;

    var db = FirebaseFirestore.instance;
    if(FirebaseAuth.instance.currentUser !=null){
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? currUser = auth.currentUser;
      if(currUser == null){
        return false;
      }
      String uid = currUser.uid;
      try{
        await db.collection('users').doc(uid).set(user.toFirestore(), SetOptions(merge:true));
      }
      catch(e){
        print(e);
        success = false;
      }
    }
    return success;
  }
}