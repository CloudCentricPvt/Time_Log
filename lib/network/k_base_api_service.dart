abstract class KBaseApiServices {
  Future<dynamic> getRequest(String url);
  Future<dynamic> postRequest(dynamic data, String url);
}
