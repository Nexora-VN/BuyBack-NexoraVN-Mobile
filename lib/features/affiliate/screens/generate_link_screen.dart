import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/generate_link_notes.dart';
import '../widgets/generate_link_panel.dart';

class GenerateLinkScreen extends StatelessWidget {
  const GenerateLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: const Text('Tạo link cashback'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GenerateLinkPanel(),
            SizedBox(height: 16),
            GenerateLinkNotes(),
          ],
        ),
      ),
    );
  }
}

