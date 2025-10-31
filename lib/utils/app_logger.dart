// --- 1. File Handling Class: Responsible for all Disk I/O ---
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LogFileWriter {
  // Use a singleton pattern to ensure consistent file access
  static final LogFileWriter _instance = LogFileWriter._internal();
  factory LogFileWriter() => _instance;
  LogFileWriter._internal();

  // The filename we will use in the application support directory
  static const _logFileName = 'alletre_app_debug_log.txt';

  // Gets the full file path in the application support directory
  Future<File> get _localFile async {
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    return File('$path/$_logFileName');
  }

  // METHOD 1: Appends a single, formatted log line to the file
  Future<void> appendLog(String logLine) async {
    try {
      final file = await _localFile;
      // Append the log line with a newline character for readability
      await file.writeAsString('$logLine\n', mode: FileMode.append);
    } catch (e) {
      // Print error to console if writing fails (avoiding log recursion)
      debugPrint('ERROR writing to log file: $e');
    }
  }

  // METHOD 2: Reads all content from the log file (for display/sharing)
  Future<String> readLogs() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return 'Log file does not exist yet. Generate some logs first!';
      }
      return await file.readAsString();
    } catch (e) {
      // If reading fails (e.g., file permissions issue)
      return 'Error reading log file: $e';
    }
  }

  // NEW METHOD: Shares the log file using the system share sheet
  Future<void> shareLogs() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        AppLogger.log.w('Attempted to share log file, but it does not exist.');
        return;
      }

      // Use the share_plus package to prompt the user to share the file
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Application Log File'));
    } catch (e) {
      AppLogger.log.e('Failed to share log file: $e');
    }
  }

  // Clears the log file
  Future<void> clearLogs() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.writeAsString('', mode: FileMode.write); // Overwrite with empty string
      }
    } catch (e) {
      debugPrint('ERROR clearing log file: $e');
    }
  }
}

// --- 2. Custom Logger Output Bridge: Connects 'logger' to 'LogFileWriter' ---
class FileLogOutput extends LogOutput {
  final LogFileWriter _writer = LogFileWriter();

  @override
  void output(OutputEvent event) {
    // The logger package provides the formatted log message in event.lines
    for (var line in event.lines) {
      // 1. Write the formatted log line to the file
      _writer.appendLog(line);

      // 2. OPTIONAL: Also print to console during DEBUG/DEVELOPMENT builds
      // This allows you to still see the logs in your IDE console
      debugPrint(line);
    }
  }
}

// --- 3. App Logger Configuration: Your central access point ---
class AppLogger {
  // This is the instance you will call: AppLogger.log.i('Your message')
  static final Logger log = Logger(
    // Use the default PrettyPrinter for formatting (timestamps, level names)
    printer: PrettyPrinter(
      methodCount: 0, // Reduces noise by not showing the calling method stack in the log file
      errorMethodCount: 5,
      lineLength: 80,
      colors: false, // Must be false for file writing
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Crucial: Ensures every line is timestamped
    ),
    // Crucial: Use the custom file writer output instead of the default ConsoleOutput
    output: FileLogOutput(),
    // Set the logging level to capture everything (Debug, Info, Warning, Error, Fatal)
    level: Level.debug,
  );
}
