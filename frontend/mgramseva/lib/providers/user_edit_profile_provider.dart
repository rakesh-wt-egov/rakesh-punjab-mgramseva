import 'dart:async';

import 'package:mgramseva/model/userProfile/user_profile.dart';
import 'package:mgramseva/repository/user_edit_profile_repo.dart';
import 'package:flutter/material.dart';

class UserEditProfileProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();

  dispose() {
    streamController.close();
    super.dispose();
  }

  Future<void> editUserProfileDetails(body) async {
    try {
      var edituserResponse = await UserEditProfileRepository().editProfile(body);
      if (edituserResponse != null) {
        streamController.add(edituserResponse);
      }
    } catch (e) {
      print(e);
      streamController.addError('error');
    }
  }

  Future<void> getEditUser() async {
    try {
      streamController.add(User());
    } catch (e) {
      streamController.addError('error');
    }
  }

  void onChangeOfGender(String gender, User user) {
    user.gender = gender;
    notifyListeners();
  }

}