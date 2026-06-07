final chunkSize = ((1024 * 1024) / 2).ceil(); // 512 KB

const maxFileSize = 50 * 1024 * 1024; // 50 Mo

String humanReadableFileSize(int? size) {
  if (size == null) return '…';
  if (size < 1024) return '$size B';
  if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
  if (size < 1024 * 1024 * 1024) {
    return '${(size / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
  return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(0)} GB';
}
