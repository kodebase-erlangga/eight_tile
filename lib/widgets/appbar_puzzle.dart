import 'package:flutter/material.dart';
import 'package:tes/widgets/sound_controller.dart';

class AppbarPuzzle extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onFilterPressed;

  const AppbarPuzzle({Key? key, required this.onFilterPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'EIGHT TILE PUZZLE',
        style: TextStyle(
          color: Colors.black,
          fontFamily: "Peace",
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.black),
        onPressed: onFilterPressed, // Callback untuk ikon filter
      ),
      actions: [
          IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SoundController()),
                );
              }),
        ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
