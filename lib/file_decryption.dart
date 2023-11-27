import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as enc;

class DecryptFolder extends StatefulWidget {
  const DecryptFolder({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<DecryptFolder> createState() => _DecryptFolderState();
}

class _DecryptFolderState extends State<DecryptFolder> {
  late String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the DecryptFolder object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          backgroundColor: Colors.blue,
        ),
        body: SafeArea(child: _decryptFile()));
  }

  Widget _decryptFile() {
    return Center(
      child: MaterialButton(
          color: Colors.blue,
          child: const Text(" Decrypt Folder",
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          onPressed: () async {
            initiateDecrypt(
                '/data/data/com.example.flutter_poc_examples/files/encrypted/152016'); // app directory path of encrypted folder or file
          }),
    );
  }

  initiateDecrypt(directoryPath) async {
    var dir = Directory(directoryPath);
    createDirectory(directoryPath);
    final List<FileSystemEntity> entities = await dir.list().toList();
    iterateToCheckDir(entities);
  }

  iterateToCheckDir(filesList) {
    for (final file in filesList) {
      if (file is Directory) {
        initiateDecrypt(file.path.toString());
      } else {
        var fileName = getFileName(file.path.toString());
        decryptFile(file.path.toString(), fileName);
      }
    }
  }

  decryptFile(filePath, fileName) async {
    Uint8List encData = await _readData(filePath);
    var plainData = await _decryptData(encData);
    String p = await _writeData(
        plainData, filePath, fileName); // + '/$fileName DecryptedDat'
    print("file decrypted successfully in path $p");
  }

  String? getFileName(String fileName) {
    try {
      return fileName.substring(fileName.lastIndexOf('/') + 1);
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List> _readData(path) async {
    print("Reading data in progress");
    File file = File(path);
    return await file.readAsBytes();
  }

  _decryptData(encData) {
    print("File decryption in progress");
    enc.Encrypted encrypted = enc.Encrypted(encData);
    return MyEncrypt.myCryptor.decryptBytes(encrypted, iv: MyEncrypt.myIv);
  }

  Future<String> _writeData(dataToWrite, path, fileName) async {
    print("Writting data....");
    var appendPath = path.replaceAll(
        "data/data/com.example.flutter_poc_examples/files/encrypted/", "");
    appendPath =
        'data/data/com.example.flutter_poc_examples/files/decrypted/$appendPath'; // path of decrypted folder or file
    print("save file path $appendPath");

    File file = File(appendPath);

    await file.writeAsBytes(dataToWrite);
    return file.absolute.toString();
  }

  createDirectory(dirPath) {
    var appendPath = dirPath.replaceAll("encrypted", "decrypted");
    Directory(appendPath).create(recursive: true);
  }
}

class MyEncrypt {
  static final myKey =
      enc.Key.fromBase64('FgQb914mNIlnCept2LaaNQ=='); // Encryption Key
  static final myIv =
      enc.IV.fromUtf8('4fLvTX%&B^NeYSa*'); // Initialization Vector
  static final myCryptor =
      enc.Encrypter(enc.AES(myKey, mode: enc.AESMode.cbc, padding: null));
}
