import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key, this.showFaq = false});

  final bool showFaq;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(showFaq ? 'Frequently asked questions' : 'Help Center')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(showFaq ? 'Frequently asked questions' : 'Using YouthFinance', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const _HelpItem(
            question: 'How do I update my profile?',
            answer: 'Open Profile and select the edit icon beside your name. Your email is read-only after registration.',
          ),
          const _HelpItem(
            question: 'How does the Emergency Fund work?',
            answer: 'Adding or releasing money moves controlled money between General and Emergency Fund buckets. It does not create income or expenses.',
          ),
          const _HelpItem(
            question: 'Why are there no notifications?',
            answer: 'Notifications are created for Emergency Fund activity when the Emergency Fund activity preference is enabled in Settings.',
          ),
          const _HelpItem(
            question: 'How do investment records work?',
            answer: 'Investment records help you keep details of investments you already hold. Recording one does not move money or create a transaction.',
          ),
          const SizedBox(height: 16),
          const Text('Support requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Direct support request submission is not available in the current application. This Help Center provides the support material implemented by YouthFinance today.'),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String question;
  final String answer;
  const _HelpItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(title: Text(question), children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(answer))]),
  );
}
