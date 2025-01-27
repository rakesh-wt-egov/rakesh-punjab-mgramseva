import 'dart:async';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/widgets/toast/toast_animation.dart';

import 'package:flutter/material.dart';

class ToastUtils {
  static Timer? toastTimer;
  static OverlayEntry? _overlayEntry;

  static void showCustomToast(
      BuildContext context, String message, String type) {
    if (toastTimer != null) {
      print(toastTimer!.isActive);
    }
    if (toastTimer == null || toastTimer!.isActive == false) {
      print(toastTimer);
      if (toastTimer != null) {
        print(toastTimer!.isActive);
      }
      _overlayEntry = createOverlayEntry(context, message, type);

      Overlay.of(context)!.insert(_overlayEntry!);
      toastTimer = Timer(Duration(seconds: 10), () {
        if (_overlayEntry != null) {
          _overlayEntry!.remove();
        }
      });
    }
  }

  static OverlayEntry createOverlayEntry(
      BuildContext context, String message, String type) {
    return OverlayEntry(
        builder: ((context) => Positioned(
              bottom: 50.0,
              width: MediaQuery.of(context).size.width > 720
                  ? MediaQuery.of(context).size.width / 4
                  : MediaQuery.of(context).size.width,
              left: MediaQuery.of(context).size.width > 720
                  ? MediaQuery.of(context).size.width / 2.55
                  : 0,
              child: (Material(
                elevation: 10.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 13, bottom: 10),
                  decoration: BoxDecoration(
                      color: type == 'ERROR' ? Colors.red : Colors.green[900]),
                  child: Align(
                    alignment: Alignment.center,
                    child: SlideInToastMessageAnimation(Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          type == 'ERROR'
                              ? Icons.info_outline_rounded
                              : Icons.check_circle_outline_rounded,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: Text(
                            ApplicationLocalizations.of(context)
                                .translate(message),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            toastTimer!.cancel();
                            _overlayEntry!.remove();
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        )
                      ],
                    )),
                  ),
                ),
              )),
            )));
  }
}
