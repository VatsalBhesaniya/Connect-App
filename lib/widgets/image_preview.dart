import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({Key? key, required this.imageFile}) : super(key: key);
  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.file(imageFile),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[700],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueGrey,
                  ),
                ),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 25.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
