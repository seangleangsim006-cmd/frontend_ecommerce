import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/screens/customer/map/get_current_location.dart';

class ProLocationPicker extends StatefulWidget {
  const ProLocationPicker({super.key});

  @override
  State<ProLocationPicker> createState() => _ProLocationPickerState();
}

class _ProLocationPickerState extends State<ProLocationPicker> {
  GoogleMapController? mapController;
  LatLng selectedLatLng = const LatLng(11.5564, 104.9282);
  String addressName = 'Getting location...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      isLoading = true;
      addressName = 'Getting location...';
    });

    final position = await getCurrentLocation();
    if (position == null) {
      setState(() {
        addressName = 'Location permission denied.';
        isLoading = false;
      });
      return;
    }

    selectedLatLng = LatLng(position.latitude, position.longitude);
    await _moveCamera(selectedLatLng);
    await _getAddressFromLatLng(selectedLatLng);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      final place = placemarks.first;

      final street = [
        place.street,
        place.subLocality,
      ].where((value) => value != null && value.isNotEmpty).join(', ');
      final city = [
        place.locality,
        place.administrativeArea,
      ].where((value) => value != null && value.isNotEmpty).join(', ');
      final country = place.country ?? '';

      setState(() {
        addressName = [
          street,
          city,
          country,
        ].where((value) => value.isNotEmpty).join(', ');
      });
    } catch (_) {
      setState(() {
        addressName = 'Unable to resolve address';
      });
    }
  }

  Future<void> _moveCamera(LatLng latLng) async {
    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: selectedLatLng,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;
            },
            onCameraMove: (position) {
              selectedLatLng = position.target;
            },
            onCameraIdle: () {
              _getAddressFromLatLng(selectedLatLng);
            },
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: LinearProgressIndicator(),
                    ),
                  Text(addressName, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _initLocation,
                          icon: const Icon(Icons.my_location,color: AppColors.primary,),
                          label: const Text('Current',style: TextStyle(color:  AppColors.primary),),
                          
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'lat': selectedLatLng.latitude,
                              'lng': selectedLatLng.longitude,
                              'address': addressName,
                            });
                          },
                          child: const Text('Confirm',style: TextStyle(color: AppColors.primary),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
