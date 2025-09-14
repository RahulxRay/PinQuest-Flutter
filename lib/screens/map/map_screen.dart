import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import '../../providers/pin_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/pin_model.dart';
import '../../core/config/app_config.dart';
import '../pins/pin_detail_screen.dart';
import '../../widgets/pin_cluster_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  LocationData? _currentLocation;
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await context.read<PinProvider>().loadPins();
      await _getCurrentLocation();
      _updateMarkers();
    } catch (e) {
      debugPrint('Map initialization error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final pinProvider = context.read<PinProvider>();
      _currentLocation = pinProvider.currentLocation;
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _updateMarkers() {
    final pinProvider = context.read<PinProvider>();
    final pins = _selectedCategory == 'All'
        ? pinProvider.filteredPins
        : pinProvider.getPinsByCategory(_selectedCategory);

    _markers = pins.map((pin) => _createMarker(pin)).toSet();
    
    // Add current location marker if available
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }
    
    setState(() {});
  }

  Marker _createMarker(PinModel pin) {
    return Marker(
      markerId: MarkerId(pin.id),
      position: LatLng(pin.latitude, pin.longitude),
      icon: pin.isSponsored
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: pin.title,
        snippet: pin.description.length > 50
            ? '${pin.description.substring(0, 50)}...'
            : pin.description,
        onTap: () => _showPinDetails(pin),
      ),
      onTap: () => _showPinBottomSheet(pin),
    );
  }

  void _showPinDetails(PinModel pin) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinDetailScreen(pin: pin),
      ),
    );
  }

  void _showPinBottomSheet(PinModel pin) {
    final pinProvider = context.read<PinProvider>();
    final userProvider = context.read<UserProvider>();
    final distance = pinProvider.getFormattedDistanceToPin(pin);
    final canCheckIn = pinProvider.isUserNearPin(pin);
    final hasCheckedIn = userProvider.hasCompletedPin(pin.id);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pin.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (pin.isSponsored)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'SPONSORED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              pin.category,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              pin.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                if (hasCheckedIn)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showPinDetails(pin);
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canCheckIn && !hasCheckedIn
                        ? () => _checkInAtPin(pin)
                        : null,
                    child: Text(
                      hasCheckedIn
                          ? 'Checked In'
                          : canCheckIn
                              ? 'Check In'
                              : 'Too Far',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkInAtPin(PinModel pin) async {
    final userProvider = context.read<UserProvider>();
    await userProvider.checkInAtPin(pin.id);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked in at ${pin.title}! +${AppConfig.pointsPerCheckIn} points'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (category) {
              setState(() {
                _selectedCategory = category;
                _updateMarkers();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Categories')),
              ...AppConfig.pinCategories.map(
                (category) => PopupMenuItem(
                  value: category,
                  child: Text(category),
                ),
              ),
            ],
            child: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _moveToCurrentLocation,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLocation != null
                  ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                  : const LatLng(37.7749, -122.4194), // Default to San Francisco
              zoom: AppConfig.defaultZoom,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            minMaxZoomPreference: const MinMaxZoomPreference(
              AppConfig.minZoom,
              AppConfig.maxZoom,
            ),
          ),
          
          // Category Filter Chip
          if (_selectedCategory != 'All')
            Positioned(
              top: 16,
              left: 16,
              child: Chip(
                label: Text(_selectedCategory),
                onDeleted: () {
                  setState(() {
                    _selectedCategory = 'All';
                    _updateMarkers();
                  });
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
