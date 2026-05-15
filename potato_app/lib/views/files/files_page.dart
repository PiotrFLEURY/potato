import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/models/encryption/encryption_service.dart';
import 'package:potato/viewmodels/chunks_repository_provider.dart';
import 'package:potato/viewmodels/room_provider.dart';
import 'package:potato/views/common/potato_button.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  final _codeController = TextEditingController();
  String? _activeCode;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeCode == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Files')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              const Text(
                'Enter the code shared with you to access the files.',
                textAlign: TextAlign.center,
              ),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'e.g. ABCD1234',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
              ),
              PotatoButton.primary(
                onPressed: () {
                  final code = _codeController.text.trim().toUpperCase();
                  if (code.isNotEmpty) {
                    setState(() => _activeCode = code);
                  }
                },
                child: const Text('Load files'),
              ),
            ],
          ),
        ),
      );
    }

    final room = ref.watch(roomProvider(_activeCode!));
    return room.when(
      data: (room) => Scaffold(
        appBar: AppBar(
          title: Text('Files – $_activeCode'),
          leading: BackButton(
            onPressed: () => setState(() {
              _activeCode = null;
              _codeController.clear();
            }),
          ),
        ),
        body: room.chunkInfos.isEmpty
            ? const Center(child: Text('No files found for this code.'))
            : ListView.builder(
                itemCount: room.chunkInfos.length,
                itemBuilder: (context, index) => _FileListItem(
                  code: _activeCode!,
                  chunkInfos: room.chunkInfos[index],
                ),
              ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Files')),
        body: Center(child: Text('Error: $error')),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _FileListItem extends ConsumerStatefulWidget {
  const _FileListItem({required this.code, required this.chunkInfos});

  final String code;
  final ChunkInfos chunkInfos;

  @override
  ConsumerState<_FileListItem> createState() => _FileListItemState();
}

class _FileListItemState extends ConsumerState<_FileListItem> {
  String? _decryptedFilename;

  @override
  void initState() {
    super.initState();
    _decryptFilename();
  }

  Future<void> _decryptFilename() async {
    try {
      final name = await EncryptionService.decryptString(
        widget.code,
        widget.chunkInfos.filename,
      );
      if (mounted) setState(() => _decryptedFilename = name);
    } catch (_) {
      if (mounted) setState(() => _decryptedFilename = '(decryption failed)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.insert_drive_file),
      title: Text(_decryptedFilename ?? '…'),
      subtitle: Text('${widget.chunkInfos.chunks.length} chunk(s)'),
      trailing: IconButton(
        onPressed: () => _downloadFile(context),
        icon: const Icon(Icons.download),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    final savePath = await FilePicker.platform.getDirectoryPath();
    if (savePath == null) return;

    try {
      Uint8List fileBytes = Uint8List(0);
      for (final chunkId in widget.chunkInfos.chunks) {
        final encryptedBytes = await ref
            .read(chunksRepositoriesProvider)
            .downloadChunk(chunkId);
        final decryptedBytes = await EncryptionService.decryptBytes(
          widget.code,
          encryptedBytes,
        );
        fileBytes = Uint8List.fromList([...fileBytes, ...decryptedBytes]);
      }

      final filename = _decryptedFilename ?? widget.chunkInfos.filename;
      await File('$savePath/$filename').writeAsBytes(fileBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: $filename')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed: wrong code or corrupted data.')),
        );
      }
    }
  }
}
