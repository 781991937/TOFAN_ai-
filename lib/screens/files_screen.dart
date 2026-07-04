import 'package:flutter/material.dart';

/// Files screen for browsing and managing documents used with TOFAN AI
/// (e.g. attachments for chat context). File picking/storage integration
/// (file_picker, path_provider) can be wired in here.
class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text('No files yet', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Upload documents to give TOFAN AI more context',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
