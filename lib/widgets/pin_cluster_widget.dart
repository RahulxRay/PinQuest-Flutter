import 'package:flutter/material.dart';
import '../models/pin_model.dart';

class PinClusterWidget extends StatelessWidget {
  final List<PinModel> pins;
  final VoidCallback? onTap;

  const PinClusterWidget({
    super.key,
    required this.pins,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pins.length == 1) {
      return _buildSinglePin(context, pins.first);
    }
    
    return _buildCluster(context);
  }

  Widget _buildSinglePin(BuildContext context, PinModel pin) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: pin.isSponsored ? Colors.orange : Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          pin.isSponsored ? Icons.star : Icons.location_on,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCluster(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
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
        child: Center(
          child: Text(
            pins.length.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
