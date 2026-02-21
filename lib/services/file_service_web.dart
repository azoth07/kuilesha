import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'file_service.dart';

FileService createFileService() => WebFileService();

class WebFileService extends FileService {
  @override
  Future<void> shareFile(String content, String fileName) async {
    final bytes = utf8.encode(content);
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'text/csv'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = fileName;
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
