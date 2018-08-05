import 'package:flutter/material.dart';
import 'package:pusher_flutter/pusher_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map _latestMessage;
  PusherError _lastError;
  PusherConnectionState _connectionState;
  PusherFlutter pusher = PusherFlutter("<your_key>");

  @override
  initState() {
    super.initState();
    pusher.onConnectivityChanged.listen((state) {
      setState(() {
        _connectionState = state;
        if (state == PusherConnectionState.connected) {
          _lastError = null;
        }
      });
    });
    pusher.onError.listen((err) => _lastError = err);
    _connectionState = PusherConnectionState.disconnected;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Pusher example app.'),
          ),
          body: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Latest message ${_latestMessage.toString()}')
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              buildConnectRow(context),
              buildErrorRow(context),
            ],
          )),
    );
  }

  Widget buildErrorRow(BuildContext context) {
    if (_lastError != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text("Error: ${_lastError.message}")],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text("No Errors")],
      );
    }
  }

  Widget buildConnectRow(BuildContext context) {
    switch (_connectionState) {
      case PusherConnectionState.connected:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(onPressed: disconnect, child: Text("Disconnect"))
          ],
        );
      case PusherConnectionState.disconnected:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(onPressed: connect, child: Text("Connect"))
          ],
        );
      case PusherConnectionState.disconnecting:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text("Disconnecting...")],
        );
      case PusherConnectionState.connecting:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text("Connecting...")],
        );
      case PusherConnectionState.reconnectingWhenNetworkBecomesReachable:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Will reconnect when network becomes available")
          ],
        );
      case PusherConnectionState.reconnecting:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text("Reconnecting...")],
        );
    }
    return Text("Invalid state");
  }

  void connect() {
    pusher.connect();

    pusher.subscribe("test_channel", "test_event");
    pusher.subscribe("test_channel", "test_event2");

    pusher.subscribeAll("test_channel", ["test_event3", "test_event4"]);

    pusher.onMessage.listen((pusher) {
      setState(() => _latestMessage = pusher.body);
    });
  }

  void disconnect() {
    pusher.unsubscribe("test_channel");
    pusher.unsubscribe("test_channel2");
    pusher.disconnect();
  }
}
