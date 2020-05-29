class RecordInfo {
  static final RecordInfo _info = RecordInfo._internal();

  bool _isRecording = false;
  bool _isPlaying = false;
  String _recordPath;
  Duration _duration;

  factory RecordInfo() => _info;

  RecordInfo._internal();

  bool isRecording() => _isRecording;
  bool isPlaying() => _isPlaying;
  String recordPath() => _recordPath;
  Duration getDuration() => _duration;

  void setIsRecording(value) {
    _isRecording = value;
  }

  void setIsPlaying(value) {
    _isPlaying = value;
  }

  void setRecordPath(path) {
    _recordPath = path;
  }

  void setDuration(Duration duration) {
    _duration = duration;
  }
}