// ignore_for_file: avoid_print

import 'dart:async';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';

enum SocketConnectionState {
  connecting,
  connected,
  disconnected,
  error
}

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final _storage = const FlutterSecureStorage();
  
  // Stream controllers
  final _connectionStateController = StreamController<SocketConnectionState>.broadcast();
  final _auctionUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _bidUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Stream getters
  Stream<SocketConnectionState> get connectionState => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get auctionUpdates => _auctionUpdateController.stream;
  Stream<Map<String, dynamic>> get bidUpdates => _bidUpdateController.stream;
  Stream<String> get errors => _errorController.stream;

  Future<void> connect() async {
    if (_socket != null) {
      print('Socket already connected');
      return;
    }

    try {
      final accessToken = await _storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Convert HTTP/HTTPS to WS/WSS
      final socketUrl = ApiEndpoints.baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
      
      _connectionStateController.add(SocketConnectionState.connecting);

      _socket = IO.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'extraHeaders': {'Authorization': 'Bearer $accessToken'},
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'reconnectionAttempts': 5,
        'path': '/socket.io', // Add this if your NestJS uses a custom path
      });

      _setupSocketListeners();
      _socket!.connect();

    } catch (e) {
      print('Socket connection error: $e');
      _errorController.add('Failed to connect: $e');
      _connectionStateController.add(SocketConnectionState.error);
    }
  }

  void _setupSocketListeners() {
    _socket!
      ..on('connect', (_) {
        print('Socket connected');
        _connectionStateController.add(SocketConnectionState.connected);
      })
      ..on('disconnect', (_) {
        print('Socket disconnected');
        _connectionStateController.add(SocketConnectionState.disconnected);
      })
      ..on('error', (error) {
        print('Socket error: $error');
        _errorController.add(error.toString());
        _connectionStateController.add(SocketConnectionState.error);
      })
      ..on('connect_error', (error) {
        print('Socket connection error: $error');
        _errorController.add('Connection error: $error');
        _connectionStateController.add(SocketConnectionState.error);
      })
      // Auction-specific events
      ..on('auctionUpdate', (data) {
        print('Received auction update: $data');
        _auctionUpdateController.add(Map<String, dynamic>.from(data));
      })
      ..on('bidUpdate', (data) {
        print('Received bid update: $data');
        _bidUpdateController.add(Map<String, dynamic>.from(data));
      })
      ..on('newAuction', (data) {
        print('Received new auction: $data');
        _auctionUpdateController.add({
          'type': 'new_auction',
          'data': data,
        });
      })
      ..on('auctionEnded', (data) {
        print('Auction ended: $data');
        _auctionUpdateController.add({
          'type': 'auction_ended',
          'data': data,
        });
      });
  }

  // Join auction room to receive specific auction updates
  void joinAuctionRoom(String auctionId) {
    // print('Joining auction room: $auctionId');
    _socket?.emit('joinAuction', {'auctionId': auctionId});
  }

  // Leave auction room
  void leaveAuctionRoom(String auctionId) {
    print('Leaving auction room: $auctionId');
    _socket?.emit('leaveAuction', {'auctionId': auctionId});
  }

  // Place a bid
  Future<bool> placeBid(String auctionId, double amount) async {
    final completer = Completer<bool>();
    
    _socket?.emitWithAck('placeBid', {
      'auctionId': auctionId,
      'amount': amount
    }, ack: (data) {
      if (data['success'] == true) {
        completer.complete(true);
      } else {
        _errorController.add(data['message'] ?? 'Bid failed');
        completer.complete(false);
      }
    });

    return completer.future;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
    _auctionUpdateController.close();
    _bidUpdateController.close();
    _errorController.close();
  }
}
