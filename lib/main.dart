// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:ionicons/ionicons.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Processing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  Uint8List? _processedImage;
  // ignore: unused_field
  String _detectText = '';
  String funcProcess = '';

  Future _getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _processOcr() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/ocr'),
      // Uri.parse('https://2k718frb-3000.asse.devtunnels.ms//ocr'),
    );

    print('Process OCR');

    request.files.add(
      await http.MultipartFile.fromBytes(
        'photo',
        File(_image!.path).readAsBytesSync(),
        filename: 'uploaded_image.jpg',
      ),
    );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('OCR Berhasil');

        var responseData = await response.stream.toBytes();
        var responseText = utf8.decode(responseData);
        setState(() {
          _detectText = responseText;
        });
        // Tampilkan teks hasil (misalnya, dengan menggunakan snackbar)
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Deteksi Teks: $resultText'),
        //   ),
        // );
      } else {
        print(
            'Terjadi kesalahan ${response.statusCode} : ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Terjadi kesalahan catch : $error');
    }
  }

  void _bwImage() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/bw'),
      // Uri.parse('https://2k718frb-3000.asse.devtunnels.ms//bw'),
    );

    print('Process B&W');

    request.files.add(
      await http.MultipartFile.fromBytes(
        'photo',
        File(_image!.path).readAsBytesSync(),
        filename: 'uploaded_image.jpg',
      ),
    );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Gambar berhasil diproses');
        var responseImage = await response.stream.toBytes();
        setState(() {
          _processedImage = responseImage;
        });
      } else {
        print(
            'Terjadi kesalahan ${response.statusCode} : ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Terjadi kesalahan catch : $error');
    }
  }

  void _saveGallery() async {
    // try {
    //   final result = await ImageGallerySaver.saveImage(_processedImage!);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(result
    //           ? 'Gambar berhasil disimpan di galeri'
    //           : 'Gagal menyimpan gambar'),
    //     ),
    //   );
    // } catch (error) {
    //   print('Terjadi kesalahan: $error');
    // }

    //
    // save image for windows

    if (_processedImage == null) {
      print('Error: Gambar belum diproses atau tidak ada.');
      return;
    }

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      File file = File('$appDocPath/processed_image.jpg');
      await file.writeAsBytes(_processedImage!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gambar berhasil disimpan secara lokal di $appDocPath'),
        ),
      );
    } catch (error) {
      print('Terjadi kesalahan: $error');
    }
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _detectText));
    // Tampilkan snackbar sebagai umpan balik
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Teks berhasil disalin ke clipboard'),
      ),
    );
  }

  void _deleteImage() {
    setState(() {
      _image = null;
      funcProcess = '';
    });
  }

  void _resetImage() {
    setState(() {
      _processedImage = null;
      _detectText = '';
      funcProcess = '';
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Image Processing'),
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           if (_processedImage != null)
  //             Image.memory(
  //               _processedImage!, // Image.memory show image byte
  //               fit: BoxFit.cover,
  //               width: 300,
  //             )
  //           else
  //             _image == null
  //                 ? Text('Silahkan ambil gambar')
  //                 : Image.file(
  //                     _image!,
  //                     fit: BoxFit.cover,
  //                     width: 300,
  //                   ),
  //           SizedBox(height: 20),
  //           if (_image != null)
  //             Column(
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: _bwImage,
  //                   child: Text('Proses Gambar'),
  //                 ),
  //                 SizedBox(height: 20),
  //                 ElevatedButton(
  //                   onPressed: _resetImage,
  //                   child: Text('Reset Gambar'),
  //                 ),
  //               ],
  //             )
  //           else
  //             Column(
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: _getImageFromGallery,
  //                   child: Text('Galeri'),
  //                 ),
  //                 SizedBox(height: 20),
  //                 ElevatedButton(
  //                   onPressed: _getImageFromCamera,
  //                   child: Text('Kamera'),
  //                 ),
  //               ],
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSquareButton(
      IconData icon, String text, String label, String func) {
    return Expanded(
        child: AspectRatio(
            aspectRatio: 10 / 8,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        funcProcess == func ? Colors.purple : Color(0xFF0C0C0C),
                    width: 2),
                borderRadius: BorderRadius.circular(8.0),
                color: Color(0xFF0C0C0C),
              ),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (label != 'AI') {
                      funcProcess = func;
                    }
                  });
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (label == "AI")
                                  Container(
                                    padding: EdgeInsets.only(
                                        right: 5, left: 5, bottom: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade800,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      'Coming',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Icon(
                                icon,
                                size: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Icon(
                            Ionicons.arrow_forward_outline,
                            size: 22.0,
                            color: Colors.purple,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                // image: AssetImage("assets/bg.jpg"),
                image: AssetImage("assets/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: screenHeight * 0.10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Text(
                        'DETXT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 24.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade800,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'BETA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 24.0),
                child: Text(
                  'IMAGE CREATION',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.purple.shade300,
                      // fontWeight: FontWeight.w600,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                child: Text(
                  'Apps powered creativity',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 26.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                child: Text(
                  'enchancement',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 26.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _image != null || _processedImage != null
                  ? screenHeight * 0.9
                  : screenHeight * 0.55,
              padding: EdgeInsets.only(
                  top: 16.0, bottom: 65.0, right: 8.0, left: 8.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.0),
                  topRight: Radius.circular(28.0),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            Ionicons.flame,
                            color: Colors.purple.shade800,
                            size: 20.0,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            'TOOLS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: _image == null
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: <Widget>[
                          if (_image == null)
                            Text(
                              'Please Select Image',
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500),
                            ),
                          if (_image != null)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.fitWidth,
                                height: screenHeight * 0.20,
                              ),
                            ),
                          if (_processedImage != null && _detectText == '')
                            Column(
                              children: [
                                SizedBox(height: 20.0),
                                Align(
                                  alignment: AlignmentDirectional.center,
                                  child: Text(
                                    'Result Image',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Image.memory(
                                  _processedImage!,
                                  fit: BoxFit.fitWidth,
                                  height: screenHeight * 0.20,
                                ),
                              ],
                            ),
                          if (_detectText != '' && _processedImage == null)
                            Expanded(
                              child: ListView(
                                children: [
                                  SizedBox(height: 20.0),
                                  Align(
                                    alignment: AlignmentDirectional.center,
                                    child: Text(
                                      'Result Text',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    _detectText,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                          if (_image != null &&
                              _detectText == '' &&
                              _processedImage == null)
                            Expanded(
                                child: ListView(
                              children: [
                                SizedBox(height: 16.0),
                                Align(
                                  alignment: AlignmentDirectional.center,
                                  child: Text(
                                    'Select Tool',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSquareButton(Ionicons.text_outline,
                                        'Text Recognition', 'IMAGE', 'ocr'),
                                    _buildSquareButton(
                                        Ionicons.contrast_outline,
                                        'Black & White',
                                        'IMAGE',
                                        'bw'),
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSquareButton(Ionicons.scan, 'Expand',
                                        'AI', 'expand'),
                                    _buildSquareButton(Ionicons.color_wand,
                                        'Reimagine', 'AI', 'reimagine'),
                                  ],
                                ),
                              ],
                            )),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade700,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (_image == null && _processedImage == null)
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: IconButton(
                        icon: Icon(Ionicons.camera_outline),
                        color: Colors.white,
                        onPressed: _getImageFromCamera,
                      ),
                    ),
                  if (_image == null && _processedImage == null)
                    Expanded(
                      child: Container(
                        height: 48.0,
                        margin: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.purple.shade800,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: TextButton(
                          onPressed: _getImageFromGallery,
                          child: Text(
                            'Select from Gallery',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                  if (_image != null &&
                      (_processedImage == null && _detectText == ''))
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: IconButton(
                        icon: Icon(Ionicons.trash_outline),
                        color: Colors.white,
                        onPressed: _deleteImage,
                      ),
                    ),
                  if (_image != null &&
                      _processedImage == null &&
                      _detectText == '')
                    Expanded(
                      child: Container(
                        height: 48.0,
                        margin: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          // color: Colors.purple.shade800,
                          color: funcProcess != ''
                              ? Colors.purple.shade800
                              : Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (funcProcess == 'ocr') {
                              _processOcr();
                            } else if (funcProcess == 'bw') {
                              _bwImage();
                            }
                          },
                          child: Text(
                            'Process Image',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                  if (_image != null &&
                      (_detectText != '' || _processedImage != null))
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: IconButton(
                        icon: Icon(Ionicons.arrow_back_outline),
                        color: Colors.white,
                        onPressed: _resetImage,
                        iconSize: 20.0,
                      ),
                    ),
                  if (_image != null &&
                      _detectText == '' &&
                      _processedImage != null)
                    Expanded(
                      child: Container(
                        height: 48.0,
                        margin: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.purple.shade800,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: TextButton(
                          onPressed: _saveGallery,
                          child: Text(
                            'Save Image',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                  if (_detectText != '' && _processedImage == null)
                    Expanded(
                      child: Container(
                        height: 48.0,
                        margin: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.purple.shade800,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: TextButton(
                          onPressed: _copyText,
                          child: Text(
                            'Copy Text',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
