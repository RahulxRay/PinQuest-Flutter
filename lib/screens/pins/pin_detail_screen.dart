import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../models/pin_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/pin_provider.dart';
import '../../core/config/app_config.dart';

class PinDetailScreen extends StatelessWidget {
  final PinModel pin;

  const PinDetailScreen({
    super.key,
    required this.pin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageCarousel(context),
      ),
      actions: [
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final hasCheckedIn = userProvider.hasCompletedPin(pin.id);
            return hasCheckedIn
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    if (pin.imageUrls.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }

    return PageView.builder(
      itemCount: pin.imageUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = pin.imageUrls[index];
        
        // Handle local file paths vs network URLs
        if (imageUrl.startsWith('http')) {
          return CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error, size: 64),
            ),
          );
        } else {
          return Image.file(
            File(imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.error, size: 64),
            ),
          );
        }
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildDescription(context),
          const SizedBox(height: 16),
          _buildDetails(context),
          const SizedBox(height: 16),
          if (pin.isSponsored && pin.sponsorInfo != null)
            _buildSponsorSection(context),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                pin.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (pin.isSponsored)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SPONSORED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.category,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              pin.category,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Consumer<PinProvider>(
              builder: (context, pinProvider, child) {
                final distance = pinProvider.getFormattedDistanceToPin(pin);
                return Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pin.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailItem(
          context,
          Icons.star,
          'Rating',
          pin.rating > 0 ? '${pin.rating.toStringAsFixed(1)}/5.0' : 'No ratings yet',
        ),
        _buildDetailItem(
          context,
          Icons.people,
          'Check-ins',
          '${pin.checkInCount} people',
        ),
        _buildDetailItem(
          context,
          Icons.calendar_today,
          'Created',
          _formatDate(pin.createdAt),
        ),
        if (pin.tags.isNotEmpty)
          _buildDetailItem(
            context,
            Icons.tag,
            'Tags',
            pin.tags.join(', '),
          ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorSection(BuildContext context) {
    final sponsorInfo = pin.sponsorInfo!;
    
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (sponsorInfo.companyLogo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      sponsorInfo.companyLogo,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(Icons.business),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sponsorInfo.companyName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sponsor',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              sponsorInfo.perkTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sponsorInfo.perkDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            if (sponsorInfo.perkExpiry != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Valid until: ${_formatDate(sponsorInfo.perkExpiry!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer2<UserProvider, PinProvider>(
      builder: (context, userProvider, pinProvider, child) {
        final hasCheckedIn = userProvider.hasCompletedPin(pin.id);
        final canCheckIn = pinProvider.isUserNearPin(pin);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!hasCheckedIn)
              FilledButton.icon(
                onPressed: canCheckIn
                    ? () => _checkInAtPin(context, userProvider)
                    : null,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(canCheckIn ? 'Check In Here' : 'Too Far to Check In'),
              )
            else
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle, color: Colors.green),
                label: const Text('Checked In'),
              ),
            
            const SizedBox(height: 12),
            
            if (pin.isSponsored && pin.sponsorInfo != null && hasCheckedIn)
              OutlinedButton.icon(
                onPressed: () => _redeemPerk(context),
                icon: const Icon(Icons.card_giftcard),
                label: const Text('Redeem Perk'),
              ),
            
            const SizedBox(height: 12),
            
            OutlinedButton.icon(
              onPressed: () => _sharePin(context),
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkInAtPin(BuildContext context, UserProvider userProvider) async {
    await userProvider.checkInAtPin(pin.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked in at ${pin.title}! +${AppConfig.pointsPerCheckIn} points'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _redeemPerk(BuildContext context) {
    final sponsorInfo = pin.sponsorInfo!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem ${sponsorInfo.perkTitle}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sponsorInfo.perkDescription),
            if (sponsorInfo.perkCode != null) ...[
              const SizedBox(height: 16),
              Text(
                'Perk Code:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sponsorInfo.perkCode!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            if (sponsorInfo.contactInfo != null) ...[
              const SizedBox(height: 16),
              Text(
                'Contact: ${sponsorInfo.contactInfo}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (sponsorInfo.perkCode != null)
            FilledButton(
              onPressed: () {
                // Copy to clipboard functionality would go here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perk code copied to clipboard')),
                );
              },
              child: const Text('Copy Code'),
            ),
        ],
      ),
    );
  }

  void _sharePin(BuildContext context) {
    // Share functionality would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality would go here')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
