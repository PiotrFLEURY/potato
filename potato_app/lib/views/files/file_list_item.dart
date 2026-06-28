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
import 'package:potato/viewmodels/utils/file_size_utils.dart';
import 'package:potato/views/common/potato_button.dart';
import 'package:potato/views/files/clipboard_text.dart';
import 'package:potato/views/files/file_indicator.dart';
import 'package:potato/views/success/success_dialog.dart';
import 'package:potato/views/theme.dart';

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

  @override
  void initState() {
    super.initState();
    _decryptFilename();
  }

  bool _heavyFile() {
    return widget.chunkInfos.chunks.length > 20;
  }

  Future<void> _decryptFilename() async {
    try {
      final name = await EncryptionService.decryptString(
        widget.code,
        widget.chunkInfos.filename,
      );
      if (mounted) {
        setState(() => _decryptedFilename = name);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _decryptedFilename = context.tr('decryption_failed'));
      }
    }
  }

  Text _fileSize() {
    if (_fileBytes != null) {
      return Text(
        humanReadableFileSize(_fileBytes!.length),
        style: const TextStyle(
          fontSize: 16,
          color: PotatoColors.gray,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Text(
      context.tr('downloading_file'),
      style: const TextStyle(
        fontSize: 16,
        color: PotatoColors.gray,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chunkInfosBytesProvider(widget.code, widget.chunkInfos), (
      previous,
      next,
    ) {
      if (next.hasValue) {
        setState(() {
          _fileBytes = next.value;
        });
      }
    });
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PotatoColors.gray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.all(8),
        onTap: isPicture() ? () => _previewFile(context) : null,
        leading: SizedBox(
          width: 48,
          height: 48,
          child: FileIndicator(
            color: PotatoColors.lightBlue,
            fileExtension: _decryptedFilename?.split('.').last ?? '???',
          ),
        ),
        title: isClipboard()
            ? ClipboardText(code: widget.code, chunkInfos: widget.chunkInfos)
            : Text(
                _decryptedFilename ?? '…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        subtitle: _fileSize(),
        trailing: _fileBytes == null
            ? null
            : PopupMenuButton(
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

  bool isPicture() {
    final lowerName = (_decryptedFilename ?? '').toLowerCase();
    return lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.bmp') ||
        lowerName.endsWith('.gif') ||
        lowerName.endsWith('.webp') ||
        (lowerName.endsWith('.heic') &&
            !kIsWeb &&
            (Platform.isIOS || Platform.isMacOS));
  }

  bool isClipboard() {
    return _decryptedFilename == "clipboard.txt";
  }

  Future<void> _previewFile(BuildContext context) async {
    if (!isPicture()) {
      return;
    }

    if (_decryptedFilename == null) {
      return;
    }

    final fileBytes = await ref.read(
      chunkInfosBytesProvider(widget.code, widget.chunkInfos).future,
    );

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
                child: Image.memory(fileBytes, height: 400),
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

  Future<Uint8List> asBytes() {
    return ref.read(
      chunkInfosBytesProvider(widget.code, widget.chunkInfos).future,
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    final filename = _decryptedFilename ?? widget.chunkInfos.filename;

    final fileBytes = await asBytes();

    final result = await FilePicker.platform.saveFile(
      fileName: filename,
      bytes: fileBytes,
    );

    if (context.mounted && result != null) {
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

    final filename = _decryptedFilename ?? widget.chunkInfos.filename;

    final fileBytes = await asBytes();

    await Gal.requestAccess();

    await Gal.putImageBytes(fileBytes, name: filename);

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

    final fileBytes = await ref.read(
      chunkInfosBytesProvider(widget.code, widget.chunkInfos).future,
    );

    final text = utf8.decode(fileBytes);

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
