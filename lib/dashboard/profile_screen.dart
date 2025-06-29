import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    Future<void> exportAllData() async {
  final projects = await FirebaseFirestore.instance.collection('projects').get();
  final tasks = await FirebaseFirestore.instance.collection('tasks').get();
  final invoices = await FirebaseFirestore.instance.collection('invoices').get();

  final data = {
    "projects": projects.docs.map((d) => d.data()).toList(),
    "tasks": tasks.docs.map((d) => d.data()).toList(),
    "invoices": invoices.docs.map((d) => d.data()).toList(),
  };

  final file = await FilePicker.platform.saveFile(dialogTitle: 'Save Export', fileName: 'freelancer_data.json');
  if (file != null) {
    await File(file).writeAsString(jsonEncode(data));
  }
}


    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            Text(user?.email ?? "No email", style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 40),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: themeProvider.isDarkMode,
              onChanged: themeProvider.toggleTheme,
              secondary: const Icon(Icons.dark_mode),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: () {
                FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset link sent.")));
              },
            ),

          ],
        ),
      ),
    );
  }
}
