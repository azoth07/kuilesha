import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'file_service.dart';

FileService createFileService() => IoFileService();

class IoFileService extends FileService {
  @override
  Future<void> shareFile(String content, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: '亏了啥 - 数据导出'),
    );
  }
}
