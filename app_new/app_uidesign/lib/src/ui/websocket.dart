// stateful widget that connects to websocket and listens for messages
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/models/user.dart';
import '../api/shared_preferences.dart';
import '../resources/strings.dart';

class WebSocket extends StatefulWidget {
  const WebSocket({Key? key,  required this.user}) : super(key: key);

  final User user;

  @override
  _WebSocketState createState() => _WebSocketState();
}

class  _WebSocketState  extends State<WebSocket> {
  late WebSocketChannel _channel;
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late List<String> _messages;

  late Stream broadcastStream;

  @override
  void initState()  {
    super.initState();
    print ('initState of web socket');
    _messages = [];
    _controller = TextEditingController();
    _scrollController = ScrollController();

    // remove the https:// from the value of the BASE_URL
    var url = Strings.BASE_URL.replaceAll('https://', '');

    print('url: $url');
    _channel = IOWebSocketChannel.connect('wss://${url}ws/${widget.user.id}');

    broadcastStream = _channel.stream.asBroadcastStream();

    broadcastStream.listen((dynamic message) {
      setState(() {
        _messages.add(message as String);
        // if message contains 'Welcome' we show a nicer alert.
        if (message.contains('Welcome')){
          // Alert(
          //   context: context,
          //   //type: AlertType.info,
          //   title: "Hello ${widget.user.full_name}!",
          //   desc: message as String,
          //   image: Image.network(widget.user.avatar_url),
          //   buttons: [
          //     DialogButton(
          //       child: const Text(
          //         "OK",
          //         style: TextStyle(color: Colors.white, fontSize: 20),
          //       ),
          //       onPressed: () => Navigator.pop(context),
          //       width: 120,
          //     )
          //   ],
          // ).show();
        }
        else {
          Alert(
            context: context,
            //type: AlertType.warning,
            image: Image.network('https://cdn-icons-png.flaticon.com/512/6192/6192146.png'),
            title: "Caution!",
            desc: message as String,
            buttons: [
              DialogButton(
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show();
        }
      });
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: const Duration(milliseconds: 300),
      //   curve: Curves.easeOut,
      // );
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Demo'),
      ),
      body: Column(
        children: <Widget>[
          Text("Websocket realtime")
          // Form(
          //   child: TextFormField(
          //     controller: _controller,
          //     decoration: const InputDecoration(labelText: 'Send a message'),
          //   ),
          // ),
          // StreamBuilder<dynamic>(
          //   stream: broadcastStream,
          //   builder: (context, snapshot) => Expanded(
          //       child: ListView.builder(
          //         controller: _scrollController,
          //         itemCount: _messages.length,
          //         itemBuilder: (BuildContext context, int index) => Text(_messages[index]),
          //       ),
          //     ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ),
    );

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
    }
  }
}

