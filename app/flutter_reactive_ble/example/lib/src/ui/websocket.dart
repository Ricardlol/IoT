// stateful widget that connects to websocket and listens for messages
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/models/user.dart';

class WebSocket extends StatefulWidget {
  const WebSocket({Key? key,  required this.userId}) : super(key: key);

  final String userId;

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
  void initState() {
    super.initState();
    print ('initState of web socket');
    _messages = [];
    _controller = TextEditingController();
    _scrollController = ScrollController();

    _channel = IOWebSocketChannel.connect('wss://b04d-79-157-130-10.eu.ngrok.io/ws/${widget.userId}');

    broadcastStream = _channel.stream.asBroadcastStream();

    broadcastStream.listen((dynamic message) {
      setState(() {
        _messages.add(message as String);
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
          Form(
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Send a message'),
            ),
          ),
          StreamBuilder<dynamic>(
            stream: broadcastStream,
            builder: (context, snapshot) => Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (BuildContext context, int index) => Text(_messages[index]),
                ),
              ),
          ),
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

