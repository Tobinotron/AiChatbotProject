import 'package:flutter/material.dart';
import 'package:webcrawler/ui/home_page.dart';
import 'package:webcrawler/apis/msg_database.dart' as db;
//import 'package:supabase/supabase.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:webcrawler/helpers/tflite_embed.dart';

//import 'dart:typed_data';
//import 'package:tflite_flutter/tflite_flutter.dart';

void main() async {
  // Initialize Database
  await db.initDb();
  // Run App
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.green[700], // Set default AppBar color
        ),
      ),
      home: HomePage(),
    );
  }
}

/*
void main() async {
  // Load the TFLite model
  final interpreter = await Interpreter.fromAsset('assets/USE.tflite');

  // Allocate tensors
  final inputShape = interpreter.getInputTensor(0).shape;
  final inputType = interpreter.getInputTensor(0).type;
  final outputShape = interpreter.getOutputTensor(0).shape;
  final outputType = interpreter.getOutputTensor(0).type;

  print('Input shape: $inputShape, type: $inputType');
  print('Output shape: $outputShape, type: $outputType');

  // Example input sentence
  final sentence = "This is a test sentence.";

  // Preprocess sentence (ensure input matches expected tensor shape)
  // Note: Adjust this depending on your model's expected input format
  final input = preprocess(sentence);

  // Allocate input and output buffers
  var output = List.filled(outputShape[1], 0.0).reshape([1, outputShape[1]]);

  // Run inference
  interpreter.run(input, output);

  // Retrieve embeddings
  print("Sentence Embedding: $output");

  // Close the interpreter
  interpreter.close();
}

/// Preprocesses the input sentence to match the model's requirements.
/// Modify this based on your model's documentation (e.g., tokenization, padding).
Uint8List preprocess(String sentence) {
  // Assuming the model expects UTF-8 encoded strings
  // Check your model documentation for preprocessing requirements.
  return Uint8List.fromList(sentence.codeUnits);
}*/



