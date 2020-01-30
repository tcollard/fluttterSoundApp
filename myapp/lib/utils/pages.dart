import 'package:myapp/pages/recorder.dart';
import 'package:myapp/pages/settings.dart';
import 'package:myapp/pages/soundLib.dart';
import 'package:flutter/material.dart';

class Page {
  final String title;
  final IconData icon;
  final Widget pageName;

  const Page(this.title, this.icon, this.pageName);
}

class AllPages {

  List<Page> list = [];

  static final AllPages _allPages = AllPages._internal();

  factory AllPages() {
    return _allPages;
  }

  AllPages._internal() {
    list = [
      Page('Record', Icons.keyboard_voice, RecorderPage()),
      Page('Sounds', Icons.queue_music, SoundLib()),
      Page('Settings', Icons.settings, SettingsPage()),
    ];
  }
}

const Toto = 'tata';