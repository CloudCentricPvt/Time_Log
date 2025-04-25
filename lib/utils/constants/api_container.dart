class KApiContainer {
  KApiContainer._();

  static String BASE_URL = "https://cloudcentric--qb.sandbox.my.salesforce.com/services/";

  static KApiEndPoints kApiEndPoints = KApiEndPoints();
}

class KApiEndPoints {

  /// -- Authentication
  static String login = "${KApiContainer.BASE_URL}apexrest/ValidateCredentials";
  static String checkIn = "${KApiContainer.BASE_URL}apexrest/CheckIn";
  static String checkOut = "${KApiContainer.BASE_URL}apexrest/CheckOut";
  static String allTimeLogs = "${KApiContainer.BASE_URL}apexrest/FilledTimeLogEntries";
  static String createTimeLog = "${KApiContainer.BASE_URL}apexrest/CreateTimeLog";
  static String changPassWord = "${KApiContainer.BASE_URL}apexrest/ChangePassword";


}
