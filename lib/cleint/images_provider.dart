import 'package:flutter/widgets.dart';

class ImagesProvider with ChangeNotifier {
  ImageProcessingState imageProcessingState = ImageProcessingState.empty;
  bool originalImageCorrupted = false;

  void nextPhase() {
    switch(imageProcessingState.index) {
      case 0: imageProcessingState = ImageProcessingState.added;break;
      case 1: imageProcessingState = ImageProcessingState.processing;break;
      case 2: imageProcessingState = ImageProcessingState.processed;break;
      default:
    }
    notifyListeners();
  }

  void toPhase(ImageProcessingState state) {
    imageProcessingState = state;
    notifyListeners();
  }

  // void restartProcess() {
  //   imageProcessingState = 1;
  //   notifyListeners();
  // }
  //
  // void reRemoveBackground() {
  //   imageProcessingState = 2;
  //   notifyListeners();
  // }

  void updateOriginalImageErrorState(bool state) {
    originalImageCorrupted = state;
    notifyListeners();
  }
}

enum ImageProcessingState {
  empty, added, processing, processed
}