import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trail_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/trail_model.dart';
import 'trail_detail_screen.dart';

class TrailsScreen extends StatefulWidget {
  const TrailsScreen({super.key});

  @override
  State<TrailsScreen> createState() => _TrailsScreenState();
}

class _TrailsScreenState extends State<TrailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TrailDifficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrails() async {
    await context.read<TrailProvider>().loadTrails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trails'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'My Trails'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDiscoverTab(),
                _buildMyTrailsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTrail,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search trails...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return Consumer<TrailProvider>(
      builder: (context, trailProvider, child) {
        if (trailProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<TrailModel> trails = _searchQuery.isEmpty
            ? trailProvider.filteredTrails
            : trailProvider.searchTrails(_searchQuery);

        if (trails.isEmpty) {
          return _buildEmptyState(
            'No trails found',
            _searchQuery.isEmpty
                ? 'Be the first to create a trail!'
                : 'Try a different search term',
          );
        }

        return RefreshIndicator(
          onRefresh: () => trailProvider.refreshTrails(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trails.length,
            itemBuilder: (context, index) {
              return _buildTrailCard(trails[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyTrailsTab() {
    return Consumer2<TrailProvider, UserProvider>(
      builder: (context, trailProvider, userProvider, child) {
        final userTrails = trailProvider.userTrails;

        if (userTrails.isEmpty) {
          return _buildEmptyState(
            'No trails created',
            'Create your first trail to get started!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userTrails.length,
          itemBuilder: (context, index) {
            return _buildTrailCard(userTrails[index]);
          },
        );
      },
    );
  }

  Widget _buildTrailCard(TrailModel trail) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final completionPercentage = userProvider.getTrailProgressPercentage(trail.pinIds);
        final isCompleted = completionPercentage >= 1.0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _openTrailDetail(trail),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trail.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    trail.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      _buildTrailInfoChip(
                        icon: Icons.flag,
                        label: trail.difficulty.displayName,
                        color: _getDifficultyColor(trail.difficulty),
                      ),
                      const SizedBox(width: 8),
                      _buildTrailInfoChip(
                        icon: Icons.location_on,
                        label: '${trail.pinIds.length} pins',
                      ),
                      const SizedBox(width: 8),
                      _buildTrailInfoChip(
                        icon: Icons.access_time,
                        label: '${trail.estimatedDuration}min',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${(completionPercentage * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: completionPercentage,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrailInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
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
            Text(
              'Filter Trails',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Difficulty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedDifficulty == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = selected ? null : _selectedDifficulty;
                    });
                    context.read<TrailProvider>().setDifficultyFilter(_selectedDifficulty);
                    Navigator.pop(context);
                  },
                ),
                ...TrailDifficulty.values.map(
                  (difficulty) => FilterChip(
                    label: Text(difficulty.displayName),
                    selected: _selectedDifficulty == difficulty,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDifficulty = selected ? difficulty : null;
                      });
                      context.read<TrailProvider>().setDifficultyFilter(_selectedDifficulty);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openTrailDetail(TrailModel trail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailDetailScreen(trail: trail),
      ),
    );
  }

  void _createNewTrail() {
    // Navigate to create trail screen (would be implemented)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create trail functionality would go here')),
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
