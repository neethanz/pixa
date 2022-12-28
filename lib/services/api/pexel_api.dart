import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pixa/utils/keys.dart';

class PexelApi {
  static Future<List> getImages() async {
    final images = await http.get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=78'),
        headers: {'Authorization': Keys.pexelApiKey}).then((value) {
      Map result = jsonDecode(value.body);
      // debugPrint(result.toString(), wrapWidth: 1024);
      return [result['photos'], result['next_page']];
    });
    return images;
  }

  static Future<List> loadMoreImages(String url) async {
    final List images = await http.get(Uri.parse(url),
        headers: {'Authorization': Keys.pexelApiKey}).then((value) {
      Map result = jsonDecode(value.body);
      return [result['photos'], result['next_page']];
    });
    return images;
  }

  static Future<List> searchImages({required String searchKey}) async {
    String url =
        'https://api.pexels.com/v1/search?query=$searchKey&per_page=78';
    final List images = await http.get(Uri.parse(url),
        headers: {'Authorization': Keys.pexelApiKey}).then((value) {
      Map result = jsonDecode(value.body);
      return [result['photos'], result['next_page']];
    });

    return images;
  }
}
