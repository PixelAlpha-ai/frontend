import 'package:flutter/material.dart';

class GithubImagePage extends StatelessWidget {

  final String url;

  const GithubImagePage(this.url, {super.key});

  @override
  Widget build(BuildContext context) {

    return Image.network(
          url,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return const Text('Failed to load image');
          },
        );
  }
  
}