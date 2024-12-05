import 'package:google_generative_ai/google_generative_ai.dart';

const String apiKey = 'AIzaSyCw8VrEb65qZuB9hdsyTJVR9amLYhBsHAI';

final model = GenerativeModel(
  model: 'embedding-001',
  apiKey: apiKey);

Future<List<double>> generateText(String prompt) async {
  final content = Content.text(prompt);
  //final response = await model.embedContent(content, outputDimensionality: 100);

  // Standard eeturn value dimensions: 768-Value-Vector
  final response = await model.embedContent(content);

  return(response.embedding.values);
}

//void main(List<String> args) {
//}
