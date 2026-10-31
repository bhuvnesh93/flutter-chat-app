import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({super.key, this.image = "", this.defautImage = ""});

  final String image;
  final String defautImage;

  @override
  Widget build(BuildContext context) {
    return image.isNotEmpty
        ? CircleAvatar(radius: 30, backgroundImage: NetworkImage(image))
        : CircleAvatar(radius: 30, backgroundImage: AssetImage(defautImage));
  }
}
