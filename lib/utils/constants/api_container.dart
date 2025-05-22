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
  static String getDashboardDetails = "${KApiContainer.BASE_URL}apexrest/DashboardAPI";
  static String allTimeLogs = "${KApiContainer.BASE_URL}apexrest/FilledTimeLogEntries";
  static String createTimeLog = "${KApiContainer.BASE_URL}apexrest/CreateTimeLog";
  static String updateTimeLog = "${KApiContainer.BASE_URL}apexrest/UpdateTimeLog";
  static String changPassWord = "${KApiContainer.BASE_URL}apexrest/ChangePassword";
  static String checkInOutDetails = "${KApiContainer.BASE_URL}apexrest/CheckInCheckOutDetails";
  static String getAssignProject = "${KApiContainer.BASE_URL}apexrest/AssignedProjects";
  static String getAssignTask = "${KApiContainer.BASE_URL}apexrest/TaskTypes";
  static String privacyPolicyPDF = "${KApiContainer.BASE_URL}apexrest/GetPolicyPDF?policyName=Privacy Policy";
  static String leavePolicyPDF = "${KApiContainer.BASE_URL}apexrest/GetPolicyPDF?policyName=Leave Policy";
  static String termsAndConditionPDF = "${KApiContainer.BASE_URL}apexrest/GetPolicyPDF?policyName=Terms and Conditions";
  static String applyLeave = "${KApiContainer.BASE_URL}apexrest/RequestLeave";
  static String getAppliedLeave = "${KApiContainer.BASE_URL}apexrest/AppliedLeaveDetails";
  static String applyCompOff = "${KApiContainer.BASE_URL}apexrest/RequestCompOff";
  static String getCompOff = "${KApiContainer.BASE_URL}apexrest/CompOffDetails";
  static String applyWFH = "${KApiContainer.BASE_URL}apexrest/RequestWorkFromHome";
  static String wfhHistory = "${KApiContainer.BASE_URL}apexrest/AppliedWFHDetails";
  static String getAnnualLeaveDetails = "${KApiContainer.BASE_URL}apexrest/AnnualLeaveDetailsAPI";
  static String getUpcomingAllLeave = "${KApiContainer.BASE_URL}apexrest/UpcomingLeave";
  static String getUpcomingHolidays = "${KApiContainer.BASE_URL}apexrest/UpcomingHolidays";
  static String getOfficialHolidays = "${KApiContainer.BASE_URL}apexrest/HolidayList";
  static String getProfileDetails = "${KApiContainer.BASE_URL}apexrest/ProfileDetailsAPI";
  static String updateProfile = "${KApiContainer.BASE_URL}apexrest/ProfileDetailsUpdateAPI";


}
