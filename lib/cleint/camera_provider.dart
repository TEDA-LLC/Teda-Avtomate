import 'package:flutter/cupertino.dart';
class CameraProvider with ChangeNotifier {
  /*List<CameraDescription> cameras = [];

  setCameras(List<CameraDescription> availableCameras) {
    cameras = availableCameras;
    notifyListeners();
  }*/

  bool _isCameraReady = false;
  bool get isCameraReady => _isCameraReady;
  set isCameraReady(bool isCameraReady) {
    _isCameraReady = isCameraReady;
    notifyListeners();
  }

  bool _isRecording = false;
  bool get isRecording => _isRecording;
  set isRecording(bool isRecording) {
    _isRecording = isRecording;
    notifyListeners();
  }

  bool _isRecordingMode = false;
  bool get isRecordingMode => _isRecordingMode;
  set isRecordingMode(bool isRecordingMode) {
    _isRecordingMode = isRecordingMode;
    notifyListeners();
  }
}