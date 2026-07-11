import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/models/wallet_model/wallet_model.dart';
import '../../../dashboard/history/widgets/image_save_as_bottom_sheet.dart';

class QrCodeProvider extends ChangeNotifier {
  QrCodeProvider({required WalletNetworkModel walletNetwork})
    : _walletNetwork = walletNetwork,
      _selectedCoin = walletNetwork.coins.isNotEmpty
          ? walletNetwork.coins.first
          : null;

  final WalletNetworkModel _walletNetwork;
  WalletCoinModel? _selectedCoin;

  final GlobalKey qrBoundaryKey = GlobalKey();

  WalletNetworkModel get walletNetwork => _walletNetwork;
  WalletCoinModel? get selectedCoin => _selectedCoin;
  List<WalletCoinModel> get coins => _walletNetwork.coins;
  bool get hasMultipleCoins => _walletNetwork.coins.length > 1;

  void selectCoin(WalletCoinModel coin) {
    if (_selectedCoin == coin) return;
    _selectedCoin = coin;
    notifyListeners();
  }

  Future<void> saveImage(BuildContext context, ImageSaveFormat format) async {
    final bytes = await _captureQrImage(format);
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final ext = format == ImageSaveFormat.png ? 'png' : 'jpg';
    final symbol = _selectedCoin?.symbol ?? 'unknown';
    final fileName =
        'qr_${symbol}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Gal.putImage(file.path, album: 'OmlaPay');
    await file.delete();
  }

  Future<void> shareImage() async {
    final bytes = await _captureQrImage(ImageSaveFormat.png);
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final symbol = _selectedCoin?.symbol ?? 'unknown';
    final fileName =
        'qr_${symbol}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<List<int>?> _captureQrImage(ImageSaveFormat format) async {
    final boundary =
        qrBoundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;

    const pixelRatio = 3.0;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    if (format == ImageSaveFormat.jpg) {
      final decoded = img.decodeImage(byteData.buffer.asUint8List());
      if (decoded == null) return null;
      return img.encodeJpg(decoded, quality: 90);
    }

    return byteData.buffer.asUint8List();
  }
}
