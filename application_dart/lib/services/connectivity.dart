import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();
  Stream<bool> get statusStream => _statusController.stream;
  bool get isConnected => _isConnected;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityService() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _isConnected = _mapConnectivityResultToBool(result);
      _statusController.add(_isConnected);
    });
  }

  bool _mapConnectivityResultToBool(List<ConnectivityResult> results) {
    return results.any((result) => 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.mobile);
  }

  void dispose() {
    _subscription.cancel();
    _statusController.close();
  }
}