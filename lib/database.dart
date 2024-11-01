import 'dart:io';
import 'dart:convert';

//List<Map<String, String>> processedArticles = [];
List<Map<String, dynamic>> processedArticles = [];
List<String> stopwords = [];
//const English analyzer = English.new();

void addProcessedArticleToList(Map<String, dynamic> article) {
  processedArticles.add(article);
}

List<String> summaryToList(String summary) {
  if (stopwords.isEmpty) {
    initializeStopwords('E:/Webcrawler/webcrawler/export_data/stopwords-de.json');
  }
  List<String> words = [];
  List<String> filteredWords = [];
  summary = summary.replaceAll(RegExp(r'[^\w\säöüß]+'), ' ')
                   .replaceAll(RegExp(r'\s+'), ' ')
                   .trim();
  words = summary.toLowerCase().split(RegExp(r'\s+'));

  // to remove duplicates
  //words = words.toSet().toList();

  // delete non-words and Stopwords
  for(String word in words) {
    if (RegExp(r'^[a-zäöüß]+$', caseSensitive: false, unicode: true).hasMatch(word) && word.length > 1 && !isStopword(word, stopwords)) {
      filteredWords.add(word);
    }
  }
  
  return filteredWords;
}

// Binary search function to check if a word is in the stopwords list
bool isStopword(String word, List<String> stopwords) {
  int low = 0;
  int high = stopwords.length - 1;
  
  while (low <= high) {
    int mid = low + ((high - low) ~/ 2);
    if (stopwords[mid] == word) {
      return true; // The word is a stopword
    } else if (stopwords[mid].compareTo(word) < 0) {
      low = mid + 1; // Search in the upper half
    } else {
      high = mid - 1; // Search in the lower half
    }
  }
  return false; // The word is not a stopword
}

// Function to initialize the list of stopwords from a given JSON file path
void initializeStopwords(String filePath) {
  // Read the file as a string
  String jsonStopwords = File(filePath).readAsStringSync();
  // Parse the JSON string to a List<String>
  stopwords = List<String>.from(jsonDecode(jsonStopwords));
}

// Method to read processed articles from a JSON file
Future<List<Map<String, dynamic>>> readProcessedArticlesFromJson(String filePath) async {
  List<Map<String, dynamic>> articleList = [];
  try {
    // Read the JSON file
    String jsonData = await File(filePath).readAsString();
    
    // Deserialize the JSON data into List<Map<String, dynamic>>
    List<dynamic> jsonList = jsonDecode(jsonData);
    
    // Iterate through the list and cast to Map<String, dynamic>
    for (var item in jsonList) {
      articleList.add(Map<String, dynamic>.from(item));
    }
    
    print('Processed articles loaded successfully.');
  } catch (e) {
    print('Error reading JSON file: $e');
  }
  return articleList;
}

// Method to write processed articles to a JSON file
Future<void> writeProcessedArticlesToJson(String filePath) async {
  try {
    // Serialize the processedArticles list to JSON
    String jsonData = jsonEncode(processedArticles);
    
    // Write the JSON data to the specified file
    await File(filePath).writeAsString(jsonData);
    
    print('Processed articles saved successfully.');
  } catch (e) {
    print('Error writing JSON file: $e');
  }
}

/*
void main() async {
  String description = '''Der bisherige Bundeskanzler und ÖVP-Chef Karl Nehammer hat den Auftrag von Bundespräsident  Alexander Van der Bellen zur Regierungsbildung angenommen. 
  Er wolle „hart dafür arbeiten, eine stabile, von einer breiten Mehrheit im Parlament getragene Bundesregierung“ zu bilden. Dafür werde es einen dritten Partner brauchen, 
  so Nehammer. SPÖ-Chef Andreas Babler zeigte sich offen für „konstruktive Gespräche''';

  String description2 = ''' Hallo Welt Fortnite Obamna ÖVP-Chef Karl Nehammer ''';

  initializeStopwords('E:/Webcrawler/webcrawler/export_data/stopwords-de.json');
}*/