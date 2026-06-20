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
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return OcrResult(
        storeName: '',
        date: DateTime.now(),
        totalAmount: 0.0,
        isSure: false,
      );
    }

    String storeName = _detectStoreName(lines);
    DateTime date = _detectDate(lines);
    double totalAmount = _detectTotalAmount(lines);

    final isSure = storeName.isNotEmpty && totalAmount > 0;

    return OcrResult(
      storeName: storeName,
      date: date,
      totalAmount: totalAmount,
      isSure: isSure,
    );
  }

  String _detectStoreName(List<String> lines) {
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (line.isNotEmpty &&
          line.length > 3 &&
          !line.contains(RegExp(r'\d')) &&
          !lower.contains('telp') &&
          !lower.contains('jl') &&
          !lower.contains('no.') &&
          !lower.contains(':') &&
          !lower.startsWith('=') &&
          !lower.startsWith('-')) {
        return line;
      }
    }
    return lines.first;
  }

  DateTime _detectDate(List<String> lines) {
    final dateRegex = RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})');
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        final day = int.tryParse(match.group(1) ?? '');
        final month = int.tryParse(match.group(2) ?? '');
        var year = int.tryParse(match.group(3) ?? '');
        if (day != null && month != null && year != null) {
          if (year < 100) year += 2000;
          if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
            try {
              return DateTime(year, month, day);
            } catch (_) {}
          }
        }
      }
    }
    return DateTime.now();
  }

  double _detectTotalAmount(List<String> lines) {
    if (lines.isEmpty) return 0.0;

    // Priority 1: Cari baris mengandung "total" (hindari "jumlah item/barang")
    double result = _scanForTotal(lines);
    if (result > 0) return result;

    // Priority 2: Cari baris "kembali" → total ada 2 baris di atasnya
    result = _scanByKembali(lines);
    if (result > 0) return result;

    // Priority 3: Cari baris "tunai/cash/bayar" → total ada 1 baris di atas
    result = _scanByPaymentLine(lines);
    if (result > 0) return result;

    // Priority 4: Fallback — angka terbesar di 40% baris terbawah, minimal Rp1000
    return _fallbackTotal(lines);
  }

  double _scanForTotal(List<String> lines) {
    final totalPatterns = ['total', 'grand total', 'belanja'];
    for (int i = lines.length - 1; i >= 0; i--) {
      final lower = lines[i].toLowerCase();
      final isTotal = totalPatterns.any((kw) => lower.contains(kw));
      if (!isTotal) continue;
      if (lower.contains('item') || lower.contains('barang')) continue;

      double amount = _extractPriceFromLine(lines, i);
      if (amount > 0) return amount;
    }
    return 0.0;
  }

  double _scanByKembali(List<String> lines) {
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].toLowerCase().contains('kembali')) {
        if (i >= 2) {
          double amount = _extractPriceFromLine(lines, i - 2);
          if (amount > 0) return amount;
        }
        if (i >= 1) {
          double amount = _extractPriceFromLine(lines, i - 1);
          if (amount > 0) return amount;
        }
      }
    }
    return 0.0;
  }

  double _scanByPaymentLine(List<String> lines) {
    final paymentKeywords = ['tunai', 'cash', 'bayar'];
    for (int i = lines.length - 1; i >= 0; i--) {
      final lower = lines[i].toLowerCase();
      final isPayment = paymentKeywords.any((kw) => lower.contains(kw));
      if (!isPayment) continue;

      if (i >= 1) {
        double amount = _extractPriceFromLine(lines, i - 1);
        if (amount > 0) return amount;
      }
      double amount = _extractPriceFromLine(lines, i);
      if (amount > 0) return amount;
    }
    return 0.0;
  }

  double _fallbackTotal(List<String> lines) {
    final startIndex = (lines.length * 0.6).floor();
    double maxAmount = 0.0;
    for (int i = startIndex; i < lines.length; i++) {
      final amount = _extractPriceFromLine(lines, i);
      if (amount > maxAmount && amount >= 1000) {
        maxAmount = amount;
      }
    }
    return maxAmount;
  }

  double _extractPriceFromLine(List<String> lines, int index) {
    String searchText = lines[index];
    if (index + 1 < lines.length) {
      searchText += ' ${lines[index + 1]}';
    }

    double amount = _parseRupiahFormat(searchText);
    if (amount > 0) return amount;

    amount = _parsePlainNumber(searchText);
    if (amount > 0) return amount;

    return 0.0;
  }

  double _parseRupiahFormat(String text) {
    final rpRegex = RegExp(r'[rR][pP]\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{0,2})?)');
    final match = rpRegex.firstMatch(text);
    if (match == null) return 0.0;

    String numStr = match.group(1)!;

    if (numStr.contains(',') && RegExp(r',\d{2}$').hasMatch(numStr)) {
      numStr = numStr.replaceAll('.', '').replaceFirst(',', '.');
    } else {
      numStr = numStr.replaceAll('.', '').replaceAll(',', '');
    }

    return double.tryParse(numStr) ?? 0.0;
  }

  double _parsePlainNumber(String text) {
    final numberRegex = RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{0,2})?)');
    final matches = numberRegex.allMatches(text);
    if (matches.isEmpty) return 0.0;

    double largest = 0.0;
    for (final m in matches) {
      String numStr = m.group(1)!;

      if (numStr.contains(',') && RegExp(r',\d{2}$').hasMatch(numStr)) {
        numStr = numStr.replaceAll('.', '').replaceFirst(',', '.');
      } else {
        numStr = numStr.replaceAll('.', '').replaceAll(',', '');
      }

      final val = double.tryParse(numStr) ?? 0.0;
      if (val > largest && val >= 1000 && val < 50000000) {
        largest = val;
      }
    }
    return largest;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
