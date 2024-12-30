import 'package:flutter/material.dart';

class AppbarMain extends StatelessWidget implements PreferredSizeWidget {
  const AppbarMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // centerTitle: true,
      // title: const Text(
      //   'My App',
      //   style: TextStyle(color: Colors.black), // Warna teks di AppBar
      // ),
      // actions: [
      //   IconButton(
      //     icon: SvgPicture.asset(
      //       'assets/icons/bell.svg',
      //       color: Colors.black,
      //       height: 24.0,
      //     ),
      //     onPressed: () {
      //       print('Bell icon clicked');
      //     },
      //   ),
      //   IconButton(
      //     icon: SvgPicture.asset(
      //       'assets/icons/bars-sort.svg',
      //       color: Colors.black,
      //       height: 24.0,
      //     ),
      //     onPressed: () {
      //       print('Bars-sort icon clicked');
      //     },
      //   ),
      // ],
      backgroundColor: Colors.white,
      // elevation: 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
