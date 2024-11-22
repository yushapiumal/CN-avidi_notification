import 'package:avidi_notification/ui/brackPoint.dart';
import 'package:flutter/material.dart';


class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    Key? key,
    required this.mobileBody,
    required this.tabletBody,
    //  this.desktopBody,
  }) : super(key: key);

  final Widget mobileBody;
  final Widget tabletBody;
  // final Widget desktopBody;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      if (constraint.maxWidth >= TabletBrakePoint) {
        return tabletBody;
      }
      return mobileBody;
    });
  }
}
