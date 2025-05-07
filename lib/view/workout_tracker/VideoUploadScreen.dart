import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadVideoScreen extends StatefulWidget {
  @override
  _UploadVideoScreenState createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  XFile? _video;
  VideoPlayerController? _controller;

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      print("Storage permission denied");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission is required to upload the video.")),
      );
    } else if (status.isPermanentlyDenied) {
      print("Storage permission permanently denied");
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = pickedFile;
        _controller = VideoPlayerController.file(File(pickedFile.path))
          ..initialize().then((_) => setState(() {}));
      });
    }
  }

  Future<void> uploadVideo() async {
    if (_video == null) return;

    var uri = Uri.parse("http://192.168.1.22:5000/process-video");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('video', _video!.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Video processed successfully');
    } else {
      print('Upload failed: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Video")),
      body: Column(
        children: [
          ElevatedButton(onPressed: pickVideo, child: Text("Pick Video")),
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ElevatedButton(onPressed: uploadVideo, child: Text("Upload to Flask")),
        ],
      ),
    );
  }
}
