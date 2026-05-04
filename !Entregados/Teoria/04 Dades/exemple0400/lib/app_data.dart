import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class AppData extends ChangeNotifier {
  String _jsonContent = '';
  bool _fileLoading = false;
  bool _fileSaving = false;
  String? _loadedFilePath;
  final TextEditingController jsonController = TextEditingController();

  String get jsonContent => _jsonContent;
  bool get fileLoading => _fileLoading;
  bool get fileSaving => _fileSaving;
  bool get fileLoaded => _loadedFilePath != null;

  Future<void> loadFile(String path) async {
    _fileLoading = true;
    notifyListeners();

    try {
      final file = File(path);
      if (kDebugMode) {
        print("Trying to read file from: ${file.path}");
      }
      if (await file.exists()) {
        _jsonContent = await file.readAsString();
        jsonController.text = _jsonContent;
        _loadedFilePath = path; // Guarda el camí del fitxer carregat
      } else {
        _jsonContent = '{}';
        if (kDebugMode) {
          print("File does not exist!");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error reading file: $e");
      }
    } finally {
      _fileLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveFile(String path) async {
    _fileSaving = true;
    notifyListeners();

    try {
      final file = File(path);
      final jsonData = const JsonEncoder.withIndent('  ').convert(jsonDecode(
          jsonController
              .text)); // Utilitza el text del controlador i el formateja
      await file.writeAsString(jsonData);
      _loadedFilePath = path; // Actualitza el camí del fitxer guardat
    } catch (e) {
      if (kDebugMode) {
        print("Error saving file: $e");
      }
    } finally {
      _fileSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveLoadedFile() async {
    if (_loadedFilePath != null) {
      await saveFile(_loadedFilePath!);
    }
  }

  Future<String> getDefaultDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> loadFileWithPicker() async {
    try {
      String defaultDirectory = await getDefaultDirectoryPath();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        initialDirectory: defaultDirectory,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          await loadFile(filePath);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking file: $e");
      }
    }
  }

  Future<void> saveFileWithPicker() async {
    try {
      String defaultDirectory = await getDefaultDirectoryPath();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        initialDirectory: defaultDirectory,
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Please select a location to save the file',
      );

      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          await saveFile(filePath);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking file: $e");
      }
    }
  }
}
