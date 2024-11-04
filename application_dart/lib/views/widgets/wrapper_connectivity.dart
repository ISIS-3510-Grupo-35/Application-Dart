import 'package:application_dart/services/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final bool blockInteraction;

  const ConnectivityWrapper({
    Key? key,
    required this.child,
    this.blockInteraction = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, _) {
        return StreamBuilder<bool>(
          stream: connectivityService.statusStream,
          builder: (context, snapshot) {
            final isConnected = snapshot.data ?? true;

            return Stack(
              children: [
                // Main content
                AbsorbPointer(
                  absorbing: !isConnected && blockInteraction,
                  child: child,
                ),
                if (!isConnected)
                  Container(
                    color: Colors.black.withOpacity(0.5), // Semi-transparent black background
                  ),
                if (!isConnected)
                  Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                          ),
                        ],
                        ),
                        child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.red,
                            size: 48.0,
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'No Internet Connection',
                            style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Please try again when there is connection.',
                            textAlign: TextAlign.center,
                          ),
                          ],
                        ),
                        ),
                      ),
                      ),
                    ),
                    ),
                  ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
