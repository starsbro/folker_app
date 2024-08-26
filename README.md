1. Run the API
Start the service using uvicorn:
'''
uvicorn api:app --reload
'''
This service will run at http://127.0.0.1:8000, and the Flutter app can call the /predict/ endpoint to make requests.

2. Flutter Calls REST API
Example: Flutter Code to Call API
'''
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> getMask(String imagePath, int x, int y) async {
  var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/predict/'));
  
  request.files.add(await http.MultipartFile.fromPath('file', imagePath));
  request.fields['x'] = x.toString();
  request.fields['y'] = y.toString();

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await http.Response.fromStream(response);
    var decodedData = jsonDecode(responseData.body);
    var mask = decodedData['mask'];
    // Process the mask data, e.g., display it in the UI
  } else {
    print('Failed to get mask');
  }
}
'''

3. Passing and Displaying the Mask
Passing: The Flutter app sends the image and coordinate points to your API, and the API returns the corresponding mask data.
Displaying: Flutter parses the returned mask data and uses Canvas or CustomPainter to display the mask on the image.

In Flutter, calling a REST API involves the following steps:
1. Add Dependencies Add the http dependency to your Flutter project's pubspec.yaml file to handle HTTP requests.
'''
dependencies:
  flutter:
    sdk: flutter
  http: ^0.14.0
'''
Then run flutter pub get to install the dependencies.

2. Import the http Package Import the http package in your Dart file.
'''
import 'package:http/http.dart' as http;
import 'dart:convert';
'''

3. Write the API Call Function Write a function to call your REST API. Here’s an example that uploads an image and sends coordinate information to the API, then retrieves the mask data from the response.
'''
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> getMask(String imagePath, int x, int y) async {
  try {
    // Create a POST request
    var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/predict/'));
    
    // Add the image file
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    
    // Add coordinate points
    request.fields['x'] = x.toString();
    request.fields['y'] = y.toString();

    // Send the request
    var response = await request.send();

    // Process the response
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var decodedData = jsonDecode(responseData.body);
      var mask = decodedData['mask'];
      
      // Process mask data, e.g., display it in the UI
      print("Mask data: $mask");
    } else {
      print('Failed to get mask');
    }
  } catch (e) {
    print('Error: $e');
  }
}
'''

4. Call the Function In your Flutter app, call the getMask function and pass the image path and coordinates.
'''
void main() {
  String imagePath = 'path_to_your_image/image.jpg';  // Replace with the path to your image
  int x = 500;  // Replace with your coordinate
  int y = 300;

  getMask(imagePath, x, y);
}
'''

5. Display Mask Data To display the mask data in the Flutter UI, you can use CustomPainter or Canvas. The exact method will depend on how you want to visualize the mask data.

6. Testing and Debugging Make sure to start the FastAPI service locally (using uvicorn api:app --reload) and test the API calls using Postman or another tool to ensure it works correctly before integrating it into Flutter.

Note: Ensure that the API address (e.g., http://127.0.0.1:8000) is accessible from the Flutter app. If running on an emulator, you might need to use 10.0.2.2 instead of 127.0.0.1. When deploying to production, deploy the API to a remote server and use the remote server's address in the Flutter app.
