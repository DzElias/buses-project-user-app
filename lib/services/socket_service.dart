// ignore_for_file: constant_identifier_names, library_prefixes

import 'package:flutter/foundation.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;

  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    _socket = IO.io('https://pruebas-socket.herokuapp.com/', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    _socket.on('connect', (_) {
      if (kDebugMode) {
        print('cliente conectado');
      }
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }
}
