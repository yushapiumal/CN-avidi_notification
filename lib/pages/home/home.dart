


import 'package:avidi_notification/pages/home/devices/MobileHome.dart';
import 'package:avidi_notification/pages/home/devices/TabletHome.dart';
import 'package:avidi_notification/ui/responciveLayout.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static String routeName = " ";
  final String token; 

   const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: const  TodayFlightsPageMob(),
      tabletBody: TodayFlightsPageTab(token: widget.token,),
    );
  }
}
