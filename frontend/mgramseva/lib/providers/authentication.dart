import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/repository/authentication.dart';
import 'package:mgramseva/repository/user_profile_repo.dart';
import 'package:mgramseva/routers/Routers.dart';
import 'package:mgramseva/utils/Locilization/application_localizations.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/custom_exception.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:mgramseva/utils/notifyers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart';

class AuthenticationProvider with ChangeNotifier {
  validateLogin(BuildContext context, String userName, String password) async {
    /// Unfocus the text field
    FocusScope.of(context).unfocus();

    try {
      var body = {
        "username": userName,
        "password": password,
        "scope": "read",
        "grant_type": "password",
        "tenantId": "pb",
        "userType": "EMPLOYEE"
      };

      var headers = {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        "Access-Control-Allow-Origin": "*",
        "authorization": "Basic ZWdvdi11c2VyLWNsaWVudDo=",
      };

      Loaders.showLoadingDialog(context);

      var loginResponse =
          await AuthenticationRepository().validateLogin(body, headers);

      Navigator.pop(context);

      if (loginResponse != null) {
        print(loginResponse.toJson());
        print(loginResponse.userRequest!.toJson());
        var userInfo = await AuthenticationRepository().getProfile({
          "tenantId": loginResponse.userRequest!.tenantId,
          "id": [loginResponse.userRequest!.id],
          "mobileNumber": loginResponse.userRequest!.mobileNumber
        }, loginResponse.accessToken!);
        Navigator.pop(context);
        if (userInfo.user!.first.defaultPwdChgd == false) {
          var commonProvider =
              Provider.of<CommonProvider>(context, listen: false);
          commonProvider.loginCredentails = loginResponse;

          commonProvider.userProfile = userInfo;
          Navigator.pushNamed(context, Routes.UPDATE_PASSWORD,
              arguments: loginResponse);
          return;
        } else {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.HOME, (route) => false);
        }
      }
    } on CustomException catch (e, s) {
      Navigator.pop(context);
      if (ErrorHandler.handleApiException(context, e, s)) {
        Notifiers.getToastMessage(context, e.message, 'ERROR');
      }
    } catch (e, s) {
      Navigator.pop(context);
      ErrorHandler.logError(e.toString(), s);
      Notifiers.getToastMessage(context, e.toString(), 'ERROR');
    }
  }

  void callNotifyer() {
    notifyListeners();
  }
}
