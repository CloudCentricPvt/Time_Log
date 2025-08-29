import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/controllers/payroll_controller.dart';

import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  String selectedFilter = "This Year";
  final PayrollController controller = PayrollController();
  late Future<List<dynamic>> _payrollFuture;
  late Future<List<dynamic>> _paySlipFuture;
  final List<Map<String, dynamic>> paySlips = [
    {
      "month": "March Month",
      "status": "Paid",
      "date": "12 March, 2025",
      "salary": "₹ 27,500",
      "days": "21"
    },
    {
      "month": "February Month",
      "status": "Paid",
      "date": "13 Feb, 2025",
      "salary": "₹ 27,500",
      "days": "21"
    },
    {
      "month": "January Month",
      "status": "Paid",
      "date": "15 Jan, 2025",
      "salary": "₹ 27,500",
      "days": "21"
    },
    {
      "month": "December Month",
      "status": "Paid",
      "date": "12 Dec, 2024",
      "salary": "₹ 27,500",
      "days": "21"
    },
    {
      "month": "November Month",
      "status": "Paid",
      "date": "13 Nov, 2024",
      "salary": "₹ 27,500",
      "days": "21"
    },
  ];
  final Map<String, Color> payrollOverViewColor = {
    "Total Payslips": KColors.greenColor,
    "Total CTC": KColors.appPrimaryRed,
    "Per month": KColors.purpleColor,
    "PF Deduction": KColors.orangeColor,
  };

  int currentPage = 1;
  final int itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    _payrollFuture = controller.getThisYearWisePayroll();
    _paySlipFuture = controller.getThisYearPaySlips();
  }

  @override
  Widget build(BuildContext context) {
    final year = selectedFilter == "This Year" ? "2025" : "2024";
    final filteredPaySlips =
    paySlips.where((slip) => slip["date"].contains(year)).toList();
    final visibleItems =
    filteredPaySlips.take(currentPage * itemsPerPage).toList();

    return Scaffold(
        backgroundColor: KColors.lightGreyBGScreen,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: KColors.appPrimary,
          title: KCustomAppBar(
            screenTitle: 'Payroll Info',
            showHistory: false,
            onHistoryTap: () {
              Navigator.pushNamed(context, '/home_screen');
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                width: double.infinity,
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: KColors.appColorWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                      vertical: MediaQuery.of(context).size.height * 0.015,
                    ),
                    child: _thisYearLastYearCardDesign(),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: FutureBuilder<List<dynamic>>(
                  future: selectedFilter == "This Year"
                      ?controller.getThisYearWisePayroll()
                      :controller.getLastYearWisePayroll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No data available"));
                    }
                    final data = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payroll OverView'),
                        SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.01,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _payRollOverViewCard(data[0]["count"],"Total Payslips", KColors.greenColor),
                            _payRollOverViewCard(data[1]["count"],"Total CTC", KColors.appPrimaryRed),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.015,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _payRollOverViewCard(data[2]["count"],"Per month", KColors.purpleColor),
                            _payRollOverViewCard(data[3]["count"], "PF Deduction", KColors.orangeColor),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                ),
                child: FutureBuilder<List<dynamic>>(
                  future: selectedFilter == "This Year"
                      ? controller.getThisYearPaySlips()
                      : controller.getLastYearPaySlips(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No data available"));
                    }
                    final data = snapshot.data!;
                    final visibleItems = data
                        .skip((currentPage - 1) * itemsPerPage)
                        .take(itemsPerPage)
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('All Pay Slips'),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),

                        // Show slips
                        ...visibleItems.map((slip) => Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.width * 0.02),
                          child: _monthlyPaymentSlipCardDesign(
                            slip["monhName"].toString() ?? "",
                            slip["statusOfPayment"].toString() ?? "",
                            slip["generatedDate"].toString() ?? "",
                            slip["netSalary"].toString() ?? "",
                            "${slip["payableDays"].toString() ?? ""}",
                            KColors.appPrimary,
                            KColors.greenColor,
                          ),
                        )),

                        // Pagination
                        if (data.isNotEmpty) ...[
                          Builder(builder: (context) {
                            int totalPages =
                            (data.length / itemsPerPage).ceil();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Previous
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                                  onPressed: currentPage > 1
                                      ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                      : null,
                                ),

                                // Numbers
                                for (int i = 1; i <= totalPages; i++)
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentPage = i;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: currentPage == i
                                              ? KColors.appPrimary
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border:
                                          Border.all(color: KColors.appPrimary),
                                        ),
                                        child: Text(
                                          "$i",
                                          style: TextStyle(
                                            color: currentPage == i
                                                ? Colors.white
                                                : KColors.appPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Next
                                IconButton(
                                  icon:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                  onPressed: currentPage < totalPages
                                      ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                      : null,
                                ),
                              ],
                            );
                          }),
                        ]
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _thisYearLastYearCardDesign() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ChoiceChip(
          label: SizedBox(
            width: MediaQuery.of(context).size.width * 0.42,
            //height: MediaQuery.of(context).size.height * 0.03,
            child: Text(
              'This Year',
              style: TextStyle(
                color: selectedFilter == "This Year"
                    ? KColors.appColorWhite
                    : KColors.appPrimary,

              ),

              textAlign: TextAlign.center,
            ),
          ),
          selected: selectedFilter == "This Year",
          selectedColor: KColors.appPrimary,
          backgroundColor: KColors.appColorWhite,
          showCheckmark: false,
          labelPadding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: KColors.appPrimary)),
          onSelected: (bool selected) {
            if (selected) {
              setState(() {
                selectedFilter = "This Year";
                _payrollFuture = controller.getThisYearWisePayroll();
              });
            }
          },
        ),

        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        ChoiceChip(
          label: SizedBox(
            width: MediaQuery.of(context).size.width * 0.42,
            //height: MediaQuery.of(context).size.height * 0.030,
            child: Text(
              "Last Year",
              style: TextStyle(
                color: selectedFilter == "Last Year"
                    ? KColors.appColorWhite // When selected
                    : KColors.appPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          selected: selectedFilter == "Last Year",
          selectedColor: KColors.appPrimary,
          backgroundColor: KColors.appColorWhite,
          showCheckmark: false,
          labelPadding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: KColors.appPrimary)),
          onSelected: (bool selected) {
            if (selected) {
              setState(() {
                selectedFilter = "Last Year";
                _payrollFuture = controller.getLastYearWisePayroll();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _payRollOverViewCard(
      String amountValue, String amountType, Color amountTypeTextColor) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width * 0.45,
      child: Card(
        elevation: 0,
        color: KColors.appColorWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(amountValue),
              Text(
                amountType,
                style: TextStyle(
                  color: amountTypeTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthlyPaymentSlipCardDesign(
      String monthName,
      String statusOfPayment,
      String generatedDate,
      String netSalary,
      String payableDays,
      Color monthNameTextColor,
      Color statusOfPaymentTextColor) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.23,
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: KColors.appColorWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthName,
                    style: TextStyle(color: monthNameTextColor, fontSize: 14),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.width * 0.01),
                    decoration: BoxDecoration(
                      color: statusOfPaymentTextColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      statusOfPayment,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Divider(
                thickness: 1,
                height: 1,
                color: KColors.grayLight,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                children: [
                  Text(
                    "Generated date: ",
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(generatedDate)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Net Salary: ",
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(netSalary)
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Payable Days: ",
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(payableDays)
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.08,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // download logic
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/download_icon_payroll.svg',
                    width: 20,
                    height: 20,
                  ),
                  label: Text(
                    "Download",
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade400, width: 1),
                    // border color & width
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10), // rounded corners
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
