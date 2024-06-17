import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class globaldomain {
  static Future<String> insert_Domain() async {
    // qA test server domain
    String domain = "https://bulldog-quiet-ghastly.ngrok-free.app";
    //end domain
    // production domain
    // String domain = "internal-portal.lto.local";
    //end domain

    //  https://internal-portal.lto.local/ords/dl_user_management/authentication/latest/authenticate

    // https://jwt.api.qa.lto.direct/ords/dl_user_management/authentication/latest/authenticate

    var domain1 = domain;
    return domain1;
  }

  // ignore: non_constant_identifier_names
  static Future<Color> ColorAppbar() async {
    // qA test server domain
    // Color colorsapps = Color.fromARGB(255, 241, 8, 190);
    //end domain

    // production domain
    Color colorsapps = const Color.fromARGB(255, 0, 55, 145);
//end domain
    var Colors1 = colorsapps;
    return Colors1;
  }

  static Future<String> Version() async {
    // qA test server domain
    String domain = "0.5";
    //end domain

    // production domain
    //  var domain = Colors.pink;
    //end domain

    //  https://internal-portal.lto.local/ords/dl_user_management/authentication/latest/authenticate

    // ignore: non_constant_identifier_names
    var Colors1 = domain;
    return Colors1;
  }
}
