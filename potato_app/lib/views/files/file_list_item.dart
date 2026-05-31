import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/models/encryption/encryption_service.dart';
import 'package:potato/viewmodels/chunk_infos_bytes_provider.dart';
import 'package:potato/views/common/potato_button.dart';
import 'package:potato/views/success/success_dialog.dart';

class FileListItem extends ConsumerStatefulWidget {
  const FileListItem({super.key, required this.code, required this.chunkInfos});

  final String code;
  final ChunkInfos chunkInfos;

  @override
  ConsumerState<FileListItem> createState() => _FileListItemState();
}

class _FileListItemState extends ConsumerState<FileListItem> {
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
      if (mounted) {
        setState(() => _decryptedFilename = name);
        if (isClipboard()) {
          _preloadFileBytes();
        }
      }
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
    if (bytes.isNotEmpty && mounted) {
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
            : _fileBytes != null && isPicture()
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
        title: isClipboard() && _fileBytes != null
            ? Text(
                utf8.decode(_fileBytes!),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            : Text(_decryptedFilename ?? '…'),
        subtitle: Text(_humanReadableFileSize()),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            return [
              if (isPicture())
                PopupMenuItem(
                  value: 'preview',
                  child: Text(context.tr('popup_menu_preview')),
                ),
              if (!isClipboard())
                PopupMenuItem(
                  value: 'download',
                  child: Text(context.tr('popup_menu_download')),
                ),
              if (!kIsWeb &&
                  (Platform.isIOS || Platform.isAndroid) &&
                  isPicture())
                PopupMenuItem(
                  value: 'save_to_gallery',
                  child: Text(context.tr('popup_menu_save_to_gallery')),
                ),
              if (isClipboard())
                PopupMenuItem(
                  value: 'copy_to_clipboard',
                  child: Text(context.tr('popup_menu_copy_to_clipboard')),
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
              case 'copy_to_clipboard':
                _copyToClipboard(context);
                break;
            }
          },
        ),
      ),
    );
  }

  String _humanReadableFileSize() {
    if (_fileBytes == null) return '…';
    int size = _fileBytes!.length;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
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

  bool isClipboard() {
    return _decryptedFilename == "clipboard.txt";
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
                child: Image.memory(_fileBytes!, height: 400),
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

  Future<void> _copyToClipboard(BuildContext context) async {
    if (!isClipboard()) {
      return;
    }

    await _preloadFileBytes();
    if (_fileBytes == null) return;

    final text = utf8.decode(_fileBytes!);

    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => SuccessDialog(
          title: context.tr('text_copied_to_clipboard_title'),
          message: context.tr('text_copied_to_clipboard_message'),
        ),
      );
    }
  }
}
