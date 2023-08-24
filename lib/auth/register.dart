import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teda_avtomate/cleint/api.dart';
import 'package:teda_avtomate/modeels/region_model.dart';
import 'package:http/http.dart' as http;
import '../cleint/app_config_provider.dart';
import '../home_page.dart';
import '../rec/string_en.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _LoginPage();
}

class _LoginPage extends State<RegisterPage> {
  //text controller for text field
  final TextEditingController _fioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  var resString;
  var region = [];
  var country = [];
  var dropdownCountryList = ['Uzbekistan', 'Russia', 'USA'];
  var countryId = [1, 2, 3];
  int countryIndex = 0;
  var dropdownRegionList = ['Tashkent', 'Moscow', 'New York'];
  var regionId = [1, 2, 3];
  int regionIndex = 0;

  String selectedOption = 'rezident';
  var selectedCountry = 'USA';
  var selectedRegion = 'Tashkent';

  static const String _url = 'https://api.teda.uz:73';

  File? _originalFile;
  File? _resultedFile;
  String? appDirectoryPath;
  var isInit = false;

  Future<File?> _addPhoto({ImageSource source = ImageSource.gallery}) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
    );
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      return file;
    }
    return null;
  }

  Future<Uint8List> _removeBackground(File uploadedFile, String apiKey) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(Api.removeBgUrl))
        ..headers["X-Api-Key"] = apiKey
        ..files.add(http.MultipartFile.fromBytes(
            'image_file', await uploadedFile.readAsBytes(),
            filename: 'image.png'));

      final response = await request.send();

      if (response.statusCode >= 400) {
        final responseString = await response.stream.bytesToString();
        final encodedResp = json.decode(responseString) as Map<String, dynamic>;
        showToast(
            'Error',
            'Remove background error: ${response.statusCode} : $responseString',
            Colors.red);
        throw Exception(encodedResp['errors'][0]['title']);
      }

      var responseData = await response.stream.toBytes();
      return responseData;
    } catch (err, stacktrace) {
      showToast(
          'Error', 'Remove background error: $err : $stacktrace', Colors.red);
      rethrow;
    }
  }

  Future<File> _saveImage(Uint8List byteStream, String savedImagePath) async {
    File returnedFile = await File(savedImagePath).create(recursive: true);
    await returnedFile.writeAsBytes(byteStream);

    GallerySaver.saveImage(savedImagePath);
    return returnedFile;
  }

  @override
  Future<void> didChangeDependencies() async {
    if (!isInit) {
      appDirectoryPath =
          await getApplicationDocumentsDirectory().then((value) => value.path);

      if (mounted) {
        final provider = Provider.of<AppConfigProvider>(context, listen: false);
        provider
            .getFreeCall()
            .then((balance) => provider.updateBalance(balance));

        final prefs = await SharedPreferences.getInstance();
        final apiKey = prefs.getString('apiKey');
        if (apiKey != null) {
          provider.setApiKey(apiKey);
        }
      }

      isInit = true;
    }
    super.didChangeDependencies();
  }

  Future<void> getRegion() async {
    var response = await http.get(
      Uri.parse(
        '$_url/api/region',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<RegionModel> regions = [];
      selectedRegion = data['data'][0]['name'];
      dropdownRegionList.clear();
      regionId.clear();
      for (var item in data['data']) {
        regions.add(RegionModel.fromJson(item));
        dropdownRegionList.add(item['name']);
        regionId.add(item['id']);
      }
      setState(() {
        region = regions;
      });
    } else {
      showToast(
          'Error',
          'Region not found ${response.statusCode} : ${response.body}',
          Colors.red);
      setState(() {
        region = [];
      });
    }
  }

  Future<void> getCountry() async {
    var response = await http.get(Uri.parse('$_url/api/country'), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<RegionModel> regions = [];
      dropdownCountryList.clear();
      countryId.clear();
      selectedCountry = data['data'][0]['name'];
      for (var item in data['data']) {
        regions.add(RegionModel.fromJson(item));
        dropdownCountryList.add(item['name']);
        countryId.add(item['id']);
      }
      setState(() {
        country = regions;
      });
    } else {
      showToast(
          'Error',
          'Country not found ${response.statusCode} : ${response.body}',
          Colors.red);
      setState(() {
        country = [];
      });
    }
  }

  pushReplacement() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  pop() {
    Navigator.pop(context);
  }

  //http://185.185.80.245:73/api/user
  Future<void> addUser() async {
    final request = http.MultipartRequest('POST', Uri.parse('$_url/api/user'))
      ..fields['fio'] = _fioController.text
      ..fields['email'] = _emailController.text
      ..fields['tel'] = _phoneNumberController.text
      ..fields['lavozim'] = _positionController.text
      ..fields['tashkilot'] = _companyNameController.text
      ..fields['regionId'] = regionId[regionIndex].toString()
      ..fields['countryId'] = countryId[countryIndex].toString()
      ..files.add(http.MultipartFile.fromBytes(
          'image_file', await _resultedFile!.readAsBytes(),
          filename: 'image.png'));

    final response = await request.send();
    if (response.statusCode >= 400) {
      final responseString = await response.stream.bytesToString();
      final encodedResp = json.decode(responseString) as Map<String, dynamic>;
      throw Exception(encodedResp['errors'][0]['title']);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      showToast('Success', 'User added', Colors.green);
      pushReplacement();
    } else {
      showToast('Error', 'User not added', Colors.red);
    }
  }

  showBottomSheet(BuildContext context) {
    var newFile = File('');
    var bytes = Uint8List(0);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .4,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () async {
                          var file =
                              await _addPhoto(source: ImageSource.camera);
                          if (file != null) {
                            var provider = Provider.of<AppConfigProvider>(
                                context,
                                listen: false);
                            final apiKey = provider.apiKey;
                            bytes = await _removeBackground(file, apiKey);
                            var now = DateTime.now();
                            var formatter = DateFormat('yyyy-MM-dd: HH:mm:ss');
                            String formattedDate = formatter.format(now);
                            //save image
                            newFile = await _saveImage(
                                bytes, '$appDirectoryPath/$formattedDate.png');
                            setState(() {
                              _originalFile = newFile;
                              _resultedFile = newFile;
                            });
                          } else {
                            setState(() {
                              file = null;
                              _originalFile = null;
                              _resultedFile = null;
                            });
                          }
                          pop();
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.camera_alt),
                            Text('Camera'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          var file =
                              await _addPhoto(source: ImageSource.gallery);
                          if (file != null) {
                            var provider = Provider.of<AppConfigProvider>(
                                context,
                                listen: false);
                            final apiKey = provider.apiKey;
                            bytes = await _removeBackground(file, apiKey);
                            var now = DateTime.now();
                            var formatter = DateFormat('yyyy-MM-dd: HH:mm:ss');
                            String formattedDate = formatter.format(now);
                            newFile = await _saveImage(
                                bytes, '$appDirectoryPath/$formattedDate.png');
                            setState(() {
                              _originalFile = newFile;
                              _resultedFile = newFile;
                            });
                          } else {
                            setState(() {
                              file = null;
                              _originalFile = null;
                              _resultedFile = null;
                            });
                          }
                          pop();
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.photo),
                            Text('Gallery'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ));
        });
  }

  showToast(String title, String message, Color color) {
    //android toast style for ios
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
    if (Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          closeIconColor: Colors.white,
          backgroundColor: color,
          showCloseIcon: true,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  //language menu button
  showMenuLanguage() {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          100, MediaQuery.of(context).size.height * 0.1, 0, 0),
      items: [
        const PopupMenuItem<String>(
          child: Text('English'),
          value: 'en',
        ),
        const PopupMenuItem<String>(
          child: Text('Русский'),
          value: 'ru',
        ),
        const PopupMenuItem<String>(
          child: Text('O\'zbekcha'),
          value: 'uz',
        ),
      ],
      elevation: 8.0,
    ).then<void>((String? itemSelected) {
      if (itemSelected == null) return;
      setState(() {
        switch (itemSelected) {
          case 'en':
            setLanguage('en');
            resString = StringEn();
            break;
          case 'ru':
            setLanguage('ru');
            resString = StringRu();
            break;
          case 'uz':
            setLanguage('uz');
            resString = StringUz();
            break;
        }
      });
    });
  }

  setLanguage(language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  getLanguage() async{
    final prefs = await SharedPreferences.getInstance();
    var language = prefs.getString('language');
    if(language!.isNotEmpty){
      setState(() {
        switch (language) {
          case 'en':
            resString = StringEn();
            break;
          case 'ru':
            resString = StringRu();
            break;
          case 'uz':
            resString = StringUz();
            break;
        }
      });
    }
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    getLanguage();
    getRegion();
    getCountry();
    resString = StringEn();
  }

  @override
  void dispose() {
    _fioController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _companyNameController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55), // here the desired height
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          actions: [
            Row(
              children: [
                SizedBox(width: w * 0.03),
                Container(
                  width: w * 0.08,
                  height: w * 0.08,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Text(
                  resString.getTeda,
                  style: TextStyle(
                    fontSize: w * 0.05,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            IconButton(
              onPressed: () {
                setState(() {
                  showMenuLanguage();
                  resString = StringEn();
                });
              },
              icon: const Icon(Icons.language, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // //////////////////////////////////////////// //////////////////////////////////////////// //////////////////////////////////////////

          Expanded(
            child: Container(
              width: w,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Colors.deepPurple[800],
              ),
              child: Column(
                children: [
                  Container(
                      width: w,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        color: Colors.deepPurple[800],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: h * 0.03),
                          Text(
                            resString.getRegisterNewUser,
                            style: TextStyle(
                              fontSize: w * 0.04,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: h * 0.03),
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: w * 0.16,
                                backgroundColor: Colors.white,
                                backgroundImage: _resultedFile == null
                                    ? null
                                    : FileImage(_resultedFile!)
                                        as ImageProvider,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (_resultedFile == null)
                                      //empty image
                                      IconButton(
                                        onPressed: () {
                                          showBottomSheet(context);
                                        },
                                        color: Colors.black87,
                                        icon: Icon(
                                          Icons.add_a_photo,
                                          size: w * 0.07,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_resultedFile != null)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: w * 0.05,
                                    backgroundColor: Colors.grey[200],
                                    child: IconButton(
                                      onPressed: () {
                                        showBottomSheet(context);
                                      },
                                      color: Colors.black87,
                                      icon: Icon(
                                        Icons.add_a_photo,
                                        size: w * 0.05,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: h * 0.05),
                        ],
                      )),
                  Expanded(
                    child: Container(
                      width: w,
                      height: h,
                      padding: EdgeInsets.only(top: h * 0.08),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(width: w * 0.05),
                            SizedBox(height: h * 0.02),
                            Container(
                              width: w * 0.9,
                              height: h * 0.1,
                              padding: EdgeInsets.only(left: w * 0.005),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: TextField(
                                controller: _fioController,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: resString.getFio,
                                  hintStyle: TextStyle(
                                    fontSize: w * 0.036,
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: Icon(
                                    size: w * 0.06,
                                    Icons.person,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: h * 0.02),
                            Container(
                              width: w * 0.9,
                              height: h * 0.1,
                              padding: EdgeInsets.only(left: w * 0.005),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _emailController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: resString.getEmail,
                                    hintStyle: TextStyle(
                                      fontSize: w * 0.036,
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: Icon(
                                      size: h * 0.06,
                                      Icons.email,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: h * 0.02),
                            Container(
                              width: w * 0.9,
                              height: h * 0.1,
                              padding: EdgeInsets.only(left: w * 0.005),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _phoneNumberController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: resString.getPhoneNumber,
                                    hintStyle: TextStyle(
                                      fontSize: w * 0.036,
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: Icon(
                                      size: w * 0.06,
                                      Icons.phone,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: w * 0.03),

                            Row(
                              children: [
                                SizedBox(width: w * 0.03),
                                Radio(
                                  value: 'rezident',
                                  groupValue: selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value!;
                                    });
                                  },
                                ),
                                Text(
                                    resString.getRezident,
                                    style: TextStyle(
                                        fontSize: w * 0.03,
                                        color: Colors.black)),
                                SizedBox(width: w * 0.03),
                                Radio(
                                  value: 'nonrezident',
                                  groupValue: selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value!;
                                    });
                                  },
                                ),
                                Text(
                                    resString.getNoRezident,
                                    style: TextStyle(
                                        fontSize: w * 0.03,
                                        color: Colors.black)),
                              ],
                            ),
                            SizedBox(height: h * 0.02),
                            //if rezident selected then show region and country dropdown
                            if (selectedOption == 'rezident')
                              if (region.isNotEmpty)
                                Container(
                                  width: w * 0.9,
                                  height: h * 0.1,
                                  padding: EdgeInsets.only(
                                      left: w * 0.02, right: w * 0.02),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                  ),
                                  child: Center(
                                    child: DropdownButton(
                                      underline: const SizedBox(),
                                      isExpanded: true,
                                      value: selectedCountry,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCountry = value.toString();
                                          countryIndex = dropdownCountryList
                                              .indexOf(value!);
                                        });
                                      },
                                      items: dropdownCountryList.map((e) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                            if (selectedOption != 'rezident')
                              if (region.isNotEmpty)
                                Container(
                                  width: w * 0.9,
                                  height: h * 0.1,
                                  padding: EdgeInsets.only(
                                      left: w * 0.02, right: w * 0.02),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                  ),
                                  child: Center(
                                    child: DropdownButton(
                                      underline: const SizedBox(),
                                      isExpanded: true,
                                      value: selectedRegion,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedRegion = value.toString();
                                          regionIndex = dropdownRegionList
                                              .indexOf(value!);
                                        });
                                      },
                                      items: dropdownRegionList.map((e) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                            if (region.isNotEmpty || country.isNotEmpty)
                              SizedBox(height: h * 0.02),
                            Container(
                              width: w * 0.9,
                              height: h * 0.1,
                              padding: EdgeInsets.only(
                                  left: w * 0.005, right: w * 0.02),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _companyNameController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: resString.getCompanyName,
                                    hintStyle: TextStyle(
                                      fontSize: w * 0.035,
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: Icon(
                                      size: w * 0.06,
                                      Icons.business,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: h * 0.02),
                            Container(
                              width: w * 0.9,
                              height: h * 0.1,
                              padding: EdgeInsets.only(
                                  left: w * 0.005, right: w * 0.02),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _positionController,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: resString.getPosition,
                                    hintStyle: TextStyle(
                                      fontSize: w * 0.035,
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: Icon(
                                      size: w * 0.06,
                                      Icons.work,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: h * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: w,
            color: Colors.white,
            padding: EdgeInsets.only(
                bottom: h * 0.02, left: w * 0.02, right: w * 0.02),
            child: Container(
              width: w * 0.9,
              height: h * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.deepPurple[800],
              ),
              child: TextButton(
                onPressed: () {
                  if (_fioController.text.isEmpty) {
                    showToast('Error', 'FIO is empty', Colors.red);
                    return;
                  }
                  if (_emailController.text.isEmpty) {
                    showToast('Error', 'Email is empty', Colors.red);
                    return;
                  }
                  if (_phoneNumberController.text.isEmpty) {
                    showToast('Error', 'Phone number is empty', Colors.red);
                    return;
                  }
                  if (_companyNameController.text.isEmpty) {
                    showToast('Error', 'Company name is empty', Colors.red);
                    return;
                  }
                  if (_positionController.text.isEmpty) {
                    showToast('Error', 'Position is empty', Colors.red);
                    return;
                  }
                  if (_originalFile == null) {
                    showToast('Error', 'Photo is empty', Colors.red);
                    return;
                  }
                  if (selectedOption == 'rezident') {
                    if (selectedCountry.isEmpty) {
                      showToast('Error', 'Country is empty', Colors.red);
                      return;
                    }
                  } else {
                    if (selectedRegion.isEmpty) {
                      showToast('Error', 'Region is empty', Colors.red);
                      return;
                    }
                  }
                  addUser();
                },
                child: Text(
                  resString.getRegister,
                  style: TextStyle(
                    fontSize: w * 0.03,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
