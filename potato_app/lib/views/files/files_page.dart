import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/viewmodels/room_provider.dart';
import 'package:potato/viewmodels/short_codes_history_provider.dart';
import 'package:potato/viewmodels/utils/file_size_utils.dart';
import 'package:potato/views/common/info_card.dart';
import 'package:potato/views/common/potato_button.dart';
import 'package:potato/views/common/potato_icon_button.dart';
import 'package:potato/views/error/error_view.dart';
import 'package:potato/views/files/file_list_item.dart';
import 'package:potato/views/files/short_codes_history.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:potato/views/theme.dart';

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

  void _onCodeChanged(String code) {
    if (code.isEmpty) {
      return;
    }
    ref.read(shortCodeHistoryProvider.notifier).historizeCode(code);
    setState(() => _activeCode = code);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeCode == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('files_page_title'))),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      context.tr('enter_code_to_see_files'),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Image.asset(
                    'assets/images/potato_eggman.png',
                    width: 100,
                    height: 100,
                  ),
                ],
              ),

              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: context.tr('code'),
                  hintText: context.tr('code_hint'),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
              ),
              PotatoButton.primary(
                onPressed: () {
                  final code = _codeController.text.trim().toUpperCase();
                  if (code.isNotEmpty) {
                    _onCodeChanged(code);
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.file_download, color: Colors.white),
                ),
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('load_files')),
                    Text(
                      context.tr('type_code_manually', args: []),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Container(height: 1, color: PotatoColors.gray),
                    ),
                    Text(
                      context.tr('files_page_or').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: PotatoColors.gray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Flexible(
                      child: Container(height: 1, color: PotatoColors.gray),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  return PotatoButton.secondary(
                    onPressed: () => _showQrScanner(context),
                    icon: const Icon(Icons.qr_code),
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('scan_code')),
                        Text(
                          context.tr('scan_code_to_download', args: []),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ShortCodesHistory(
                onTap: (code) {
                  _codeController.text = code;
                  _onCodeChanged(code);
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
        body: room.chunkInfos.isEmpty
            ? ErrorView(
                errorMessage: context.tr(
                  'no_files_found_for_code',
                  args: [_activeCode!],
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      // AppBar with back button, code, and QR code button
                      Row(
                        spacing: 16,
                        children: [
                          PotatoIconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_outlined,
                              size: 16,
                            ),
                            onPressed: () => setState(() {
                              _activeCode = null;
                              _codeController.clear();
                            }),
                          ),
                          Text(
                            _activeCode!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: PotatoColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 16,
                        children: [
                          InfoCard(
                            title: room.chunkInfos.length.toString(),
                            subtitle: context.tr('files').toUpperCase(),
                          ),
                          InfoCard(
                            title: humanReadableFileSize(
                              room.chunkCount * chunkSize,
                            ),
                            subtitle: context.tr('total').toUpperCase(),
                          ),
                          PotatoIconButton(
                            icon: const Icon(Icons.qr_code, size: 48),
                            onPressed: () => _showRoomQrCode(context),
                          ),
                        ],
                      ),
                      Text(
                        context.tr('files_page_content_section'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: room.chunkInfos.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: FileListItem(
                              code: _activeCode!,
                              chunkInfos: room.chunkInfos[index],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Future<void> _showRoomQrCode(BuildContext context) async {
    final code = _activeCode;
    if (code == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: double.maxFinite,
          height: 280,
          child: Center(child: QrImageView(data: code, size: 200)),
        ),
      ),
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
      _onCodeChanged(code ?? '');
      _codeController.text = code ?? '';
    });
  }
}
