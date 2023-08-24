import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teda_avtomate/modeels/country_model.dart';
import 'package:teda_avtomate/modeels/region_model.dart';
class Api {
  //get api link
  static const String _url = 'http://185.185.80.245:73';

  static const baseUrl = "https://api.remove.bg/v1.0";
  //static const baseUrl = "https://sdk.photoroom.com/v1/segment";
  static const removeBgUrl = '$baseUrl/removebg';
  static const fetchAccountUrl = '$baseUrl/account';
  static const defaultApiKey = "s5rGeBCqLjuoseMTkXaApPYY";
  //static const defaultApiKey = "51c31c952ba1ea873c5f07c844d546673eaf341c";

  //get region http://185.185.80.245:73/api/region
  Future<List> getRegion() async {
    var response = await http.get(Uri.parse('$_url/api/region'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<RegionModel> regions = [];
      for (var item in data['data']) {
        regions.add(RegionModel.fromJson(item));
      }
      return regions;
    } else {
      return [];
    }
  }

  //http://185.185.80.245:73/api/country
  Future<List> getCountry() async {
    var response = await http.get(Uri.parse('$_url/api/country'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<CauntryModel> regions = [];
      for (var item in data['data']) {
        regions.add(CauntryModel.fromJson(item));
      }
      return regions;
    } else {
      return [];
    }
  }
}