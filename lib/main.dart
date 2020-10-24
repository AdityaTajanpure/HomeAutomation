import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'core/viewmodels/home_model.dart';
import 'ui/views/home_view.dart';
import 'package:home_automation/ui/shared/globals.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TouchID(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}

class TouchID extends StatefulWidget {
  @override
  _TouchIDState createState() => _TouchIDState();
}

class _TouchIDState extends State<TouchID> {
  final LocalAuthentication localAuth = LocalAuthentication();
  String _authorizeText = 'Not Authorized!';

  List<BiometricType> availableBiometrics = List<BiometricType>();
  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {});
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await FlutterBluetoothSerial.instance.requestEnable();
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          print(address);
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        print(name);
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        print(state.stringValue);
      });
    });
  }

  Future<void> _authorize() async {
    bool _isAuthorized = false;
    try {
      _isAuthorized = await localAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to Complete this process',
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      if (_isAuthorized) {
        _authorizeText = "Authorized Successfully!";
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeView()));
      } else {
        _authorizeText = "You're Not Authorized To Use This Home Appliances!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Automation')),
      backgroundColor: Global.darkBlue,
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _authorizeText,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          RaisedButton(
            child: Text(
              'Authorize',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            color: Colors.pink,
            onPressed: _authorize,
          )
        ],
      )),
    );
  }
}
