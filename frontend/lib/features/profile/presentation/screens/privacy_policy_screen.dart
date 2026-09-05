import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text('YouthFinance Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 16),
          _PolicySection(
            title: 'Information in your account',
            body: 'YouthFinance stores the account and financial information you enter so the application can provide its budgeting, goal, fund, and profile features.',
          ),
          _PolicySection(
            title: 'How information is used',
            body: 'Information is used within YouthFinance to display your account, financial records, goals, funds, and insights. This screen does not make claims about external sharing, encryption, or regulatory status.',
          ),
          _PolicySection(
            title: 'Your choices',
            body: 'You can update the profile information available in the app. Contact and account-deletion processes are not currently implemented in this application.',
          ),
          _PolicySection(
            title: 'Policy status',
            body: 'This in-app policy is application guidance and requires legal review before being used as a final production legal policy.',
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(body),
      ],
    ),
  );
}
