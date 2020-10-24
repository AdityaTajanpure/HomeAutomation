import 'package:home_automation/core/models/models.dart';
import 'package:home_automation/core/viewmodels/home_model.dart';
import 'package:home_automation/ui/shared/globals.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContentWidget extends StatelessWidget {
  final int index;
  final Color color;
  ContentWidget({this.index, this.color});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeModel>(context);
    final homeData = HomeData.fromMap(Global.homeItems[index]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
          ),
          height: 100,
          width: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(
                homeData.icon,
                color: Global.darkBlue,
              ),
              Text(
                model.switchValues[index]
                    ? '${(model.sliderValues[index] * 100).round()}%'
                    : 'Off',
                style: TextStyle(
                  color: Global.darkBlue,
                  fontSize: 14.0,
                  fontFamily: 'Sf',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              homeData.location,
              style: TextStyle(
                color: color,
                fontSize: 16.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              homeData.power,
              style: TextStyle(
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
