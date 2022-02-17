import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'package:funny_facts/models/fact.dart';

class ApiService {
  final apiUrl =
      Uri.parse("https://uselessfacts.jsph.pl/random.json?language=en");

  Future<Fact> getFact() async {
    Response res = await get(apiUrl);

    if (res.statusCode == 200) {
      var resBody = jsonDecode(res.body);
      Fact quote = Fact.fromJson(resBody);
      return quote;
    } else {
      throw "api returned none 200 response";
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
