import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teda_avtomate/auth/register.dart';
import 'package:teda_avtomate/platform/web_register.dart';
import 'package:teda_avtomate/platform/windows_register.dart';
class SamplePage extends StatefulWidget {
  const SamplePage({super.key});

  @override
  State<SamplePage> createState() => _LoginPage();
}

class _LoginPage extends State<SamplePage> {

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid||Platform.isIOS){
      return const Scaffold(
          backgroundColor: Colors.white,
          body: RegisterPage()
      );
    }else if (Platform.isWindows||Platform.isMacOS||Platform.isLinux){
      return const Scaffold(
          backgroundColor: Colors.white,
          body: RegisterPageWin()
      );
    }else{
      return Scaffold(
          backgroundColor: Colors.white,
          body: RegisterPageWeb()
      );
    }
  }
}