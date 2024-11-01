import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'dart:collection';

import 'package:webcrawler/database.dart' as database;

Set<String> visitedUrls = {}; // Set zum Speichern der besuchten URLs
Queue<String> urlQueue = Queue(); // Warteschlange für URLs

// Regulärer Ausdruck für URLs, die mit "https://orf.at/stories/" gefolgt von einer Ziffer beginnen
final RegExp storiesUrlPattern = RegExp(r'^https://orf.at/stories/\d+/?$');

Future<void> crawlWebsite(String url) async {
  try {
    // HTTP-Anfrage an die Webseite senden
    var response = await http.get(Uri.parse(url));

    // Überprüfen, ob die Anfrage erfolgreich war
    if (response.statusCode == 200) {
      // HTML-Dokument parsen
      var document = parse(response.body);

      // Alle Links auf der Seite extrahieren
      List<Element> links = document.querySelectorAll('a');

      // Links verarbeiten
      for (var link in links) {
        var href = link.attributes['href'];
        if (href != null) {
          // Absolute URLs erstellen, falls notwendig
          var absoluteUrl = href.startsWith('http') ? href : Uri.parse(url).resolve(href).toString();

          // Nur URLs, die dem Pattern "https://orf.at/stories/" gefolgt von einer Ziffer entsprechen, ausgeben
          if (storiesUrlPattern.hasMatch(absoluteUrl)) {
            print(absoluteUrl);
            // Process Article and add to Article List
            database.addProcessedArticleToList(await fetchAndExtract(absoluteUrl));
          }

          // URLs zur Warteschlange hinzufügen, wenn sie noch nicht besucht wurden und mit "https://orf.at" beginnen
          if (absoluteUrl.startsWith('https://orf.at') && !visitedUrls.contains(absoluteUrl)) {
            urlQueue.add(absoluteUrl);
          }
        }
      }
    } else {
      print('Fehler: ${response.statusCode}');
    }
  } catch (e) {
    print('Fehler beim Abrufen der Webseite: $e');
  }
}

Future<void> startCrawl(String startUrl) async {
  // Start-URL zur Warteschlange hinzufügen
  urlQueue.add(startUrl);

  // Solange es noch URLs in der Warteschlange gibt, crawlen
  while (urlQueue.isNotEmpty) {
    var currentUrl = urlQueue.removeFirst();

    // Wenn die URL noch nicht besucht wurde, crawlen
    if (!visitedUrls.contains(currentUrl)) {
      visitedUrls.add(currentUrl);
      print('Crawling: $currentUrl');
      await crawlWebsite(currentUrl);
    }
  }
}

Future<String> fetchUrlContent(String url) async {
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return 'Error: Unable to fetch content';
    }
  } catch (e) {
    return 'Error: Exception occurred while fetching content';
  }
}


Map<String, dynamic> extractArticleData(String html, String url) {
  var document = parse(html);
  
  // Extrahiere den Titel
  var titelTag = document.querySelector('title');
  String titel = titelTag != null ? titelTag.text : "";
  
  // Extrahiere die Zusammenfassung
  var metaDescription = document.querySelector('meta[name="description"]');
  String zusammenfassung = metaDescription != null ? metaDescription.attributes['content'] ?? "" : "";
  
  // Extrahiere den Inhalt
  var contentDiv = document.querySelector('#ss-storyContent');
  String content = "";
  if (contentDiv != null) {
    var paragraphs = contentDiv.querySelectorAll('p');
    content = paragraphs.map((p) => p.text).join("\n");
  }

  if(zusammenfassung.length < 10) {
    zusammenfassung = getFirst30Words(content);
  }

  List<String> wordlist = database.summaryToList(zusammenfassung);
  
  return {
    'titel': titel,
    'zusammenfassung': zusammenfassung,
    'content': content,
    'url' : url,
    'wordlist' : wordlist
  };
}

Future<Map<String, dynamic>> fetchAndExtract(String url) async {
  Future<String> articleDataFuture = fetchUrlContent(url);
  String articleData = await articleDataFuture;
  Map<String, dynamic> extractedData = extractArticleData(articleData, url);
  
  return extractedData;
}

String getFirst30Words(String input) {
  // Split the string by whitespace (including multiple spaces and newlines)
  List<String> words = input.split(RegExp(r'\s+'));

  // Take the first 30 words or fewer if the string has less than 30 words
  List<String> first30Words = words.take(30).toList();

  // Join the words back into a string
  return first30Words.join(' ');
}

//Future<void> processArticle(String url, String filePath) async {
//  Map<String, String> article = await fetchAndExtract(url);
//  
//}

void main() async {
  database.initializeStopwords('E:/Webcrawler/webcrawler/export_data/stopwords-de.json');
  //Die Start-URL der Webseite, die gecrawlt werden soll
  var startUrl = 'https://orf.at';
  await startCrawl(startUrl);

  database.writeProcessedArticlesToJson('E:/Webcrawler/webcrawler/export_data/crawled_crawl.json');

}
/*
void main() async {
  var url = 'https://orf.at/stories/3373577/'; // Example URL
  database.initializeStopwords('E:/Webcrawler/webcrawler/export_data/stopwords-de.json');
  Map<String, dynamic> articleData = await fetchAndExtract(url);
  
  print('Titel: ${articleData['titel']}');
  print('Zusammenfassung: ${articleData['zusammenfassung']}');
  print('Inhalt: ${articleData['content']}');
  print('URL: ${articleData['url']}');
  print('Wordlist: ${articleData['wordlist']}');
}*/

/*
void main() async{
  List<Map<String, dynamic>> articleList = await database.readProcessedArticlesFromJson('E:/Webcrawler/webcrawler/export_data/crawled_crawl.json');

  print(articleList);
}*/