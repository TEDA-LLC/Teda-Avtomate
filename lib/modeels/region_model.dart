class RegionModel {
  var message;
  var success;
  List<Datas>? data;

  RegionModel({this.message, this.success, this.data});

  RegionModel.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    success = json['success'] ?? false;
    if (json['data'] != null) {
      data = <Datas>[];
      json['data'].forEach((v) {
        data!.add(Datas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Datas {
  int? id;
  var name;
  var description;

  Datas({this.id, this.name, this.description});

  Datas.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    description = json['description'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    return data;
  }
}
