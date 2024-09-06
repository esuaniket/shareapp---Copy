import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

class VideoPickerAndSharePage extends StatefulWidget {
  @override
  _VideoPickerAndSharePageState createState() =>
      _VideoPickerAndSharePageState();
}

class _VideoPickerAndSharePageState extends State<VideoPickerAndSharePage> {
  File? _videoFile;
  VideoPlayerController? _videoController;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          }).catchError((error) {
            print('Error initializing video player: $error');
          });
      });
    }
  }

  Future<void> _shareVideo() async {
    if (_videoFile != null) {
      try {
        await Share.shareXFiles([XFile(_videoFile!.path)]);
      } catch (e) {
        print('Error sharing video: $e');
      }
    } else {
      print('No video file to share');
    }
  }

  Future<void> _shareVideoUrl(String videoUrl) async {
    try {
      await Share.share(videoUrl);
    } catch (e) {
      print('Error sharing video URL: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pick, Show, and Share Video'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_videoFile != null)
                _videoController != null &&
                        _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : CircularProgressIndicator()
              else
                Text('No video selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white),
                onPressed: _pickVideo,
                child: const Text('Pick Video'),
              ),
              const SizedBox(height: 20),
              if (_videoFile != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white),
                  onPressed: _shareVideo,
                  child: const Text('Share Video'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
