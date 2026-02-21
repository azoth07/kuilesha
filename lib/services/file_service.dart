import 'file_service_stub.dart'
    if (dart.library.io) 'file_service_io.dart'
    if (dart.library.html) 'file_service_web.dart' as impl;

abstract class FileService {
  static FileService get instance => impl.createFileService();
  Future<void> shareFile(String content, String fileName);
}
