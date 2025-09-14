import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/pin_provider.dart';
import '../../providers/auth_provider_simple.dart' as auth;
import '../../models/pin_model.dart';

class CreatePinScreenSimple extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  
  const CreatePinScreenSimple({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<CreatePinScreenSimple> createState() => _CreatePinScreenSimpleState();
}

class _CreatePinScreenSimpleState extends State<CreatePinScreenSimple> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  
  String _selectedCategory = 'Landmark';
  bool _isSponsored = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Landmark',
    'Restaurant', 
    'Nature',
    'Adventure',
    'Shopping',
    'Entertainment',
    'Education',
    'Healthcare',
  ];

  @override
  void initState() {
    super.initState();
    _setDefaultLocation();
  }

  void _setDefaultLocation() {
    // Use provided coordinates or default to NYC
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _latController.text = widget.initialLatitude!.toStringAsFixed(6);
      _lngController.text = widget.initialLongitude!.toStringAsFixed(6);
    } else {
      _latController.text = '40.7589';
      _lngController.text = '-73.9851';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Pin'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPin,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildOptionsSection(),
            const SizedBox(height: 32),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Pin Title *',
                hintText: 'Enter a descriptive title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe this location',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use Current'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final lat = double.tryParse(value);
                      if (lat == null || lat < -90 || lat > 90) {
                        return 'Invalid latitude';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final lng = double.tryParse(value);
                      if (lng == null || lng < -180 || lng > 180) {
                        return 'Invalid longitude';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: You can tap on the map to get coordinates',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Category',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category)),
                      const SizedBox(width: 12),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sponsored Pin'),
              subtitle: const Text('Mark this as a sponsored location'),
              value: _isSponsored,
              onChanged: (value) {
                setState(() {
                  _isSponsored = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _createPin,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_location),
        label: Text(_isLoading ? 'Creating...' : 'Create Pin'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
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
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'education':
        return Icons.school;
      case 'healthcare':
        return Icons.local_hospital;
      default:
        return Icons.place;
    }
  }

  void _getCurrentLocation() async {
    final pinProvider = context.read<PinProvider>();
    if (pinProvider.currentLocation != null) {
      setState(() {
        _latController.text = pinProvider.currentLocation!.latitude!.toStringAsFixed(6);
        _lngController.text = pinProvider.currentLocation!.longitude!.toStringAsFixed(6);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available')),
      );
    }
  }

  Future<void> _createPin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<auth.AuthProvider>();
      final pinProvider = context.read<PinProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('User not logged in');
      }

      final pin = PinModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
        category: _selectedCategory,
        createdBy: authProvider.currentUser!.id,
        createdAt: DateTime.now(),
        imageUrls: const [], // No images for web demo
        tags: [_selectedCategory.toLowerCase()],
        isSponsored: _isSponsored,
        checkInCount: 0,
        rating: 0.0,
      );

      await pinProvider.createPin(pin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pin "${pin.title}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        _setDefaultLocation();
        setState(() {
          _selectedCategory = 'Landmark';
          _isSponsored = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create pin: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
