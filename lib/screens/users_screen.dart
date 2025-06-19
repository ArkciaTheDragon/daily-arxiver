import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../services/api_service.dart';
import '../widgets/user_search_bar.dart';
import '../widgets/user_list.dart';
import '../utils/user_color.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  UsersScreenState createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen>
    with TickerProviderStateMixin {
  late Future<List<String>> _usersFuture;
  late AnimationController _fadeController;
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchController = TextEditingController();
    _fetchUsers();
    // Listen for baseUrl changes
    AppConfig().addListener(_fetchUsers);
    _fadeController.forward();
  }

  @override
  void dispose() {
    AppConfig().removeListener(_fetchUsers);
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchUsers() {
    setState(() {
      _usersFuture = context.read<ApiService>().fetchUsers();
    });
  }

  Future<void> _refreshUsers() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
    _fetchUsers();
    setState(() {});
  }

  List<String> _filterUsers(List<String> users) {
    if (_searchQuery.isEmpty) return users;

    return users
        .where(
          (user) => user.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Profile',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    bottom: 80,
                    right: 16,
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Welcome to your Daily Arxiv',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverSearchBarDelegate(
              child: UserSearchBar(
                controller: _searchController,
                searchQuery: _searchQuery,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              height: 64,
            ),
          ),
        ],
        body: Consumer<ApiService>(
          builder: (context, apiService, child) {
            return FadeTransition(
              opacity: _fadeController,
              child: RefreshIndicator(
                onRefresh: _refreshUsers,
                child: FutureBuilder<List<String>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Loading users...',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load users',
                              style: theme.textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _fetchUsers,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredUsers = _filterUsers(snapshot.data!);

                    return UserList(
                      users: filteredUsers,
                      searchQuery: _searchQuery,
                      theme: theme,
                      getUserColor: getUserColor,
                      onUserTap: (username) {
                        Navigator.of(
                          context,
                        ).pushNamed('/home', arguments: {'username': username});
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverSearchBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverSearchBarDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}
