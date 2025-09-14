import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/pin_provider.dart';
import '../../models/pin_model.dart';
import '../../core/theme/app_theme.dart';
import '../pins/create_pin_screen_simple.dart';

class MapScreenWeb extends StatefulWidget {
  const MapScreenWeb({super.key});

  @override
  State<MapScreenWeb> createState() => _MapScreenWebState();
}

class _MapScreenWebState extends State<MapScreenWeb> {
  final MapController _mapController = MapController();
  bool _isLoading = true;
  String _selectedCategory = 'All';
  LatLng _center = const LatLng(40.7589, -73.9851); // New York City default

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await context.read<PinProvider>().loadPins();
      // Try to get user's location, fallback to NYC if not available
      final pinProvider = context.read<PinProvider>();
      if (pinProvider.currentLocation != null) {
        _center = LatLng(
          pinProvider.currentLocation!.latitude!,
          pinProvider.currentLocation!.longitude!,
        );
      }
    } catch (e) {
      debugPrint('Map initialization error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Map'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onSelected: (category) {
                setState(() => _selectedCategory = category);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'All', child: Text('All Categories')),
                const PopupMenuItem(value: 'Landmark', child: Text('Landmarks')),
                const PopupMenuItem(value: 'Restaurant', child: Text('Restaurants')),
                const PopupMenuItem(value: 'Nature', child: Text('Nature')),
                const PopupMenuItem(value: 'Adventure', child: Text('Adventure')),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.my_location, color: Colors.white),
              onPressed: _centerOnUserLocation,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMap(),
          // Hint banner
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667EEA).withOpacity(0.9),
                    const Color(0xFF764BA2).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Long press anywhere to create a pin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to create pin screen
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const CreatePinScreenSimple(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add_location,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Consumer<PinProvider>(
      builder: (context, pinProvider, child) {
        final pins = _selectedCategory == 'All'
            ? pinProvider.filteredPins
            : pinProvider.getPinsByCategory(_selectedCategory);

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 13.0,
            minZoom: 5.0,
            maxZoom: 18.0,
            onTap: (tapPosition, point) => _onMapTap(point),
            onLongPress: (tapPosition, point) => _onMapLongPress(point),
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.pinquest',
              maxZoom: 18,
            ),
            // Pin markers
            MarkerLayer(
              markers: _buildMarkers(pins, pinProvider),
            ),
            // Attribution
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Marker> _buildMarkers(List<PinModel> pins, PinProvider pinProvider) {
    List<Marker> markers = [];

    // Add pin markers
    for (final pin in pins) {
      markers.add(
        Marker(
          point: LatLng(pin.latitude, pin.longitude),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => _showPinDetails(pin),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getPinGradientColors(pin),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getCategoryIcon(pin.category),
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      );
    }

    // Add user location marker if available
    if (pinProvider.currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            pinProvider.currentLocation!.latitude!,
            pinProvider.currentLocation!.longitude!,
          ),
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26C6DA), Color(0xFF00ACC1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<Color> _getPinGradientColors(PinModel pin) {
    if (pin.isSponsored) {
      return [const Color(0xFFFF8A65), const Color(0xFFFF5722)];
    }
    
    switch (pin.category.toLowerCase()) {
      case 'nature':
        return [const Color(0xFF66BB6A), const Color(0xFF4CAF50)];
      case 'restaurant':
        return [const Color(0xFFFF7043), const Color(0xFFFF5722)];
      case 'landmark':
        return [const Color(0xFF42A5F5), const Color(0xFF2196F3)];
      case 'adventure':
        return [const Color(0xFFAB47BC), const Color(0xFF9C27B0)];
      case 'shopping':
        return [const Color(0xFFEF5350), const Color(0xFFF44336)];
      case 'entertainment':
        return [const Color(0xFF5C6BC0), const Color(0xFF3F51B5)];
      case 'education':
        return [const Color(0xFF26A69A), const Color(0xFF009688)];
      case 'healthcare':
        return [const Color(0xFF78909C), const Color(0xFF607D8B)];
      default:
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'landmark':
        return Icons.location_city;
      case 'restaurant':
        return Icons.restaurant;
      case 'nature':
        return Icons.nature;
      case 'adventure':
        return Icons.hiking;
      default:
        return Icons.place;
    }
  }

  void _showPinDetails(PinModel pin) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header with gradient background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getPinGradientColors(pin),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(pin.category),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pin.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          pin.category,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (pin.isSponsored)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Sponsored',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              pin.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              children: [
                _buildStatChip(Icons.star, '${pin.rating.toStringAsFixed(1)}', Colors.amber),
                const SizedBox(width: 12),
                _buildStatChip(Icons.how_to_reg, '${pin.checkInCount}', Colors.green),
                const SizedBox(width: 12),
                _buildStatChip(Icons.location_on, 
                    '${pin.latitude.toStringAsFixed(2)}, ${pin.longitude.toStringAsFixed(2)}', 
                    Colors.blue),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getPinGradientColors(pin),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _checkInToPin(pin),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Check In', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    label: Text('Close', style: TextStyle(color: Colors.grey[600])),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _checkInToPin(PinModel pin) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked in to ${pin.title}!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      ),
    );
  }

  void _centerOnUserLocation() {
    final pinProvider = context.read<PinProvider>();
    if (pinProvider.currentLocation != null) {
      _mapController.move(
        LatLng(
          pinProvider.currentLocation!.latitude!,
          pinProvider.currentLocation!.longitude!,
        ),
        15.0,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available'),
        ),
      );
    }
  }

  void _onMapTap(LatLng point) {
    // Show coordinates on tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tapped: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blueGrey[800],
      ),
    );
  }

  void _onMapLongPress(LatLng point) {
    // Show dialog to create pin at this location
    _showCreatePinDialog(point);
  }

  void _showCreatePinDialog(LatLng point) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_location,
                  color: Colors.deepPurple[700],
                ),
              ),
              const SizedBox(width: 12),
              const Text('Create Pin Here'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a new pin at this location?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, 
                         size: 16, 
                         color: Colors.deepPurple[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToCreatePin(point);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Pin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCreatePin(LatLng point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CreatePinScreenSimple(
          initialLatitude: point.latitude,
          initialLongitude: point.longitude,
        ),
      ),
    );
  }
}
