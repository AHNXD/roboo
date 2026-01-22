class UserModel {
  MainData? mainData;
  MoreData? moreData;

  UserModel({this.mainData, this.moreData});

  UserModel.fromJson(Map<String, dynamic> json) {
    mainData = json['main_data'] != null
        ? MainData.fromJson(json['main_data'])
        : null;
    moreData = json['more_data'] != null
        ? MoreData.fromJson(json['more_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mainData != null) {
      data['main_data'] = mainData!.toJson();
    }
    if (moreData != null) {
      data['more_data'] = moreData!.toJson();
    }
    return data;
  }
}

class MainData {
  int? id;
  String? image;
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  String? role;

  MainData({
    this.id,
    this.image,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.role,
  });

  MainData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['profile_image'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phone = json['phone'];
    email = json['email'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['profile_image'] = image;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['phone'] = phone;
    data['email'] = email;
    data['role'] = role;
    return data;
  }
}

class MoreData {
  String? address;
  String? gender;
  String? weight;
  String? height;
  String? maritalStatus;
  bool? hasChildren;
  String? numberOfChildren;
  String? birthDate;
  bool? isSmoke;

  MoreData({
    this.address,
    this.gender,
    this.weight,
    this.height,
    this.maritalStatus,
    this.hasChildren,
    this.numberOfChildren,
    this.birthDate,
    this.isSmoke,
  });

  MoreData.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    gender = json['gender'];
    weight = json['weight'].toString();
    height = json['height'].toString();
    maritalStatus = json['marital_status'];
    hasChildren = json['has_children'];
    numberOfChildren = json['number_of_children'].toString();
    birthDate = json['birth_date'];

    isSmoke = json['is_smoke'].toString() == "1";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['gender'] = gender;
    data['weight'] = weight;
    data['height'] = height;
    data['marital_status'] = maritalStatus;
    data['has_children'] = hasChildren;
    data['number_of_children'] = numberOfChildren;
    data['birth_date'] = birthDate;

    data['is_smoke'] = isSmoke;

    return data;
  }
}
