import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;

class SignLanguageModel {
  Interpreter? _interpreter;
  List<String>? _labels;

  // মডেল এবং লেবেল লোড করা
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      String labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n').where((element) => element.isNotEmpty).toList();
      print('✅ Model and labels loaded successfully');
    } catch (e) {
      print('❌ Error loading model: $e');
    }
  }

  // প্রেডিকশন লজিক
  String predict(imglib.Image image) {
    if (_interpreter == null || _labels == null) return "Model not ready";

    // ১. ইমেজ রিসাইজ করা (বেশিরভাগ Kaggle মডেল 224x224 বা 64x64 সাইজের ইমেজ ইনপুট নেয়)
    // যদি আপনার মডেলে সাইজ এরর দেয়, তবে 224 এর বদলে 64 বা 128 বসিয়ে ট্রাই করবেন।
    imglib.Image resizedImage = imglib.copyResize(image, width: 224, height: 224);

    // ২. ইমেজকে ম্যাট্রিক্সে রূপান্তর করা (Normalization)
    var input = List.generate(1, (i) => 
                  List.generate(224, (y) => 
                    List.generate(224, (x) => List.filled(3, 0.0))
                  )
                );

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        var pixel = resizedImage.getPixel(x, y);
        // কালার ভ্যালু (0-255) কে (0.0-1.0) তে কনভার্ট করা হচ্ছে
        input[0][y][x][0] = pixel.r / 255.0; // Red
        input[0][y][x][1] = pixel.g / 255.0; // Green
        input[0][y][x][2] = pixel.b / 255.0; // Blue
      }
    }

    // ৩. আউটপুট ভেরিয়েবল তৈরি করা (যতগুলো লেবেল, ততগুলো আউটপুট ভ্যালু)
    var output = List.filled(1, List.filled(_labels!.length, 0.0));

    // ৪. মডেল রান করা
    try {
      _interpreter!.run(input, output);
    } catch (e) {
      print("Interpreter run error: $e");
      return "Processing...";
    }

    // ৫. সবচেয়ে বেশি সম্ভাবনাময় (Highest Probability) ফলাফলটি খুঁজে বের করা
    double maxScore = 0.0;
    int maxIndex = 0;
    
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxScore) {
        maxScore = output[0][i];
        maxIndex = i;
      }
    }

    // যদি কনফিডেন্স ৫০% এর বেশি হয়, তবেই টেক্সট দেখাবে
    if (maxScore > 0.50) {
      return "ইশারা: ${_labels![maxIndex]} ${(maxScore * 100).toStringAsFixed(1)}%";
    } else {
      return "বুঝতে পারছি না...";
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}