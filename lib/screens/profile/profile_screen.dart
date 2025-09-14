import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider_simple.dart';
import '../../providers/user_provider.dart';
import '../../providers/pin_provider.dart';
import '../../providers/trail_provider.dart';
import '../../models/badge_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await context.read<PinProvider>().loadUserPins(authProvider.currentUser!.id);
      await context.read<TrailProvider>().loadUserTrails(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, user, authProvider),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildStatsSection(context, userProvider),
                    _buildTabSection(context),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, user, AuthProvider authProvider) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (user.isSponsored)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'SPONSOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit_profile',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Profile'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(value, authProvider),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, UserProvider userProvider) {
    final user = userProvider.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Stats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    Icons.star,
                    'Points',
                    user.totalPoints.toString(),
                    Colors.amber,
                  ),
                  _buildStatItem(
                    context,
                    Icons.location_on,
                    'Pins',
                    user.completedPins.length.toString(),
                    Colors.red,
                  ),
                  _buildStatItem(
                    context,
                    Icons.route,
                    'Trails',
                    user.completedTrails.length.toString(),
                    Colors.blue,
                  ),
                  _buildStatItem(
                    context,
                    Icons.military_tech,
                    'Badges',
                    user.badges.length.toString(),
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Badges', icon: Icon(Icons.military_tech)),
            Tab(text: 'My Pins', icon: Icon(Icons.location_on)),
            Tab(text: 'Activity', icon: Icon(Icons.timeline)),
          ],
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBadgesTab(context),
              _buildMyPinsTab(context),
              _buildActivityTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesTab(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userBadges = userProvider.userBadges;
        final availableBadges = userProvider.availableBadges;
        
        if (userBadges.isEmpty && availableBadges.isEmpty) {
          return const Center(
            child: Text('No badges available'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (userBadges.isNotEmpty) ...[
              Text(
                'Earned Badges',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: userBadges.length,
                itemBuilder: (context, index) {
                  return _buildBadgeItem(context, userBadges[index], true);
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Show locked badges
            Text(
              'Available Badges',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: availableBadges.length,
              itemBuilder: (context, index) {
                final badge = availableBadges[index];
                final isEarned = userBadges.any((b) => b.id == badge.id);
                return _buildBadgeItem(context, badge, isEarned);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeItem(BuildContext context, BadgeModel badge, bool isEarned) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge, isEarned),
      child: Container(
        decoration: BoxDecoration(
          color: isEarned
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech,
              size: 32,
              color: isEarned
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 4),
            Text(
              badge.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isEarned
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPinsTab(BuildContext context) {
    return Consumer<PinProvider>(
      builder: (context, pinProvider, child) {
        final userPins = pinProvider.userPins;
        
        if (userPins.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text('No pins created yet'),
                Text('Create your first pin to get started!'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userPins.length,
          itemBuilder: (context, index) {
            final pin = userPins[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: pin.isSponsored
                      ? Colors.orange
                      : Theme.of(context).colorScheme.primary,
                  child: Icon(
                    pin.isSponsored ? Icons.star : Icons.location_on,
                    color: Colors.white,
                  ),
                ),
                title: Text(pin.title),
                subtitle: Text(pin.category),
                trailing: Text(
                  '${pin.checkInCount} check-ins',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  // Navigate to pin detail
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        if (user == null) return const SizedBox.shrink();

        // Mock activity data - in a real app, this would come from a service
        final activities = [
          {
            'icon': Icons.location_on,
            'title': 'Checked in at ${user.completedPins.length} locations',
            'time': 'Recent activity',
            'color': Colors.red,
          },
          {
            'icon': Icons.route,
            'title': 'Completed ${user.completedTrails.length} trails',
            'time': 'This month',
            'color': Colors.blue,
          },
          {
            'icon': Icons.military_tech,
            'title': 'Earned ${user.badges.length} badges',
            'time': 'All time',
            'color': Colors.purple,
          },
          {
            'icon': Icons.star,
            'title': 'Accumulated ${user.totalPoints} points',
            'time': 'Total score',
            'color': Colors.amber,
          },
        ];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (activity['color'] as Color).withOpacity(0.1),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                  ),
                ),
                title: Text(activity['title'] as String),
                subtitle: Text(activity['time'] as String),
              ),
            );
          },
        );
      },
    );
  }

  void _showBadgeDetails(BuildContext context, BadgeModel badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.military_tech,
              color: isEarned ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(badge.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description),
            const SizedBox(height: 12),
            if (badge.requiredPoints > 0)
              Text('Required: ${badge.requiredPoints} points'),
            if (badge.requiredCount != null)
              Text('Required: ${badge.requiredCount} ${badge.requiredAction ?? 'actions'}'),
            const SizedBox(height: 8),
            Chip(
              label: Text(badge.rarity.toString().split('.').last.toUpperCase()),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value, AuthProvider authProvider) {
    switch (value) {
      case 'edit_profile':
        _showEditProfileDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
      case 'logout':
        _showLogoutDialog(authProvider);
        break;
    }
  }

  void _showEditProfileDialog() {
    // Edit profile functionality would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile functionality would go here')),
    );
  }

  void _showSettingsDialog() {
    // Settings functionality would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings functionality would go here')),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
