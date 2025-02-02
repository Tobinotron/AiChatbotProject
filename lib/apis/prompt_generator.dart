import 'dart:convert'; // For JSON encoding and decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'msg_database.dart' as db; // The database
import 'package:webcrawler/apis/keys/keys.dart' show openrouterKey;


// The URL for the API endpoint
const String url = "https://openrouter.ai/api/v1/chat/completions";

// Prompting Options
const String prePrompt = "Du bist ein Gesprächsteilnehmer auf WhatsApp. Antworte im selben Stil wie folgende Nachrichten: \n";

const String middlePrompt = "\nFühre folgende Konversation fort:";

const String finalPrompt = """Du bist in den Konversationen 'bot', dein gegenüber ist 'user'. Wiederhole nicht, was User sagt sondern führe eine echte 
Konversation. Hier ist eine kurze Beschreibung wer du bist:""";

const String lengthPrompt = "\nDeine Nachricht sollte so lange sein: ";

String descPrompt = """Du bist Gesprächsteilnehmer auf Whatsapp. Ich schicke dir nun eine Liste an Nachrichten von einer Person zu einer anderen Person. 
Verfasse bitte eine Anleitung in Form von Anweisungen, wie ein Chatbot so wie diese Person schreiben kann (Im Sinne von: Du verwendest oft Wort XY, Du beendest 
deine Sätze oft ..., etc.) Integriere ebenfalls eine Einschätzung, wie du denkst dass diese Person zu der anderen Steht (Verwandter, Freund, etc.). Verfasse 
diese Liste als unformatierter Text. Orientiere dich an diesen Nachrichten:\n""";


const String model = "liquid/lfm-40b:free";

/*
  Prepares the message to be sent to the server and then calls sendToServer(...).
  Input:
    - String resources    : The RAG messages similar to question
    - String question     : The question that was asked
    - String length       : The desired length of the answer
    - List<Map<String, String>> messageHistory : The history of messages in this chat
    - String description  : The character description of the person
  Returns:
    - Future<String> resonse  : The response of the LLM
*/
Future<String> generateResponse(String resources, String question, String length, List<Map<String, String>> messageHistory, String description) async {

  String message = prePrompt + resources + middlePrompt + question + finalPrompt + description + lengthPrompt + length;
  //String model = "meta-llama/llama-3.1-70b-instruct:free";

  List<Map<String, String>> msgToSend = messageHistory + [{"role": "user", "content": message}];
  return await sendToServer(msgToSend, model);
}

/*
  Sends a message to the server with the necessary information.
  Input:
    - List<Map<String, String>> message : The message that was built before
    - String model : The model the response should be generated with
  Returns:
    - Future<String> response  : The response of the LLM
*/
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
    "Authorization": "Bearer $openrouterKey",
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

/*
  Receives the LLM response, cleans it and converts it to a String
  Input:
    - String responseBody : The response of the LLM as a JSON
  Returns:
    - String response     : The response of the LLM as a String
*/
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

/*
  Asks a LLM to write a Prompt inspired by a given Persons chat messages
  Input:
    - String person : The person that should be described
  Returns:
    - Future<String> description : The description of said person
*/
Future<String> generateDescription(String person) async {
  String messages = await db.fetchAllRAGMessages(person);
  List<Map<String, String>> msgToSend = [{"role": "user", "content": descPrompt + messages}];
  
  return await sendToServer(msgToSend, model);
}
