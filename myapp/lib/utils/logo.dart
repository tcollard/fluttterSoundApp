import 'package:flutter/material.dart';
import 'package:myapp/utils/cache.dart';

class LogoPath {
  String _logoPath;
  String _logoLm;
  String _logoBm;

  static final LogoPath _logo = LogoPath._internal();

  factory LogoPath() => _logo;

  LogoPath._internal() {
    _logoPath = 'lib/asset/icons/mymic_bm.png';
    _logoBm = 'lib/asset/icons/mymic_bm.png';
    _logoLm = 'lib/asset/icons/mymic_lm.png';
  }

  String getLogo() => _logoPath;

  changeLogo(darkModeState) {
    _logoPath = (darkModeState == true) ? _logoBm : _logoLm;
  }
}

class Logo extends StatefulWidget {
  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  LogoPath _logo = LogoPath();

  @override
  void initState() {
    Cache().getCacheOnKey('darkModeState').then((state) {
      setState(() {
        _logo.changeLogo(state);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width * 0.8;
    return Image.asset(
      _logo.getLogo(),
      width: _width,
      height: 50,
    );
  }
}
