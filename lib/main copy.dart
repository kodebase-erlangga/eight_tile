import 'package:flutter/material.dart';
import 'package:tes/latarbelakang.dart';
import 'package:tes/widgets/appbar_main.dart';
import 'package:tes/widgets/card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuzzleSelectionScreen(),
    );
  }
}

class PuzzleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppbarMain(),
        body: LatarBelakang(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      "PUZZLE",
                      style: TextStyle(
                          fontSize: 50,
                          fontFamily: "PixelGameFont",
                          color: Colors.white),
                    ),
                  ),
                ),
                ButtonCard(
                  title: "WAJAH",
                  url:
                      "https://drive.google.com/uc?export=view&id=1nbf1uDKS9gLnqZRJRQlrWWUmtRRQjhRB",
                ),
                ButtonCard(
                  title: "RAMBUTAN",
                  url:
                      "https://akcdn.detik.net.id/visual/2021/03/29/ilustrasi-rambutan_169.jpeg?w=650&q=80",
                ),
                ButtonCard(
                  title: "APEL",
                  url:
                      "https://asset-a.grid.id/crop/0x0:0x0/700x465/photo/2023/12/11/apel4jpg-20231211013431.jpg",
                ),
              ],
            ),
          ),
        ));
  }
}