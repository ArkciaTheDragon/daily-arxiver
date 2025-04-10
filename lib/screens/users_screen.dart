import 'package:daily_arxiv_flutter/config/app_config.dart';
import 'package:daily_arxiv_flutter/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<String>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    // Listen for baseUrl changes
    AppConfig().addListener(_fetchUsers);
  }

  @override
  void dispose() {
    AppConfig().removeListener(_fetchUsers);
    super.dispose();
  }

  void _fetchUsers() {
    _usersFuture = context.read<ApiService>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<ApiService>(
        builder: (context, apiService, child) {
          // Re-fetch users when baseUrl changes
          _fetchUsers();

          return FutureBuilder<List<String>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to fetch users: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _fetchUsers();
                          });
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder:
                    (ctx, index) => ListTile(
                      title: Text(snapshot.data![index]),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/query',
                            arguments: {'username': snapshot.data![index]},
                          ),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
