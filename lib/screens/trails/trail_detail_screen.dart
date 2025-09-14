import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trail_model.dart';
import '../../models/pin_model.dart';
import '../../providers/trail_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/pin_provider.dart';
import '../pins/pin_detail_screen.dart';

class TrailDetailScreen extends StatelessWidget {
  final TrailModel trail;

  const TrailDetailScreen({
    super.key,
    required this.trail,
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
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          trail.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getDifficultyColor(trail.difficulty),
                _getDifficultyColor(trail.difficulty).withOpacity(0.7),
              ],
            ),
          ),
          child: trail.imageUrl != null
              ? Image.network(
                  trail.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.route, size: 64, color: Colors.white),
                  ),
                )
              : const Center(
                  child: Icon(Icons.route, size: 64, color: Colors.white),
                ),
        ),
      ),
      actions: [
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final isCompleted = userProvider.hasCompletedTrail(trail.id);
            return isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrailInfo(context),
          const SizedBox(height: 16),
          _buildProgressSection(context),
          const SizedBox(height: 16),
          _buildDescription(context),
          const SizedBox(height: 16),
          _buildPinsList(context),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildTrailInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  context,
                  Icons.flag,
                  'Difficulty',
                  trail.difficulty.displayName,
                  _getDifficultyColor(trail.difficulty),
                ),
                _buildInfoItem(
                  context,
                  Icons.location_on,
                  'Pins',
                  '${trail.pinIds.length}',
                ),
                _buildInfoItem(
                  context,
                  Icons.access_time,
                  'Duration',
                  '${trail.estimatedDuration}min',
                ),
              ],
            ),
            if (trail.distance > 0) ...[
              const SizedBox(height: 16),
              _buildInfoItem(
                context,
                Icons.straighten,
                'Distance',
                '${trail.distance.toStringAsFixed(1)}km',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, [
    Color? color,
  ]) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final progress = userProvider.getTrailProgress(trail.pinIds);
        final progressPercentage = userProvider.getTrailProgressPercentage(trail.pinIds);
        final isCompleted = progressPercentage >= 1.0;

        return Card(
          color: isCompleted
              ? Colors.green.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.track_changes,
                      color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCompleted ? 'Trail Completed!' : 'Your Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : null,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$progress/${trail.pinIds.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progressPercentage * 100).toInt()}% complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          trail.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (trail.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: trail.tags.map((tag) {
              return Chip(
                label: Text(tag),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPinsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pins on this Trail',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Consumer2<TrailProvider, UserProvider>(
          builder: (context, trailProvider, userProvider, child) {
            final pins = trailProvider.getTrailPins(trail.id);
            
            if (pins.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('No pins found for this trail'),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pins.length,
              itemBuilder: (context, index) {
                final pin = pins[index];
                final isCompleted = userProvider.hasCompletedPin(pin.id);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                      child: Icon(
                        isCompleted ? Icons.check : Icons.location_on,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      pin.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      pin.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    trailing: isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openPinDetail(context, pin),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isCompleted = userProvider.hasCompletedTrail(trail.id);
        final progressPercentage = userProvider.getTrailProgressPercentage(trail.pinIds);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isCompleted && progressPercentage >= 1.0)
              FilledButton.icon(
                onPressed: () => _completeTrail(context, userProvider),
                icon: const Icon(Icons.flag),
                label: const Text('Complete Trail'),
              )
            else if (isCompleted)
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle, color: Colors.green),
                label: const Text('Trail Completed'),
              )
            else
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.track_changes),
                label: Text('${(progressPercentage * 100).toInt()}% Complete'),
              ),
            
            const SizedBox(height: 12),
            
            OutlinedButton.icon(
              onPressed: () => _shareTrail(context),
              icon: const Icon(Icons.share),
              label: const Text('Share Trail'),
            ),
          ],
        );
      },
    );
  }

  void _openPinDetail(BuildContext context, PinModel pin) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinDetailScreen(pin: pin),
      ),
    );
  }

  Future<void> _completeTrail(BuildContext context, UserProvider userProvider) async {
    await userProvider.completeTrail(trail.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Congratulations! Trail completed! +100 points'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareTrail(BuildContext context) {
    // Share functionality would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality would go here')),
    );
  }

  Color _getDifficultyColor(TrailDifficulty difficulty) {
    switch (difficulty) {
      case TrailDifficulty.easy:
        return Colors.green;
      case TrailDifficulty.medium:
        return Colors.orange;
      case TrailDifficulty.hard:
        return Colors.red;
      case TrailDifficulty.expert:
        return Colors.purple;
    }
  }
}
