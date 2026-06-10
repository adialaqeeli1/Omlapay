import 'package:flutter/widgets.dart';

/// Local drop-in for the `crypto_font_icons` package.
///
/// The upstream package (v1.0.1, unmaintained) defines its icons via a
/// `CryptoFontIconData extends IconData` class. As of Flutter 3.44, `IconData`
/// is a `final` class and can no longer be extended, so importing the package's
/// Dart library fails to compile. The bundled `CryptoFont` font asset is still
/// shipped by the dependency, so we construct the glyphs as plain [IconData]
/// here and avoid importing the broken library. Glyphs are byte-for-byte
/// identical to the originals.
///
/// Code points map 1:1 to `crypto_font_icons` v1.0.1. Add more as needed.
// ignore_for_file: constant_identifier_names
class CryptoFontIcons {
  const CryptoFontIcons._();

  static const IconData BTC = IconData(
    0xf00c,
    fontFamily: 'CryptoFont',
    fontPackage: 'crypto_font_icons',
  );
  static const IconData ETH = IconData(
    0xf01c,
    fontFamily: 'CryptoFont',
    fontPackage: 'crypto_font_icons',
  );
  static const IconData USDT = IconData(
    0xf04f,
    fontFamily: 'CryptoFont',
    fontPackage: 'crypto_font_icons',
  );
}
