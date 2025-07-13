import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportManager {
  Future<void> exportToJson(Map<String, dynamic> data, String baseFileName) async {
    try {
      // ✅ External storage directory (ADB-accessible)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        print('❌ External storage directory not available');
        return;
      }

      // ⏱️ Format timestamp for filename
      final timestamp = DateTime.now().toIso8601String().replaceAll(":", "-");
      final fileName = '$baseFileName\_$timestamp.json';

      // 📄 Create file path
      final externalFile = File('${externalDir.path}/$fileName');

      // 🔄 Convert map to pretty-printed JSON
      final jsonData = const JsonEncoder.withIndent('  ').convert(data);

      // 💾 Save to file
      await externalFile.writeAsString(jsonData);

      print('✅ Session log saved to external storage: ${externalFile.path}');
    } catch (e) {
      print('❌ Failed to export session data: $e');
    }
  }
}
//doone changes