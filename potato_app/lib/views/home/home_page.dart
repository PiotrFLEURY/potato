import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/models/encryption/encryption_service.dart';
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
                  onPressed: () => _sendFile(context, ref, (code) {
                    _showSuccessBottomsheet(context, code);
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

  void _showSuccessBottomsheet(BuildContext context, String code) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'File sent successfully!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Share this code to let others download the file:',
              textAlign: TextAlign.center,
            ),
            QrImageView(
              data: code,
              version: QrVersions.auto,
              size: 180.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied!')),
                    );
                  },
                ),
              ],
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
    void Function(String code) onSuccess,
  ) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      final filename = result.files.first.name;
      final filePath = result.files.first.path;
      if (filePath != null) {
        final code = EncryptionService.generateCode();
        final uuid = Uuid().v4();
        final File file = File(filePath);
        final fileBytes = await file.readAsBytes();
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
          final encryptedBytes = await EncryptionService.encryptBytes(
            code,
            Uint8List.fromList(chunkBytes),
          );
          final chunkId = '$uuid-$i';
          await ref
              .read(chunksRepositoriesProvider)
              .uploadChunk(chunkId, encryptedBytes);
          chunkIds.add(chunkId);
        }
        final encryptedFilename = await EncryptionService.encryptString(
          code,
          filename,
        );
        await ref
            .read(roomsRepositoryProvider)
            .addChunkToRoom(
              code,
              ChunkInfos(filename: encryptedFilename, chunks: chunkIds),
            );
        onSuccess(code);
      }
    }
  }
}
