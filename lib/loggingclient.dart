import 'package:http/http.dart';

class LoggingClient extends BaseClient {
  final Client _inner;

  LoggingClient(this._inner);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    if (request is Request) {
      print('sending ${request.url} with ${request.body}');
    } else {
      print('sending ${request.url}');
    }

    final response = await _inner.send(request);
    final read = await Response.fromStream(response);

    print('response:\n${read.body}');

    return StreamedResponse(
        Stream.fromIterable([read.bodyBytes]), response.statusCode);
  }
}