import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/eight_tile.dart';

class SoundController extends StatefulWidget {
  const SoundController({Key? key}) : super(key: key);
  @override
  SoundControllerState createState() => SoundControllerState();
}

class SoundControllerState extends State<SoundController> {
  double _musicVolume = 0.5;
  double _narratorVolume = 0.5;
  double _gameVolume = 0.5;
  double _openingVolume = 0.5;

  double get musicVolume => _musicVolume;
  double get narratorVolume => _narratorVolume;
  double get gameVolume => _gameVolume;
  double get openingVolume => _openingVolume;

  @override
  void initState() {
    super.initState();
    _loadVolumePreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setVolume(double value, String type) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      switch (type) {
        case 'music':
          _musicVolume = value;
          musicPlayer.setVolume(_musicVolume);
          prefs.setDouble('musicVolume', _musicVolume);
          break;
        case 'narrator':
          _narratorVolume = value;
          narratorPlayer.setVolume(value);
          prefs.setDouble('narratorVolume', value);
          break;
        case 'game':
          _gameVolume = value;
          gamePlayer.setVolume(value);
          prefs.setDouble('gameVolume', value);
          break;
        case 'opening':
          _openingVolume = value;
          openingPlayer.setVolume(value);
          prefs.setDouble('openingVolume', value);
          break;
      }
    });
  }

  Future<void> _loadVolumePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      _narratorVolume = prefs.getDouble('narratorVolume') ?? 0.5;
      _gameVolume = prefs.getDouble('gameVolume') ?? 0.5;
      _openingVolume = prefs.getDouble('openingVolume') ?? 0.5;
    });
  }

  Widget _buildVolumeControl({
    required String title,
    required IconData icon,
    required Color color,
    required double value,
    required Function(double) onChanged,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: 0,
              max: 1,
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audio Controller',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent,
              Colors.deepPurple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVolumeControl(
                title: 'Music Volume',
                icon: Icons.music_note,
                color: Colors.orange,
                value: _musicVolume,
                onChanged: (value) => _setVolume(value, 'music'),
              ),
              _buildVolumeControl(
                title: 'Narrator Volume',
                icon: Icons.record_voice_over,
                color: Colors.blue,
                value: _narratorVolume,
                onChanged: (value) => _setVolume(value, 'narrator'),
              ),
              _buildVolumeControl(
                title: 'Game Volume',
                icon: Icons.sports_esports,
                color: Colors.green,
                value: _gameVolume,
                onChanged: (value) => _setVolume(value, 'game'),
              ),
              _buildVolumeControl(
                title: 'Opening Volume',
                icon: Icons.movie,
                color: Colors.red,
                value: _openingVolume,
                onChanged: (value) => _setVolume(value, 'opening'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
