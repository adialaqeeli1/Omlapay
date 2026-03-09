import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CommonLoadingIndicator extends StatelessWidget {
  /// Progress value between 0.0 and 1.0.
  /// If null, the indicator will be indeterminate.
  final double? value;

  const CommonLoadingIndicator({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    // Determine the platform using defaultTargetPlatform so it works
    // even if Theme.of(context).platform is not customized for testing.
    final platform = defaultTargetPlatform;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (platform == TargetPlatform.iOS) {
      if (value != null) {
        return CupertinoActivityIndicator.partiallyRevealed(
          progress: value!,
          color: primaryColor,
        );
      }
      return CupertinoActivityIndicator(color: primaryColor);
    } else {
      return CircularProgressIndicator(value: value, color: primaryColor);
    }
  }
}
