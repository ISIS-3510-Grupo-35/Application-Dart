import 'package:application_dart/view_models/localization.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapComponent extends StatefulWidget {
  const MapComponent({Key? key}) : super(key: key);

  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  GoogleMapController? _mapController;
  final LatLng _defaultLocation = const LatLng(4.7110, -74.0721);

  @override
  void initState() {
    super.initState();
    // Fetch parking lots when the component initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);
      parkingLotVM.fetchParkingLots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ParkingLotViewModel>(
        builder: (context, parkingLotVM, child) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _defaultLocation,
                  zoom: 11.0,
                ),
                markers: parkingLotVM.markers, // Use markers from the view model
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              if (parkingLotVM.fetchingData) // Show loading indicator if data is being fetched
                Center(child: CircularProgressIndicator()),
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
