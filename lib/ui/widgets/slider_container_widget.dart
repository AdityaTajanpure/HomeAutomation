import 'dart:convert';
import 'package:home_automation/core/enums/enum.dart';
import 'package:home_automation/core/viewmodels/home_model.dart';
import 'package:home_automation/ui/shared/globals.dart';
import 'package:home_automation/ui/widgets/content_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

class RectangleClipper extends CustomClipper<Rect> {
  final double offset;
  RectangleClipper({this.offset});

  @override
  Rect getClip(Size size) {
    Rect rect = Rect.fromLTRB(offset, 0.0, size.width, size.height);
    return rect;
  }

  @override
  bool shouldReclip(RectangleClipper oldClipper) => true;
}

class SliderContainerWidget extends StatefulWidget {
  final Color color;
  final int index;
  final BluetoothConnection connection;
  SliderContainerWidget({this.color, this.index, this.connection});

  @override
  _SliderContainerWidgetState createState() => _SliderContainerWidgetState();
}

class _SliderContainerWidgetState extends State<SliderContainerWidget> {
  void _sendMessage(String text) async {
    print(widget.connection.isConnected);
    text = text.trim();
    if (text.length > 0) {
      try {
        widget.connection.output.add(utf8.encode(text + "\r\n"));
        await widget.connection.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeModel>(context);
    final width = MediaQuery.of(context).size.width;

    Widget sliderAnimation() {
      return IgnorePointer(
        ignoring: true,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            curve: Curves.easeInOutQuart,
            duration: Duration(
              milliseconds: model.state == ViewState.Busy ? 0 : 500,
            ),
            width:
                model.widthValues[widget.index] ?? model.getStartWidth(width),
            height: Global.boxHeight,
            decoration: BoxDecoration(
              color: model.switchValues[widget.index]
                  ? Global.mediumBlue
                  : Global.darkGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
            ),
          ),
        ),
      );
    }

    Widget sliderValues() {
      return IgnorePointer(
        ignoring: model.switchValues[widget.index] ? false : true,
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: Global.trackHeight,
            overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 100.0, right: 80.0),
            child: Slider(
              activeColor: Colors.transparent,
              inactiveColor: Colors.transparent,
              value: model.sliderValues[widget.index],
              onChanged: (value) {
                model.setSliderValue(widget.index, value);
                model.setWidth(widget.index, width);
              },
            ),
          ),
        ),
      );
    }

    Widget cupertinoSwitch() {
      return Container(
        width: Global.boxWidth,
        height: Global.boxHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: CupertinoSwitch(
          activeColor: Colors.pinkAccent,
          value: model.switchValues[widget.index],
          onChanged: (value) {
            model.setSwitchValues(widget.index, value);
            model.setWidth(widget.index, width);
            switch (widget.index) {
              case 0:
                if (model.switchValues[widget.index])
                  _sendMessage('b');
                else
                  _sendMessage('a');
                break;
              case 1:
                if (model.switchValues[widget.index])
                  _sendMessage('f');
                else
                  _sendMessage('e');
                break;
              case 2:
                if (model.switchValues[widget.index])
                  _sendMessage('h');
                else
                  _sendMessage('g');
                break;
              case 3:
                if (model.switchValues[widget.index])
                  _sendMessage('d');
                else
                  _sendMessage('c');
                break;
              default:
            }
          },
        ),
      );
    }

    Widget content() {
      return IgnorePointer(
        ignoring: true,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: 100,
              child: ContentWidget(
                color: Global.darkBlue,
                index: widget.index,
              ),
            ),
            ClipRect(
              clipper: RectangleClipper(
                offset: model.getFormula(widget.index, width),
              ),
              child: Container(
                height: 100,
                child: AnimatedOpacity(
                  curve: Curves.easeInOutQuart,
                  opacity: model.switchValues[widget.index] ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: ContentWidget(
                    color: Global.mediumBlue,
                    index: widget.index,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        sliderAnimation(),
        sliderValues(),
        content(),
        cupertinoSwitch(),
      ],
    );
  }
}
