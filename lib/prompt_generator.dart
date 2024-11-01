import 'dart:convert'; // For JSON encoding and decoding
import 'package:http/http.dart' as http; // For making HTTP requests


// Set your API key here
const String apiKey = "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";

// The URL for the API endpoint
const String url = "https://openrouter.ai/api/v1/chat/completions";

// Pre-Prompt Options
const String prePrompt = "Du bist ein Nachrichtendienst. Gebe nur Fakten zurück, die du aus Folgenden Resourcen erhältst: \n";

const String middlePrompt = "\nAuf folgende Frage solltest du antworten:";

// Send the message to the server with character information
Future<String> generateResponse(String resources, String question) async {

  String message = prePrompt + resources + middlePrompt + question;
  String model = "liquid/lfm-40b:free";

  return await sendToServer(message, model);
}

// Function to send the message to the server
Future<String> sendToServer(String message, String model) async {
  // Create the data to send
  Map<String, dynamic> requestData = {
    "model": model,
    "messages": [
      {"role": "user", "content": message}
    ]
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
