import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pin_provider.dart';
import '../../models/pin_model.dart';

class MapScreenSimple extends StatefulWidget {
  const MapScreenSimple({super.key});

  @override
  State<MapScreenSimple> createState() => _MapScreenSimpleState();
}

class _MapScreenSimpleState extends State<MapScreenSimple> {
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
        title: const Text('Map'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMapContent(),
    );
  }

  Widget _buildMapContent() {
    return Consumer<PinProvider>(
      builder: (context, pinProvider, child) {
        final pins = _selectedCategory == 'All'
            ? pinProvider.filteredPins
            : pinProvider.getPinsByCategory(_selectedCategory);

        return Column(
          children: [
            // Mock map container
            Container(
              height: 400,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 64,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Interactive Map View',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Google Maps integration will work on mobile devices',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            // Pins list
            Expanded(
              child: pins.isEmpty
                  ? const Center(
                      child: Text(
                        'No pins found in this category',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pins.length,
                      itemBuilder: (context, index) {
                        final pin = pins[index];
                        return _buildPinCard(pin);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPinCard(PinModel pin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: pin.isSponsored 
              ? Colors.orange 
              : Theme.of(context).colorScheme.primary,
          child: Icon(
            _getCategoryIcon(pin.category),
            color: Colors.white,
          ),
        ),
        title: Text(
          pin.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pin.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Lat: ${pin.latitude.toStringAsFixed(4)}, '
                  'Lng: ${pin.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: pin.isSponsored
            ? const Icon(Icons.star, color: Colors.orange)
            : null,
        onTap: () {
          // Navigate to pin details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${pin.title}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
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
}
