import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
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
        appBar: AppBar(title: Text(context.tr('files_page_title'))),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Image.asset(
                'assets/images/potato_eggman.png',
                width: 100,
                height: 100,
              ),
              Text(
                context.tr('enter_code_to_see_files'),
                textAlign: TextAlign.center,
              ),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: context.tr('code'),
                  hintText: context.tr('code_hint'),
                  border: const OutlineInputBorder(),
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
                child: Text(context.tr('load_files')),
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
          title: Text(context.tr('files_for_code', args: [_activeCode!])),
          leading: BackButton(
            onPressed: () => setState(() {
              _activeCode = null;
              _codeController.clear();
            }),
          ),
        ),
        body: room.chunkInfos.isEmpty
            ? Center(
                child: Text(
                  context.tr('no_files_found_for_code', args: [_activeCode!]),
                ),
              )
            : ListView.builder(
                itemCount: room.chunkInfos.length,
                itemBuilder: (context, index) => _FileListItem(
                  code: _activeCode!,
                  chunkInfos: room.chunkInfos[index],
                ),
              ),
      ),
      error: (error, stack) {
        if (kDebugMode) {
          debugPrintStack(label: 'Room load error: $error', stackTrace: stack);
        }
        return Scaffold(
          appBar: AppBar(title: Text(context.tr('files_page_title'))),
          body: Center(
            child: Text(
              context.tr('failed_to_load_files_for_code', args: [_activeCode!]),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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
      if (mounted) {
        setState(() => _decryptedFilename = context.tr('decryption_failed'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _previewFile(context),
      leading: Image.asset(
        'assets/images/potato_eggman.png',
        width: 40,
        height: 40,
      ),
      title: Text(_decryptedFilename ?? '…'),
      subtitle: Row(
        children: [
          // Download
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _downloadFile(context),
          ),
          // Save to gallery
          if (Platform.isIOS || Platform.isAndroid)
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: () => _saveToGallery(context),
            ),
        ],
      ),
    );
  }

  Future<Uint8List> _fileBytes() async {
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
      return fileBytes;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrintStack(label: 'Download error: $e', stackTrace: stack);
      }
    }
    return Uint8List(0);
  }

  bool isPicture() {
    final lowerName = (_decryptedFilename ?? '').toLowerCase();
    return lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.bmp') ||
        lowerName.endsWith('.gif');
  }

  Future<void> _previewFile(BuildContext context) async {
    if (!isPicture()) {
      return;
    }

    final fileBytes = await _fileBytes();

    if (fileBytes.isEmpty || _decryptedFilename == null) {
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_decryptedFilename!),
          content: Image.memory(fileBytes),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('close')),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    Uint8List fileBytes = await _fileBytes();
    if (fileBytes.isEmpty) return;

    final filename = _decryptedFilename ?? widget.chunkInfos.filename;

    await FilePicker.platform.saveFile(fileName: filename, bytes: fileBytes);
  }

  Future<void> _saveToGallery(BuildContext context) async {
    if (!isPicture()) {
      return;
    }

    Uint8List fileBytes = await _fileBytes();
    if (fileBytes.isEmpty) return;

    final filename = _decryptedFilename ?? widget.chunkInfos.filename;

    await Gal.requestAccess();

    await Gal.putImageBytes(fileBytes, name: filename);
  }
}
