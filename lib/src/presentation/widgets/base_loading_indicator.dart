import 'package:flutter/material.dart';

class BaseLoadingIndicator extends StatelessWidget {
  final String? text;

  const BaseLoadingIndicator({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text ?? ''),
            ),
        ],
      ),
    );
  }
}
