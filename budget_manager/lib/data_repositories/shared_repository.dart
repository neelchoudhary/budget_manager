const jsonHeader = {'Content-Type': 'application/json'};
const baseUri = 'http://localhost:8080';

const int delay = 250;

void responsePrint(int statusCode, String body) {
  print("Status Code: ${statusCode.toString()}. Body: $body");
}
