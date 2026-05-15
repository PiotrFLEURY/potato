import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/viewmodels/chunks_repository_provider.dart';
import 'package:potato/viewmodels/rooms_repository_provider.dart';
import 'package:potato/views/common/potato_button.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Potato',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Push Over The Air To',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                Image.asset('assets/images/potato_mascot.png', width: 256),
                const Spacer(),
                PotatoButton.primary(
                  onPressed: () => _sendFile(context, ref, (chunkId) {
                    // Handle success
                    _showSuccessBottomsheet(context, chunkId);
                  }),
                  child: Text('Send file'),
                ),
                PotatoButton.secondary(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/files');
                  },
                  child: Text('See files'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessBottomsheet(BuildContext context, String chunkId) {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:8080',
    );
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('File sent successfully!'),
            QrImageView(
              data: '$backendUrl/chunks/$chunkId',
              version: QrVersions.auto,
              size: 200.0,
            ),
            PotatoButton.primary(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFile(
    BuildContext context,
    WidgetRef ref,
    void Function(String chunkId) onSuccess,
  ) async {
    // 1. Pick file
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    // 2. If file is picked, navigate to send page with file path
    if (result != null && result.files.isNotEmpty) {
      final filename = result.files.first.name;
      final filePath = result.files.first.path;
      if (filePath != null) {
        final uuid = Uuid().v4();
        final File file = File(filePath);
        final fileBytes = await file.readAsBytes();
        // Split in chunks of 1MB and upload each chunk, then add to room
        final chunkSize = 1024 * 1024; // 1MB
        final totalChunks = (fileBytes.length / chunkSize).ceil();
        final List<String> chunkIds = [];
        for (int i = 0; i < totalChunks; i++) {
          final start = i * chunkSize;
          final end = start + chunkSize;
          final chunkBytes = fileBytes.sublist(
            start,
            end > fileBytes.length ? fileBytes.length : end,
          );
          final chunkId = '$uuid-$i';
          await ref
              .read(chunksRepositoriesProvider)
              .uploadChunk(chunkId, chunkBytes);
          chunkIds.add(chunkId);
        }
        await ref
            .read(roomsRepositoryProvider)
            .addChunkToRoom(
              'default_room',
              ChunkInfos(filename: filename, chunks: chunkIds),
            );
        onSuccess(uuid);
      }
    }
  }
}
