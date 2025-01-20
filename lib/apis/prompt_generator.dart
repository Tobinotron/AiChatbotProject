import 'dart:convert'; // For JSON encoding and decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'msg_database.dart' as db;

// Set your API key here
const String apiKey = "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";

// The URL for the API endpoint
const String url = "https://openrouter.ai/api/v1/chat/completions";

// Pre-Prompt Options
const String prePrompt = "Du bist ein Gesprächsteilnehmer auf WhatsApp. Antworte im selben Stil wie folgende Nachrichten: \n";

const String middlePrompt = "\nFühre folgende Konversation fort:";

const String finalPrompt = "Du bist in den Konversationen 'bot', dein gegenüber ist 'user'. Wiederhole nicht, was User sagt sondern führe eine echte Konversation. Hier ist eine kurze Beschreibung wer du bist:";

const String lengthPrompt = "\nDeine Nachricht sollte so lange sein: ";

// Send the message to the server with character information
Future<String> generateResponse(String resources, String question, String length, List<Map<String, String>> messageHistory, String description) async {

  String message = prePrompt + resources + middlePrompt + question + finalPrompt + description + lengthPrompt + length;
  String model = "liquid/lfm-40b:free";
  //String model = "meta-llama/llama-3.1-70b-instruct:free";

  List<Map<String, String>> msgToSend = messageHistory + [{"role": "user", "content": message}];
  return await sendToServer(msgToSend, model);
}

// Function to send the message to the server
Future<String> sendToServer(List<Map<String, String>> message, String model) async {
  
  // Create the data to send
  Map<String, dynamic> requestData = {
    "model": model,
    "messages": message
  };

  // Convert the data to JSON format
  String jsonData = json.encode(requestData);

  // Set the headers, including authorization with your API key
  Map<String, String> headers = {
    "Authorization": "Bearer $apiKey",
    "Content-Type": "application/json"
  };

  // Make the POST request to the API
  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: jsonData);
    if (response.statusCode == 200) {
      // Handle successful response
      return _handleResponse(response.body);
    } else {
      // Handle error response
      return "HTTP Request failed with code: ${response.statusCode}";
    }
  } catch (e) {
    return "Error making HTTP request: $e";
  }
}

// Function to handle the response once the request is completed
String _handleResponse(String responseBody) {
  // Parse the response JSON
  Map<String, dynamic> responseDict = json.decode(responseBody);

  if (responseDict.containsKey("choices")) {
    String content = responseDict["choices"][0]["message"]["content"];
    // Pass the response to the parent or handle it in the app
    return content;
    // You can send this to your ChatScene or UI accordingly
  } else {
    return "ERROR";
  }
}

String descPrompt = "Du bist Gesprächsteilnehmer auf Whatsapp. Ich schicke dir nun eine Liste an Nachrichten von einer Person zu einer anderen Person. Verfasse bitte eine Anleitung in Form von Anweisungen, wie ein Chatbot so wie diese Person schreiben kann (Im Sinne von: Du verwendest oft Wort XY, Du beendest deine Sätze oft ..., etc.) Integriere ebenfalls eine Einschätzung, wie du denkst dass diese Person zu der anderen Steht (Verwandter, Freund, etc.). Verfasse diese Liste als unformatierter Text. Orientiere dich an diesen Nachrichten:\n";

Future<String> generateDescription(String person) async {
  String messages = await db.fetchAllRAGMessages(person);
  String model = "liquid/lfm-40b:free";
  List<Map<String, String>> msgToSend = [{"role": "user", "content": descPrompt + messages}];
  
  return await sendToServer(msgToSend, model);
}
