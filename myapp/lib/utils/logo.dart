import 'package:flutter/material.dart';
import 'package:myapp/utils/cache.dart';

class LogoPath {
  String _logoPath;
  String _logoLm;
  String _logoBm;

  static final LogoPath _logo = LogoPath._internal();

  factory LogoPath() => _logo;

  LogoPath._internal() {
    _logoBm = 'lib/asset/icons/mymic_bm.png';
    _logoLm = 'lib/asset/icons/mymic_lm.png';
    _logoPath = _logoLm;
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
  Cache _cache = Cache();

  @override
  void initState() {
    _cache.getCacheOnKey('darkModeState').then((state) {
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
