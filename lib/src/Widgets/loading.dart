import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants.dart';

loadingScreen() {
  return SpinKitFoldingCube(
    color: kPrimaryColor,
    duration: Duration(seconds: 2),
  );
}

Widget showCircularProgress(_loading) {
  if (_loading) {
    return Container(
      child: Center(
        child: SpinKitFoldingCube(
          color: kPrimaryColor,
          duration: Duration(seconds: 2),
        ),
      ),
    );
  } else {
    return Container(
      height: 0,
      width: 0,
    );
  }
}
