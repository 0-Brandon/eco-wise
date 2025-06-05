import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/users.dart';

class UserNotifier extends StateNotifier<UserModel>{
  final Ref ref;
  UserNotifier(super._state, {required this.ref});

  Future<void> _loadUser(String uid) async{
    final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if(userDoc.exists){
      state = UserModel.fromFirestore(userDoc);
    }
    else{

    }
  }


}