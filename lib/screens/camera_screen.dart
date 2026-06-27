import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/sign_language_model.dart';
import '../utils/image_converter.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;

  // ML Model
  final SignLanguageModel _mlModel = SignLanguageModel();

  String _resultText = "মডেল লোড হচ্ছে...";
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _setupApp();
  }

  Future<void> _setupApp() async {
    await _mlModel.loadModel();

    setState(() {
      _resultText = "ইশারা দেখান (ক্যামেরা প্রস্তুত)";
    });

    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();

    if (status.isGranted) {
      _initCamera();
    } else {
      setState(() {
        _resultText = "Camera Permission Denied!";
      });
    }
  }

  void _initCamera() {
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );

    _controller!.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      // লাইভ ক্যামেরা ফ্রেম পড়া শুরু
      _controller!.startImageStream((CameraImage image) {
        if (_isDetecting) return;

        _isDetecting = true;

        try {
          // CameraImage → RGB Image
          final convertedImage =
              ImageConverter.convertCameraImage(image);

          // ML Prediction
          final String output =
              _mlModel.predict(convertedImage);

          if (mounted) {
            setState(() {
              _resultText = output;
            });
          }
        } catch (e) {
          debugPrint("Frame processing error: $e");
        } finally {
          // CPU লোড কমানোর জন্য সামান্য বিরতি
          Future.delayed(const Duration(milliseconds: 500), () {
            _isDetecting = false;
          });
        }
      });
    }).catchError((e) {
      debugPrint("Camera Error: $e");
    });
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _mlModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          "Live Translator",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: _isInitialized
          ? Stack(
              children: [

                // ফুলস্ক্রিন ক্যামেরা
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(_controller!),
                ),

                // উপরের গ্রেডিয়েন্ট
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Result Card
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Text(
                          "অনুবাদ ফলাফল",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _resultText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}