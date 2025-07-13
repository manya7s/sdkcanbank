import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportManager {
  Future<void> exportToJson(Map<String, dynamic> data, String baseFileName) async {
    try {
      final internalDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(":", "-");
      final fileName = '$baseFileName\_$timestamp.json';

      // Write to internal storage only
      final internalFile = File('${internalDir.path}/$fileName');
      final jsonData = const JsonEncoder.withIndent('  ').convert(data);
      await internalFile.writeAsString(jsonData);

      print('✅ Saved in internal app folder: ${internalFile.path}');
    } catch (e) {
      print('❌ Failed to export session data: $e');
    }
  }
}
