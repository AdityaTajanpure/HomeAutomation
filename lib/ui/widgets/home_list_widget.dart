import 'dart:convert';
import 'dart:typed_data';

import 'package:home_automation/core/viewmodels/home_model.dart';
import 'package:home_automation/ui/shared/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'slider_container_widget.dart';

class HomeListWidget extends StatefulWidget {
  final width;
  const HomeListWidget({Key key, this.width}) : super(key: key);

  @override
  _HomeListWidgetState createState() => _HomeListWidgetState();
}

class _HomeListWidgetState extends State<HomeListWidget> {
  List<bool> values = [false, false, false, false];
  List<double> widths = [null, null, null, null];
  BluetoothDevice myDevice =
      new BluetoothDevice(name: 'HC-05', address: '98:D3:32:30:A2:CD');
  BluetoothConnection connection;
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;

  @override
  void initState() {
    BluetoothConnection.toAddress(myDevice.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      _sendMessage('s');
      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
    super.initState();
  }

  @override
  void dispose() {
    connection.dispose();
    connection = null;
    super.dispose();
  }

  Future setValues(HomeModel model, width, index) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      model.setswitchValues = values;
      model.setWidthValues = widths;
      setState(() {});
    });
    return Future.delayed(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeModel>(context);
    final width = MediaQuery.of(context).size.width;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: Global.homeItems.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
          child: FutureBuilder(
              future: setValues(model, width, index),
              builder: (context, snapshot) {
                return SliderContainerWidget(
                  index: index,
                  color: Global.mediumBlue,
                  connection: connection,
                );
              }),
        );
      },
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
    switch (dataString) {
      case 'T':
        values[0] = true;
        break;
      case 't':
        widths[0] = widget.width;
        break;
      case 'F':
        values[1] = true;
        break;
      case 'f':
        widths[1] = widget.width;
        break;
      case 'L':
        values[2] = true;
        break;
      case 'l':
        widths[2] = widget.width;
        break;
      case 'S':
        values[3] = true;
        break;
      case 's':
        widths[3] = widget.width;
        break;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
    });
    print(values);
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
