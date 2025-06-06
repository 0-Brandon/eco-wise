import 'package:eco_wise/Db_helpers/db_users.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/users.dart';

class UserNotifier extends StateNotifier<UserModel?>{
  final Ref ref;
  UserNotifier(super._state, {required this.ref});

  Future<void> loadCurrentUser(String uid) async{
    state = await DBUserProfile.readUserModel(uid);
  }
  Future<bool> createAndSetUser(UserModel user) async{
    final success = await DBUserProfile.writeUserModel(user);
    if(success){
      state = user;
    }
    return success;
  }
  Future<bool> updateUser(UserModel newUser) async{
    final success = await DBUserProfile.writeUserModel(newUser);
    if(success){
      state = newUser;
    }
    return success;
  }
  void clearUser(){
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref){
  return UserNotifier(null, ref: ref);
});