import '../../../models/all_time_log_res.dart';
import '../../../models/annual_leave_details_res.dart';

class ChatbotMemory {
  static AllTimeLogResponse? allTimeLogResponse;
  static AnnualLeaveDetailsResponse? annualLeaveDetailsResponse;

  static bool get hasTimeLog =>
      allTimeLogResponse != null &&
          allTimeLogResponse!.data != null;

  static bool get hasLeaveDetails =>
      annualLeaveDetailsResponse != null &&
          annualLeaveDetailsResponse!.leaveDetails.isNotEmpty;

  static double get totalMonthlyHours =>
      allTimeLogResponse?.data?.totalMonthlyHours ?? 0;

  static int get pendingCount =>
      allTimeLogResponse?.data?.pendingCount ?? 0;

  static int get rejectedCount =>
      allTimeLogResponse?.data?.rejectedCount ?? 0;

  static int get totalLogs =>
      allTimeLogResponse?.data?.lstTimeLogs?.length ?? 0;

  static List<LstTimeLog> getLogsByDate(String date) {
    return allTimeLogResponse?.data?.lstTimeLogs
        ?.where((log) => log.formattedDate == date)
        .toList() ??
        [];
  }

  static List<LstTimeLog> getRejectedLogs(String status) {
    return allTimeLogResponse?.data?.lstTimeLogs
        ?.where(
          (log) => log.status?.toLowerCase() == '$status',
    )
        .toList() ??
        [];
  }

  static int getTotalMinutesByDate(String date) {
    final logs = getLogsByDate(date);

    int totalMinutes = 0;

    for (final log in logs) {
      totalMinutes += (log.hours ?? 0) * 60;
      totalMinutes += (log.minutes ?? 0);
    }

    return totalMinutes;
  }

  static String getRejectedLogsText(String status) {
    final logs = getRejectedLogs(status);

    if (logs.isEmpty) {
      return "You have no $status timelogs.";
    }

    return logs.map((log) {
      return "• ${log.formattedDate} | ${log.projectName} | ${log.taskName}";
    }).join('\n');
  }

  static String getLeaveBalanceText() {
    if (!hasLeaveDetails) return "I don't have your leave balance data yet.";
    final data = annualLeaveDetailsResponse!.leaveDetails.first;
    return "Your Leave Balance:\n"
        "• Casual Leave (CL): ${data.balancedCl} left / ${data.totalCl} total\n"
        "• Sick Leave (SL): ${data.balancedSl} left / ${data.totalSl} total\n"
        "• Earned Leave (EL): ${data.balancedEl} left / ${data.totalEl} total\n"
        "• Comp Off: ${data.balancedCompOff} left / ${data.totalCompOffLeave} total\n"
        "• LWP Availed: ${data.availedLwp} days";
  }

}
