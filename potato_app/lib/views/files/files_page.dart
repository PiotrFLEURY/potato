import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/viewmodels/chunks_repository_provider.dart';
import 'package:potato/viewmodels/room_provider.dart';

class FilesPage extends ConsumerWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomProvider('default_room'));
    return room.when(
      data: (room) => Scaffold(
        appBar: AppBar(title: Text('Files in default_room')),
        body: ListView.builder(
          itemCount: room.chunkInfos.length,
          itemBuilder: (context, index) {
            final chunkInfos = room.chunkInfos[index];
            return ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text(chunkInfos.filename),
              subtitle: Text('Size: ${chunkInfos.chunks.length} chunks'),
              trailing: IconButton(
                onPressed: () => _downloadFile(chunkInfos, ref),
                icon: Icon(Icons.download),
              ),
            );
          },
        ),
      ),
      error: (error, stack) => Center(child: Text('Error: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _downloadFile(ChunkInfos chunkInfos, WidgetRef ref) async {
    // 1. Pick directory to save the file
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) {
      // User canceled the picker
      return;
    }
    final savePath = result; // You can also append a filename here if needed

    // 2. Download each chunk and save to the selected directory
    Uint8List fileBytes = Uint8List(0);
    for (final chunkId in chunkInfos.chunks) {
      final bytes = await ref
          .read(chunksRepositoriesProvider)
          .downloadChunk(chunkId);
      fileBytes = Uint8List.fromList([...fileBytes, ...bytes]);
    }
    // 3. Save the file to the selected directory
    final file = File('$savePath/${chunkInfos.filename}');
    await file.writeAsBytes(fileBytes);
  }
}
