import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

//Run local server at localhost:8080
Future<Stream<String>> _server() async {
  final StreamController<String> onCode = new StreamController();
  HttpServer server =
  await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080);
  server.listen((HttpRequest request) async {
    final String code = request.uri.queryParameters["code"];
    request.response
      ..statusCode = 200
      ..headers.set("Content-Type", ContentType.HTML.mimeType)
      ..write("<html><h1>Success!</h1></html>");
    await request.response.close();
    await server.close(force: true);
    onCode.add(code);
    await onCode.close();
    closeWebView();
  });
  return onCode.stream;
}

//TODO: Add state query parameter through random generation
Future<String> getToken(String clientId) async {
  Stream<String> onCode = await _server();
  String url =
      "https://accounts.spotify.com/authorize?client_id=" +clientId +"&response_type=code&redirect_uri=http://localhost:8080";
  _launchURL(url);
  String code = await onCode.first;
  return code;
}