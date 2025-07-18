import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ihealth_naija_test_version/models/clinic.dart';
import 'package:ihealth_naija_test_version/screens/builders/clinic_card.dart';
import 'package:ihealth_naija_test_version/screens/builders/clinic_card_skeleton.dart';
import 'package:ihealth_naija_test_version/providers/clinic_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';

class HealthMapScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const HealthMapScreen({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  ConsumerState<HealthMapScreen> createState() => _HealthMapScreenState();
}

class _HealthMapScreenState extends ConsumerState<HealthMapScreen> {
  Clinic? _selectedClinic;
  MapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  
  // Default location (Nigeria center)
  final LatLng _defaultCenter = const LatLng(9.0820, 8.6753);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Use default location if permission denied
          _searchClinicsAtLocation(_defaultCenter.latitude, _defaultCenter.longitude);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Use default location if permission permanently denied
        _searchClinicsAtLocation(_defaultCenter.latitude, _defaultCenter.longitude);
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Search for clinics near current location
      _searchClinicsAtLocation(position.latitude, position.longitude);
      
    } catch (e) {
      // Fallback to default location
      setState(() {
        _isLoadingLocation = false;
      });
      _searchClinicsAtLocation(_defaultCenter.latitude, _defaultCenter.longitude);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location. Using default location.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _searchClinicsAtLocation(double latitude, double longitude) {
    ref.read(clinicProvider.notifier).searchClinics(
      latitude: latitude,
      longitude: longitude,
    );
  }

  void _getDirections(Clinic clinic) async {
    final url = 'https://www.openstreetmap.org/directions?from=${_currentPosition?.latitude ?? _defaultCenter.latitude},${_currentPosition?.longitude ?? _defaultCenter.longitude}&to=${clinic.latitude},${clinic.longitude}';
    
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open directions to ${clinic.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error launching navigation'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  List<Marker> _buildMarkers(List<Clinic> clinics) {
    return clinics.map((clinic) {
      // Convert latitude and longitude to double
      double lat = double.tryParse(clinic.latitude.toString()) ?? 0.0;
      double lng = double.tryParse(clinic.longitude.toString()) ?? 0.0;
      
      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(lat, lng),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedClinic = clinic;
            });
            
            // Center map on selected clinic
            _mapController?.move(LatLng(lat, lng), 15);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.local_hospital,
              color: _selectedClinic?.id == clinic.id 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.red,
              size: _selectedClinic?.id == clinic.id ? 40 : 30,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMap(ClinicState state) {
    // Get current position or default
    final currentLat = _currentPosition?.latitude ?? _defaultCenter.latitude;
    final currentLng = _currentPosition?.longitude ?? _defaultCenter.longitude;
    
    return FlutterMap(
      mapController: _mapController = MapController(),
      options: MapOptions(
        initialCenter: LatLng(currentLat, currentLng),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            // Current location marker
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(currentLat, currentLng),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            // Clinic markers
            ..._buildMarkers(state.clinics),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicState = ref.watch(clinicProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Healthcare'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Map section
          SizedBox(
            height: 250, // Slightly bigger map
            child: _isLoadingLocation || clinicState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildMap(clinicState),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nearby Healthcare Facilities',
                        style: AppTheme.headingSmall,
                      ),
                      if (clinicState.clinics.isNotEmpty)
                        Text(
                          '${clinicState.clinics.length} results ✔️ ',
                          style: TextStyle(
                            color: AppTheme.primaryColor
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (clinicState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          clinicState.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  
                  Expanded(
                    child: clinicState.isLoading
                        ? ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return const ClinicCardSkeleton();
                            },
                          )
                        : clinicState.clinics.isEmpty && !clinicState.isLoading
                            ? const Center(
                                child: Text(
                                  'No healthcare facilities found nearby',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: clinicState.clinics.length,
                                itemBuilder: (context, index) {
                                  final clinic = clinicState.clinics[index];
                                  return ClinicCard(
                                    clinic: clinic,
                                    isSelected: _selectedClinic?.id == clinic.id,
                                    onTap: () {
                                      setState(() {
                                        _selectedClinic = clinic;
                                      });
                                      
                                      // Center map on selected clinic
                                      double lat = double.tryParse(clinic.latitude.toString()) ?? 0.0;
                                      double lng = double.tryParse(clinic.longitude.toString()) ?? 0.0;
                                      _mapController?.move(LatLng(lat, lng), 15);
                                    },
                                    onGetDirections: () => _getDirections(clinic),
                                  );
                                },
                              ),
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