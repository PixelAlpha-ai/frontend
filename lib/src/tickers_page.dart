import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:pixelalpha_fe/src/github_image_page.dart';

class Ticker {
  final String symbol;
  final Map<DateTime, String> entries = SplayTreeMap();

  Ticker(this.symbol);
}

class TickersScreen extends StatefulWidget {
  const TickersScreen({super.key});

  @override
  State<TickersScreen> createState() => _TickersScreenState();
}

class _TickersScreenState extends State<TickersScreen> {
  String? _selectedSymbol;
  DateTime? _selectedDate;

  Future<Map<String, Ticker>> _fetchImageUrls() async {
    final url = Uri.parse(
        'https://api.github.com/repos/PixelAlpha-ai/infomer_predit/contents/output');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<String, Ticker> tickers = SplayTreeMap();

      data
          .where((item) =>
              item['type'] == 'file' && (item['name'].endsWith('.png')))
          .forEach((item) {
        String url = item['download_url'] as String;
        String fileName = item['name'] as String;
        String symbol = fileName.split("_").first;
        DateTime date =
            DateTime.parse(fileName.split("_").last.split(".").first);

        if (tickers.containsKey(symbol)) {
          Ticker ticker = tickers[symbol]!;
          ticker.entries[date] = url;
        } else {
          Ticker ticker = Ticker(symbol);
          ticker.entries[date] = url;
          tickers[symbol] = ticker;
        }
      });
      if (tickers.isNotEmpty && _selectedSymbol == null) {
        Ticker defaultTicker = tickers.entries.first.value;
        _selectedSymbol = defaultTicker.symbol;
        _selectedDate = defaultTicker.entries.entries.last.key;
      }
      return tickers;
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PixelAlpha'),
        ),
        body: FutureBuilder<Map<String, Ticker>>(
          future: _fetchImageUrls(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No images found'));
            } else {
              final githubImages = snapshot.data!;

              return Center(
                  child: Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        DropdownButton<String>(
                          value: _selectedSymbol,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSymbol = newValue!;
                              if (!githubImages[_selectedSymbol]!
                                  .entries
                                  .containsKey(_selectedDate)) {
                                _selectedDate = githubImages[_selectedSymbol]!
                                    .entries
                                    .entries
                                    .last
                                    .key;
                              }
                            });
                          },
                          items: githubImages.entries
                              .map((entry) => DropdownMenuItem<String>(
                                  value: entry.key, child: Text(entry.key)))
                              .toList(),
                        ),

                        const SizedBox(width: 50),

                        DropdownButton<DateTime>(
                          value: _selectedDate,
                          onChanged: (DateTime? newValue) {
                            setState(() {
                              _selectedDate = newValue!;
                            });
                          },
                          items: githubImages[_selectedSymbol]!
                              .entries
                              .entries
                              .map((entry) => DropdownMenuItem<DateTime>(
                                  value: entry.key,
                                  child: Text(DateFormat('yyyy-MM-dd')
                                      .format(entry.key))))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                      "${_selectedSymbol!}\t${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  GithubImagePage(
                      githubImages[_selectedSymbol!]!.entries[_selectedDate!]!)
                ],
              ));
            }
          },
        ));
  }
}
