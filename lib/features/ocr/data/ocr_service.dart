import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String storeName;
  final DateTime date;
  final double totalAmount;
  final bool isSure;

  OcrResult({
    required this.storeName,
    required this.date,
    required this.totalAmount,
    required this.isSure,
  });
}

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<OcrResult> processReceiptImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    final lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text.trim())
        .toList();

    if (lines.isEmpty) {
      return OcrResult(
        storeName: '',
        date: DateTime.now(),
        totalAmount: 0.0,
        isSure: false,
      );
    }

    String storeName = '';
    for (final line in lines) {
      if (line.isNotEmpty && 
          !line.contains(RegExp(r'\d')) && 
          line.length > 3 && 
          !line.toLowerCase().contains('telp') && 
          !line.toLowerCase().contains('jl')) {
        storeName = line;
        break;
      }
    }
    if (storeName.isEmpty) {
      storeName = lines.first;
    }

    DateTime date = DateTime.now();
    bool foundDate = false;
    final dateRegex = RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})');
    
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        final day = int.tryParse(match.group(1) ?? '');
        final month = int.tryParse(match.group(2) ?? '');
        var year = int.tryParse(match.group(3) ?? '');
        
        if (day != null && month != null && year != null) {
          if (year < 100) {
            year += 2000;
          }
          if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
            try {
              date = DateTime(year, month, day);
              foundDate = true;
              break;
            } catch (_) {}
          }
        }
      }
    }

    double totalAmount = 0.0;
    bool foundTotal = false;
    final totalKeywords = ['total', 'grand total', 'belanja', 'bayar', 'jumlah', 'net', 'cash'];
    final numberRegex = RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)');

    for (var i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();
      final hasKeyword = totalKeywords.any((kw) => lineLower.contains(kw));
      
      if (hasKeyword) {
        String searchContext = lines[i];
        if (!searchContext.contains(RegExp(r'\d')) && i + 1 < lines.length) {
          searchContext = "${lines[i]} ${lines[i + 1]}";
        }
        
        final matches = numberRegex.allMatches(searchContext);
        if (matches.isNotEmpty) {
          final cleanNumStr = matches.last.group(0)!
              .replaceAll('.', '')
              .replaceAll(',', '');
          
          final amount = double.tryParse(cleanNumStr);
          if (amount != null && amount > totalAmount) {
            totalAmount = amount;
            foundTotal = true;
          }
        }
      }
    }

    if (!foundTotal) {
      double maxNum = 0.0;
      for (final line in lines) {
        final matches = numberRegex.allMatches(line);
        for (final m in matches) {
          final cleanNumStr = m.group(0)!
              .replaceAll('.', '')
              .replaceAll(',', '');
          final val = double.tryParse(cleanNumStr) ?? 0.0;
          if (val > maxNum && val < 50000000) {
            maxNum = val;
          }
        }
      }
      totalAmount = maxNum;
    }

    final isSure = storeName.isNotEmpty && foundDate && totalAmount > 0;

    return OcrResult(
      storeName: storeName,
      date: date,
      totalAmount: totalAmount,
      isSure: isSure,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
