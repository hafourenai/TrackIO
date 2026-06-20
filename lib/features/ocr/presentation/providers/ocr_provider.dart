import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/ocr_service.dart';

class OcrState {
  final File? image;
  final bool isScanning;
  final OcrResult? result;
  final String? errorMessage;

  OcrState({
    this.image,
    this.isScanning = false,
    this.result,
    this.errorMessage,
  });

  OcrState copyWith({
    File? image,
    bool? isScanning,
    OcrResult? result,
    String? errorMessage,
  }) {
    return OcrState(
      image: image ?? this.image,
      isScanning: isScanning ?? this.isScanning,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier();
});

class OcrNotifier extends StateNotifier<OcrState> {
  final OcrService _ocrService = OcrService();
  final ImagePicker _picker = ImagePicker();

  OcrNotifier() : super(OcrState());

  Future<void> pickImage(ImageSource source) async {
    state = OcrState(isScanning: false);
    
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        state = state.copyWith(image: file, isScanning: true);
        
        final result = await _ocrService.processReceiptImage(file);
        
        state = state.copyWith(result: result, isScanning: false);
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: 'Gagal memproses gambar: ${e.toString()}',
      );
    }
  }

  void reset() {
    state = OcrState();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
