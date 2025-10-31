import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_log/views/all_privacy/help_and_support.dart';
import 'package:time_log/views/all_privacy/leaves_policy_screen.dart';
import 'package:time_log/views/all_privacy/posh_policy.dart';
import 'package:time_log/views/all_privacy/privacy_policies_screen.dart';
import 'package:time_log/views/all_privacy/terms_and_condition_screen.dart';
import 'package:time_log/views/authentication/change_password.dart';
import 'package:time_log/views/authentication/login_screen.dart';
import 'package:time_log/views/leaves/comp_off_history_screen.dart';
import 'package:time_log/views/leaves/request_comp_off_screen.dart';
import 'package:time_log/views/dashBoard/check_in_check_out.dart';
import 'package:time_log/views/holidaysList/holiday_List.dart';
import 'package:time_log/views/home/home_screen.dart';
import 'package:time_log/views/leaves/apply_leave.dart';
import 'package:time_log/views/leaves/balance_leave_screen.dart';
import 'package:time_log/views/leaves/leave_history.dart';
import 'package:time_log/views/leaves/leave_screen.dart';
import 'package:time_log/views/leaves/work_from_home_history.dart';
import 'package:time_log/views/notification/notification_screen.dart';
import 'package:time_log/views/profile/edit_profile.dart';
import 'package:time_log/views/profile/profile_screen.dart';
import 'package:time_log/views/leaves/request_work_from_home.dart';
import 'package:time_log/views/splash/splash_screen.dart';
import 'package:time_log/views/timelogs/create_time_log.dart';
import 'package:time_log/views/timelogs/edit_time_log.dart';
import 'package:time_log/views/timelogs/time_logs_screen.dart';
import 'package:time_log/views/upcoming/upcoming_events.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Permission.microphone.request();
  await GetStorage.init();

  final storage = GetStorage();
  final isActive = storage.read('Is_Active') ?? false;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF84DBFF),
    ),
  );

  runApp( MyApp());

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TimeLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login_screen' : (context) => const LoginScreen(),
        '/home_screen' : (context) => const HomeScreen(),
        '/check_in_check_out_screen': (context) => const CheckInCheckOut(),
        '/time_logs_screen': (context) => const TimeLogsScreen(),
        '/create_time_logs_screen': (context) => const CreateTimeLog(),
        '/edit_time_log_screen': (context) => const EditTimeLog(),
        '/leaves_screen': (context) => const LeaveScreen(),
        '/profile_screen': (context) => const ProfileScreen(),
        '/edit_profile_screen': (context) => const EditProfile(),
        '/change_password_screen': (context) => const ChangePassword(),
        '/leave_policy_screen': (context) => const LeavesPolicyScreen(),
        '/privacy_policy_screen': (context) => const PrivacyPoliciesScreen(),
        '/terms_and_condition_screen': (context) => const TermsAndConditionScreen(),
        '/posh_policy_screen': (context) => const PoshPolicy(),
        '/help_and_support_screen': (context) => const HelpAndSupport(),
        '/holiday_list_screen': (context) => const HolidayList(),
        '/comp_off_screen': (context) => const RequestCompOFF(),
        '/comp_off_history_screen': (context) => const CompOffHistoryScreen(),
        '/request_wfh_screen': (context) => const RequestWorkFromHome(),
        '/apply_leave_screen': (context) => const ApplyLeave(),
        '/leave_history_screen': (context) => const LeaveHistory(),
        '/wfh_history_screen': (context) => const WorkFromHomeHistory(),
        '/balance_leave_screen': (context) => const BalanceLeaveScreen(),
        '/notification_screen': (context) => const NotificationScreen(),
        '/upcoming_events_screen': (context) => const UpcomingEvents(),

      },
    );
  }

}

