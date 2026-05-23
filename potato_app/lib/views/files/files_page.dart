import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/models/encryption/encryption_service.dart';
import 'package:potato/viewmodels/chunk_infos_bytes_provider.dart';
import 'package:potato/viewmodels/room_provider.dart';
import 'package:potato/views/common/potato_button.dart';
import 'package:potato/views/success/success_dialog.dart';

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
              Builder(
                builder: (context) {
                  return PotatoButton.secondary(
                    onPressed: () => _showQrScanner(context),
                    child: Icon(Icons.qr_code),
                  );
                },
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

  Future<void> _showQrScanner(BuildContext context) async {
    final code = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 16),
            Text(
              context.tr('scan_qr_code_to_get_files'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final code = capture.barcodes.first.displayValue;
                  Navigator.of(context).pop(code);
                },
              ),
            ),
          ],
        );
      },
    );
    setState(() {
      _activeCode = code;
      _codeController.text = code ?? '';
    });
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

  Uint8List? _fileBytes;

  bool _loading = false;

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

  Future<void> _preloadFileBytes() async {
    if (_fileBytes != null) return;
    setState(() {
      _loading = true;
    });
    final bytes = await ref.read(
      chunkInfosBytesProvider(widget.code, widget.chunkInfos).future,
    );
    if (bytes.isNotEmpty) {
      setState(() {
        _fileBytes = bytes;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: () => _previewFile(context),
        leading: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : _fileBytes != null
            ? Image.memory(
                _fileBytes!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/potato_eggman.png',
                width: 48,
                height: 48,
              ),
        title: Text(_decryptedFilename ?? '…'),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'preview',
                child: Text(context.tr('popup_menu_preview')),
              ),
              PopupMenuItem(
                value: 'download',
                child: Text(context.tr('popup_menu_download')),
              ),
              if ((Platform.isIOS || Platform.isAndroid) && isPicture())
                PopupMenuItem(
                  value: 'save_to_gallery',
                  child: Text(context.tr('popup_menu_save_to_gallery')),
                ),
            ];
          },
          onSelected: (value) {
            switch (value) {
              case 'preview':
                _previewFile(context);
                break;
              case 'download':
                _downloadFile(context);
                break;
              case 'save_to_gallery':
                _saveToGallery(context);
                break;
            }
          },
        ),
      ),
    );
  }

  bool isPicture() {
    final lowerName = (_decryptedFilename ?? '').toLowerCase();
    return lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.bmp') ||
        lowerName.endsWith('.gif') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.heic');
  }

  Future<void> _previewFile(BuildContext context) async {
    if (!isPicture()) {
      return;
    }

    await _preloadFileBytes();

    if (_fileBytes == null || _decryptedFilename == null) {
      return;
    }

    if (context.mounted) {
      showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.memory(_fileBytes!),
              ),
              Text(_decryptedFilename!),
              PotatoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('close')),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    await _preloadFileBytes();
    if (_fileBytes == null) return;

    final filename = _decryptedFilename ?? widget.chunkInfos.filename;

    await FilePicker.platform.saveFile(fileName: filename, bytes: _fileBytes);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => SuccessDialog(
          title: context.tr('filed_saved_to_files_title'),
          message: context.tr('filed_saved_to_files_message'),
        ),
      );
    }
  }

  Future<void> _saveToGallery(BuildContext context) async {
    if (!isPicture()) {
      return;
    }

    await _preloadFileBytes();
    if (_fileBytes == null) return;

    final filename = _decryptedFilename ?? widget.chunkInfos.filename;

    await Gal.requestAccess();

    await Gal.putImageBytes(_fileBytes!, name: filename);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => SuccessDialog(
          title: context.tr('filed_saved_to_gallery_title'),
          message: context.tr('filed_saved_to_gallery_message'),
        ),
      );
    }
  }
}
