import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/viewmodels/chunk_infos_bytes_provider.dart';

class ClipboardText extends ConsumerStatefulWidget {
  const ClipboardText({
    super.key,
    required this.code,
    required this.chunkInfos,
  });

  final String code;
  final ChunkInfos chunkInfos;

  @override
  ConsumerState<ClipboardText> createState() => _ClipboardTextState();
}

class _ClipboardTextState extends ConsumerState<ClipboardText> {
  @override
  Widget build(BuildContext context) {
    final bytes = ref.watch(
      chunkInfosBytesProvider(widget.code, widget.chunkInfos),
    );
    return bytes.when(
      data: (bytes) => Text(
        utf8.decode(bytes),
        overflow: TextOverflow.ellipsis,
        maxLines: 5,
        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
      ),
      error: (error, stackTrace) => Text(''),
      loading: () => CircularProgressIndicator(),
    );
  }
}
