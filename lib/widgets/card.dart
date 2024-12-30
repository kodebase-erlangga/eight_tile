import 'package:flutter/material.dart';
import '../view/eight_tile.dart';

class ButtonCard extends StatelessWidget {
  final String title;
  final String url;

  const ButtonCard({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Peace",
            ),
          ),
          leading: const Icon(Icons.image),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EightTilePuzzle(
                  myurl: url, // Pass the `url` parameter here
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
