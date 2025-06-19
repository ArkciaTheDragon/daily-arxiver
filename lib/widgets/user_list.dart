import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  final List<String> users;
  final String searchQuery;
  final ThemeData theme;
  final void Function(String username) onUserTap;
  final Color Function(String username, ThemeData theme) getUserColor;

  const UserList({
    super.key,
    required this.users,
    required this.searchQuery,
    required this.theme,
    required this.onUserTap,
    required this.getUserColor,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isEmpty
                  ? Icons.people_outline
                  : Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No users available'
                  : 'No users match "$searchQuery"',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: users.length,
      itemBuilder: (ctx, index) {
        final username = users[index];
        final userColor = getUserColor(username, theme);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onUserTap(username),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: userColor.withValues(alpha: 0.2),
                      child: Text(
                        username.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: userColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(username, style: theme.textTheme.titleMedium),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
