import 'package:flutter/material.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current appearance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.light_mode_outlined),
              title: Text('Light'),
              subtitle: Text('YouthFinance currently provides a single light appearance.'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'A dark appearance is not available in the existing app theme. This screen reflects the current supported setting without introducing an incomplete global theme.',
            ),
          ],
        ),
      ),
    );
  }
}
