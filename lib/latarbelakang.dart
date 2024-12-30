import 'package:flutter/material.dart';

class LatarBelakang extends StatelessWidget {
  final Widget child; // Add this line to define a child parameter

  const LatarBelakang({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Menambahkan latar belakang gradien linier
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, // Gradien mulai dari kiri atas
          end: Alignment.bottomRight, // Gradien berakhir di kanan bawah
          colors: [
            Color(0xFFCB9DF0), // Warna awal (#15B392)
            Color(0xFFCB9DF0), // Warna akhir (#D2FF72)
          ],
        ),
      ),
      child: Center(
        child: child, // Render the child widget here
      ),
    );
  }
}