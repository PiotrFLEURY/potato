import 'package:cross_file/cross_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/models/encryption/encryption_service.dart';
import 'package:potato/viewmodels/chunks_repository_provider.dart';
import 'package:potato/viewmodels/loading_state_provider.dart';
import 'package:potato/viewmodels/rooms_repository_provider.dart';
import 'package:potato/viewmodels/short_codes_history_provider.dart';
import 'package:potato/views/common/potato_button.dart';
import 'package:potato/views/loading/loading_barrier.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadingBarrier(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (kDebugMode)
              IconButton(
                icon: const Icon(Icons.translate),
                onPressed: () {
                  final newLocale = context.locale.languageCode == 'en'
                      ? 'fr'
                      : 'en';
                  context.setLocale(Locale(newLocale));
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.tr('app_title'),
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                ),
                Text(
                  context.tr('app_description'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                Image.asset('assets/images/potato_mascot.png', width: 256),
                const Spacer(),
                PotatoButton.primary(
                  onPressed: () async {
                    _sendFile(context, ref, (code) {
                      ref
                          .read(shortCodeHistoryProvider.notifier)
                          .historizeCode(code);
                      _showSuccessBottomsheet(context, code);
                    });
                  },
                  child: Text(context.tr('send_file')),
                ),
                PotatoButton.secondary(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/files');
                  },
                  child: Text(context.tr('see_files')),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<FileType?> _selectFileType(BuildContext context) async {
    FileType? selectedType;
    selectedType = await showDialog<FileType>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('select_file_type')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(context.tr('file_type_any')),
              onTap: () {
                Navigator.of(context).pop(FileType.any);
              },
            ),
            ListTile(
              title: Text(context.tr('file_type_image')),
              onTap: () {
                Navigator.of(context).pop(FileType.image);
              },
            ),
            ListTile(
              title: Text(context.tr('file_type_video')),
              onTap: () {
                Navigator.of(context).pop(FileType.video);
              },
            ),
          ],
        ),
      ),
    );
    return selectedType;
  }

  void _showSuccessBottomsheet(BuildContext context, String code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('file_sent_successfully'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              context.tr('share_code_to_download'),
              textAlign: TextAlign.center,
            ),
            QrImageView(data: code, version: QrVersions.auto, size: 180.0),
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
                  },
                ),
              ],
            ),
            PotatoButton.primary(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('close')),
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
    final fileType = await _selectFileType(context);
    if (fileType == null) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: fileType,
    );
    if (result != null && result.files.isNotEmpty) {
      final validSize = _checkFileSize(result.files);
      if (!validSize) {
        ref.read(loadingStateProvider.notifier).setLoading(false);
        if (context.mounted) {
          _showInvalidFileSizeDialog(context);
        }
        return;
      }
      ref.read(loadingStateProvider.notifier).setLoading(true);
      final code = EncryptionService.generateCode();

      for (final file in result.files) {
        await _uploadFile(file, code, ref);
      }

      ref.read(loadingStateProvider.notifier).setLoading(false);
      onSuccess(code);
    }
  }

  void _showInvalidFileSizeDialog(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('file_too_large')),
        content: Text(context.tr('file_size_limit_explanation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _checkFileSize(List<PlatformFile> files) {
    const maxSize = 10 * 1024 * 1024; // 10 Mo
    for (final file in files) {
      if (file.size > maxSize) {
        return false;
      }
    }
    return true;
  }

  Future<void> _uploadFile(
    PlatformFile file,
    String code,
    WidgetRef ref,
  ) async {
    final filename = file.name;
    final filePath = file.path;
    if (filePath != null) {
      final uuid = Uuid().v4();
      final XFile xFile = file.xFile;
      final fileBytes = await xFile.readAsBytes();
      final chunkSize = ((1024 * 1024) / 2).ceil(); // 512 KB
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
    }
  }
}
