import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/theme_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final user = authViewModel.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("You are not logged in.", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Log Out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true), child: const Text("Log Out", ),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.red)
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await authViewModel.logout();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.secondary,
                child: Icon(Icons.person, size: 80, color: theme.colorScheme.onSecondary),
              ),
              const SizedBox(height: 16),
              Text(user.name, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(user.email, style: theme.textTheme.bodySmall),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User Details", style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      _buildInfoRow("Email", user.email, theme),
                      _buildInfoRow("Phone Number", user.phone, theme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Dark Mode", style: theme.textTheme.bodyMedium),
                      CupertinoSwitch(
                        value: themeViewModel.isDarkMode,
                        onChanged: (value) {
                          themeViewModel.toggleTheme(value);
                        },
                        activeColor: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Edit Profile feature coming soon!"))),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Edit Profile", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, style: theme.textTheme.bodyMedium, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}