import 'package:flutter/material.dart';
import 'package:pixelalpha_fe/src/tickers_page.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelAlpha',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TickersScreen(),
    );
  }
}

