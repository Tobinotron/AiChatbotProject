import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:webcrawler/apis/keys/keys.dart' show geminiKey;

// The model that will do the embedding
final model = GenerativeModel(
  model: 'embedding-001',
  apiKey: geminiKey);

Future<List<double>> generateEmbedding(String prompt) async {
  final content = Content.text(prompt);
  //final response = await model.embedContent(content, outputDimensionality: 100);

  // Standard eeturn value dimensions: 768-Value-Vector
  final response = await model.embedContent(content);

  return(response.embedding.values);
}