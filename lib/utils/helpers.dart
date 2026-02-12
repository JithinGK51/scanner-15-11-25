import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }

  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool isValidURL(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static bool isUPI(String data) {
    return data.toLowerCase().startsWith('upi://') ||
        data.toLowerCase().contains('@paytm') ||
        data.toLowerCase().contains('@phonepe') ||
        data.toLowerCase().contains('@gpay') ||
        data.toLowerCase().contains('@ybl') ||
        data.toLowerCase().contains('@axl');
  }

  static String getCodeType(String data) {
    if (isUPI(data)) {
      return 'UPI Payment';
    } else if (isValidURL(data)) {
      return 'URL';
    } else {
      return 'Text';
    }
  }
}

