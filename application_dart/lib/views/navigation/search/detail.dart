import 'dart:typed_data';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/reservation.dart';
import 'package:application_dart/services/connectivity.dart';
import 'package:application_dart/services/image_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParkingLotDetailScreen extends StatefulWidget {
  final String parkingLotId;

  const ParkingLotDetailScreen({Key? key, required this.parkingLotId}) : super(key: key);

  @override
  _ParkingLotDetailScreenState createState() => _ParkingLotDetailScreenState();
}

class _ParkingLotDetailScreenState extends State<ParkingLotDetailScreen> {
  bool isReserved = false;
  bool showReviewCard = false;
  bool _isConnected = true;
  int selectedRating = 0;
  Uint8List? _noInternetImage;
  
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  final ImageCacheService _imageCacheService = ImageCacheService();

  @override
  void initState() {
    super.initState();
    _checkActiveReservation();
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    _connectivityService.statusStream.listen((status) {
      setState(() {
        _isConnected = status;
      });
    });

    await _imageCacheService.downloadAndCacheImage();
    _noInternetImage = await _imageCacheService.getCachedImage();
  }

  void _checkActiveReservation() {
    final reservationVM = Provider.of<ReservationViewModel>(context, listen: false);
    setState(() {
      isReserved = reservationVM.isReserved();
    });
  }

  Future<void> _handleReservation(ReservationViewModel reservationVM) async {
    try {
      if (!isReserved) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Enter License Plate'),
              content: TextField(
                controller: _licensePlateController,
                decoration: const InputDecoration(labelText: 'License Plate'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await reservationVM.addReservation(
                      widget.parkingLotId,
                      DateTime.now(),
                      _licensePlateController.text,
                    );
                    setState(() {
                      isReserved = true;
                    });
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      } else {
        await reservationVM.cancelReservation();
        setState(() {
          isReserved = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reservation: $e')),
      );
    }
  }

  void _toggleReviewCard() {
    setState(() {
      showReviewCard = !showReviewCard;
    });
  }

  Future<void> _submitReview() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String parkingRef = '/Parking lots/${widget.parkingLotId}';
    String userRef = '/Users/$userId';

    try {
      await _firestore.collection('reviews').add({
        'parkingID': _firestore.doc(parkingRef),
        'userID': _firestore.doc(userRef),
        'rate': selectedRating.toString(),
        'review': _reviewController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully!')),
      );

      _reviewController.clear();
      setState(() {
        selectedRating = 0;
        showReviewCard = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotVM = Provider.of<ParkingLotViewModel>(context);
    final reservationVM = Provider.of<ReservationViewModel>(context);
    final parkingLot = parkingLotVM.getParkingLotById(widget.parkingLotId);

    if (parkingLot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Parking Lot Details")),
        body: const Center(child: Text("Parking lot not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(parkingLot.name),
        backgroundColor: const Color(0xFFF4B324),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: parkingLot.image ?? '',
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          parkingLot.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parkingLot.address ?? 'No Address Provided',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16.0),
                      // Only show reservation and review buttons, and capacity info if connected
                      if (_isConnected) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(
                                parkingLot.capacity != null
                                    ? 'Capacity: ${parkingLot.capacity!.toInt()}'
                                    : 'Capacity: N/A',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: parkingLot.capacity != null && parkingLot.capacity! > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _handleReservation(reservationVM),
                            child: Text(isReserved ? 'Cancel Reservation' : 'Reserve'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: isReserved ? Colors.red : Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _toggleReviewCard,
                            icon: const Icon(Icons.rate_review),
                            label: const Text('Calificar'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showReviewCard)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleReviewCard,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _toggleReviewCard,
                              ),
                            ),
                            const Text(
                              'Review This Parking Lot',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    Icons.star,
                                    color: index < selectedRating ? Colors.yellow : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedRating = index + 1;
                                    });
                                  },
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _reviewController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Leave a comment',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _submitReview,
                                child: const Text('Publicar reseña'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
