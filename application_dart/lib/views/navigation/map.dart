import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:application_dart/view_models/localization.dart';

class MapComponent extends StatefulWidget {
  const MapComponent({Key? key}) : super(key: key);

  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  GoogleMapController? _mapController;
  final LatLng _defaultLocation = const LatLng(4.7110, -74.0721);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LocationViewModel>(
        builder: (context, locationVM, child) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: locationVM.currentPosition != null
                      ? LatLng(locationVM.currentPosition!.latitude, locationVM.currentPosition!.longitude)
                      : _defaultLocation,
                  zoom: 11.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: _centerOnUserLocation,
                  child: const Icon(Icons.my_location),
                  mini: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _centerOnUserLocation() {
    final locationVM = Provider.of<LocationViewModel>(context, listen: false);
    if (locationVM.currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locationVM.currentPosition!.latitude, locationVM.currentPosition!.longitude),
        ),
      );
    }
  }
}