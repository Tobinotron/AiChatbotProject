import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:webcrawler/apis/keys/keys.dart' show geminiKey;

// The model that will do the embedding
final model = GenerativeModel(
  model: 'embedding-001',
  apiKey: geminiKey);

/*
  Generates the embedding of a specific String.
  Input:
    - String text : The text to be embedded as a vector
  Returns:
    - Future<List<double>> embedding : A 768-dimensional vector representation
                                       of the input String
*/
Future<List<double>> generateEmbedding(String text) async {
  final content = Content.text(text);

  // Standard return value dimensions: 768-Value-Vector
  final response = await model.embedContent(content);

  return(response.embedding.values);
}


