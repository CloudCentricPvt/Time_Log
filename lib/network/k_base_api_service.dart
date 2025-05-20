import 'package:flutter/cupertino.dart';

abstract class KBaseApiServices {
  Future<dynamic> getRequest(String url,BuildContext context);
  Future<dynamic> postRequest(dynamic data, String url,BuildContext context);
}
