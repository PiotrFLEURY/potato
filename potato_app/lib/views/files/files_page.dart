import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:potato/viewmodels/room_provider.dart';
import 'package:potato/viewmodels/short_codes_history_provider.dart';
import 'package:potato/views/common/potato_button.dart';
import 'package:potato/views/files/file_list_item.dart';
import 'package:potato/views/files/short_codes_history.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
                    _onCodeChanged(code);
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
        appBar: AppBar(
          title: Text(context.tr('files_for_code', args: [_activeCode!])),
          leading: BackButton(
            onPressed: () => setState(() {
              _activeCode = null;
              _codeController.clear();
            }),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () => _showRoomQrCode(context),
            ),
          ],
        ),
        body: room.chunkInfos.isEmpty
            ? Center(
                child: Text(
                  context.tr('no_files_found_for_code', args: [_activeCode!]),
                ),
              )
            : ListView.builder(
                itemCount: room.chunkInfos.length,
                itemBuilder: (context, index) => FileListItem(
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
