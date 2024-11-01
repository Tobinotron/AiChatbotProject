import 'package:text_analysis/text_analysis.dart' as ta;
import 'package:webcrawler/database.dart' as database;

Map<String, double> globalWordRarity = {};

double compareWordLists(List<String> inputWords, List<String> listWords) {
  double similaritySum = 0.0;
  for(String word in inputWords) {
    for(String word2 in listWords) {
      //similaritySum += ta.TermSimilarity(word, word2).startsWithSimilarity;
      similaritySum += ta.TermSimilarity(word, word2).similarity;
    }
  }
  return similaritySum;
}

List<String> getHighestMatchingArticles(String input, List<Map<String, dynamic>> articles, int x) {
  // Convert input string to a list of words using summaryToList
  List<String> inputWords = database.summaryToList(input);
  
  // List to store articles with their similarity scores
  List<Map<String, dynamic>> scoredArticles = [];

  for (Map<String, dynamic> article in articles) {
    // Get the word list and URL from the current article
    List<String> articleWords = List<String>.from(article['wordlist']);
    String url = article['url'];
    
    // Calculate similarity between input words and article words
    double similarity = compareWordLists(inputWords, articleWords) / articleWords.length;
    
    // Add article URL and similarity score to scoredArticles
    scoredArticles.add({'url': url, 'similarity': similarity});
  }

  // Sort scoredArticles by similarity in descending order
  scoredArticles.sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));
  
  // Use a Set to store unique URLs and filter out duplicates
  Set<String> uniqueUrls = {};
  List<String> topUrls = [];
  
  for (var article in scoredArticles) {
    String url = article['url'] as String;
    
    // Add the URL if it hasn't been added already, and stop when we reach 'x' unique URLs
    if (uniqueUrls.add(url)) {
      topUrls.add(url);
      if (topUrls.length == x) break;
    }
  }

  return topUrls;
}

void calculateGlobalWordRarity(List<Map<String, dynamic>> articles) {
  // Initialize a map to store word frequencies
  Map<String, double> wordFrequencyMap = {};

  // Step 1: Count occurrences of each word in all articles
  for (var article in articles) {
    List<String> wordlist = List<String>.from(article['wordlist']);
    
    for (var word in wordlist) {
      // Increment the count for each word
      wordFrequencyMap[word] = (wordFrequencyMap[word] ?? 0) + 1;
    }
  }

  // Step 2: Convert frequency to rarity by replacing count with 1 / count
  wordFrequencyMap.updateAll((word, count) => 1 / count);
  globalWordRarity = wordFrequencyMap;
}

Future<String> getHighestMatchingArticlesAsString(String input) async {
  var buffer = StringBuffer();
  List<String> matchingArticles = getHighestMatchingArticles(input, database.processedArticles, 5);
  for(String url in matchingArticles) {
    for (Map<String, dynamic> article in database.processedArticles) {
      if (article['url'] == url) {
        buffer.write(article['content']);
        buffer.write("\n");
      }
    }
  }
  return buffer.toString();
}


void main(List<String> args) async {
  String input = "Was ist letzte Woche in Italien passiert?";
  List<Map<String, dynamic>> articles = await database.readProcessedArticlesFromJson('E:/Webcrawler/webcrawler/export_data/crawled_crawl.json');
  print(getHighestMatchingArticles(input, articles , 5));
  //calculateGlobalWordRarity(articles);
  //print(globalWordRarity);
}