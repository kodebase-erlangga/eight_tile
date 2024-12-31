import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tes/latarbelakang.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tes/widgets/sound_controller.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../component/puzzle_api.dart';

AudioPlayer musicPlayer = AudioPlayer();
AudioPlayer narratorPlayer = AudioPlayer();
AudioPlayer gamePlayer = AudioPlayer();
AudioPlayer openingPlayer = AudioPlayer();
AudioPlayer finishPlayer = AudioPlayer();

// ignore: must_be_immutable
class EightTilePuzzle extends StatefulWidget {
  final String myurl;
  String? naratorSound;
  EightTilePuzzle({required this.myurl, this.naratorSound}) : super(key: null);
  @override
  _EightTilePuzzleState createState() =>
      _EightTilePuzzleState(myurl: this.myurl, naratorSound: this.naratorSound);
}

class _EightTilePuzzleState extends State<EightTilePuzzle> {
  bool aktifkanTombolSound = false;
  bool isLoading = true;
  bool isConnected = false;

  double _musicVolume = 0.5;
  double _narratorVolume = 0.5;
  double _gameVolume = 0.5;
  double _openingVolume = 0.5;

  double get musicVolume => _musicVolume;
  double get narratorVolume => _narratorVolume;
  double get gameVolume => _gameVolume;
  double get openingVolume => _openingVolume;

  String myurl;
  String? naratorSound;
  _EightTilePuzzleState({required this.myurl, this.naratorSound});
  final GlobalKey<SoundControllerState> soundControllerKey =
      GlobalKey<SoundControllerState>();
  final int gridSize = 3;
  List<int> tileOrder = [];
  bool _isOpeningSoundPlayed = false;
  bool showAnimatedContainer = false;
  double boxHeight = 860;
  double boxWidth = 860;
  double boxX = 0;
  double boxY = -1.06;
  bool _isMuted = true;
  List<String> imagePaths = [];
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  bool isOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartDialog();
      if (widget.naratorSound.toString() !=
          'https://ebook.erlanggaonline.co.id/puzzledata/puzzlesound/') {
        // print('ihsan yy' + widget.naratorSound.toString());
        aktifkanTombolSound = true;
      }
      // print('ihsan yy' + widget.naratorSound.toString());

      if (!_isOpeningSoundPlayed) {
        _playOpeningSound();
        _isOpeningSoundPlayed = true;
      }
    });
    _loadVolumePreferences();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
      isLoading = false;
    });

    if (isConnected) {
      _reloadPage();
    }
  }

  void _reloadPage() {
    setState(() {
      _loadVolumePreferences();
      _checkInternetConnection();
    });
    print("Page reloaded!");
  }

  Future<void> _toggleSound(bool mute, int index, double volume) async {
    try {
      if (mute) {
        await narratorPlayer.pause();
        if (mounted) {
          setState(() {
            _isMuted = true;
          });
        }
      } else {
        if (widget.naratorSound != '') {
          await narratorPlayer.setUrl(widget.naratorSound!);
          // print('ihsan xx ' + widget.naratorSound.toString());
          await narratorPlayer.setVolume(volume);
          await narratorPlayer.play();
          if (mounted) {
            setState(() {
              _isMuted = false;
            });
          }
        } else {
          print("Sound URL is null or invalid");
        }
      }
    } catch (e) {
      print("Error saat mengatur suara: $e");
    }
  }

  Future<void> _loadVolumePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      _narratorVolume = prefs.getDouble('narratorVolume') ?? 0.5;
      _gameVolume = prefs.getDouble('gameVolume') ?? 0.5;
      _openingVolume = prefs.getDouble('openingVolume') ?? 0.5;

      musicPlayer.setVolume(_musicVolume);
      narratorPlayer.setVolume(_narratorVolume);
      gamePlayer.setVolume(_gameVolume);
      openingPlayer.setVolume(_openingVolume);

      // print('ihsan' + widget.naratorSound.toString());
    });
  }

  void loadImages() async {
    await Future.delayed(Duration(seconds: 20));
    setState(() {
      isLoading = false;
    });
  }

  void _playBackgroundMusic() async {
    try {
      musicPlayer.setVolume(_musicVolume);
      await musicPlayer.setAsset('assets/music/background.mp3');
      await musicPlayer.setLoopMode(LoopMode.one);
      await musicPlayer.play();
      print("Setting volume to: $musicVolume");
      print('Volume: $musicVolume');
    } catch (e) {
      print("Error saat memutar musik latar: $e");
    }
  }

  void _playOpeningSound() async {
    try {
      await openingPlayer.setAsset('assets/sound/opening.mp3');
      openingPlayer.setVolume(_openingVolume);
      openingPlayer.play();
    } catch (e) {
      print("Error saat memutar suara pergerakan: $e");
    }
  }

  void _playMoveSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _gameVolume = prefs.getDouble('gameVolume') ?? 0.5;
      await gamePlayer.setAsset('assets/sound/pindah.mp3');
      gamePlayer.setVolume(_gameVolume);
      // gamePlayer.setVolume(1.0);
      gamePlayer.play();
      print('ihsan111 ' + _gameVolume.toString());
    } catch (e) {
      print("Error saat memutar suara pergerakan: $e");
    }
  }

  void _playFinishSound() async {
    await finishPlayer.setAsset('assets/sound/finish.mp3');
    finishPlayer.play();
  }

  @override
  void dispose() {
    musicPlayer.stop();
    gamePlayer.stop();
    narratorPlayer.stop();
    openingPlayer.stop();
    super.dispose();
  }

  void _generatePuzzle() {
    tileOrder = List.generate(gridSize * gridSize, (index) => index);
    tileOrder.shuffle(Random());
    setState(() {});
  }

  void _swapTiles(int index1, int index2) {
    setState(() {
      int temp = tileOrder[index1];
      tileOrder[index1] = tileOrder[index2];
      tileOrder[index2] = temp;
      _playMoveSound();
    });
  }

  bool _isSolved() {
    for (int i = 0; i < tileOrder.length - 1; i++) {
      if (tileOrder[i] != i) return false;
    }
    return true;
  }

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  // Fungsi untuk mengecilkan ukuran box
  void _reduceBox() {
    setState(() {
      boxHeight = 200;
      boxWidth = 200;
    });
  }

  void _moveBox() {
    setState(() {
      boxX = 0;
      boxY = 1.0;
    });
  }

  final List<Color> colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  final TextStyle colorizeTextStyle = TextStyle(
    fontSize: 20.0,
    fontFamily: 'Horizon',
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    double tileSize = MediaQuery.of(context).size.width / gridSize;
    String formattedTime = _formatDuration(_stopwatch.elapsed);

    final myAppBar = AppBar(
      backgroundColor: Colors.purple,
      centerTitle: true,
      title: const Text(
        'EIGHT TILE PUZZLE',
        style: TextStyle(
          color: Colors.white,
          fontFamily: "ComicSans", // Font lebih playful
          fontSize: 22,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 2,
              color: Colors.black45,
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SoundController()),
            );
          },
        ),
      ],
    );

    final bodyHeight = mediaQueryHeight -
        myAppBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          return false;
        },
        child: Scaffold(
          appBar: myAppBar,
          body: LatarBelakang(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 0.0,
                        ),
                        itemCount: tileOrder.length,
                        itemBuilder: (context, index) {
                          int tileIndex = tileOrder[index];
                          if (tileIndex == gridSize * gridSize - 1) {
                            return GestureDetector(
                              onTap: () {
                                if (_isMovable(index)) {
                                  _swapTiles(
                                      index,
                                      tileOrder
                                          .indexOf(gridSize * gridSize - 1));
                                  if (_isSolved()) {
                                    _showWinDialog();
                                  }
                                }
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Container(),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                if (_isMovable(index)) {
                                  _swapTiles(
                                      index,
                                      tileOrder
                                          .indexOf(gridSize * gridSize - 1));
                                  if (_isSolved()) {
                                    _showWinDialog();
                                  }
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Image.file(
                                  File(imagePaths[tileIndex]),
                                  fit: BoxFit.cover,
                                  width: tileSize,
                                  height: tileSize,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Time: $formattedTime",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment(boxX, boxY),
                  child: Container(
                    height: bodyHeight * 0.67,
                    width: mediaQueryWidth,
                    margin: EdgeInsets.only(bottom: 60),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: boxWidth,
                          height: boxHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              myurl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text("Gambar gagal dimuat!"),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const Center(
                      // child: CircularProgressIndicator(),
                      ),
              ],
            ),
          ),
        ));
  }

  bool _isMovable(int index) {
    int emptyIndex = tileOrder.indexOf(gridSize * gridSize - 1);
    int row = index ~/ gridSize;
    int col = index % gridSize;
    int emptyRow = emptyIndex ~/ gridSize;
    int emptyCol = emptyIndex % gridSize;

    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void _showWinDialog() {
    _stopwatch.stop();
    String formattedTime = _formatDuration(_stopwatch.elapsed);
    _playFinishSound();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Congratulations!"),
        content: Text(
            "You solved the puzzle in the correct order!\nTime: $formattedTime"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generatePuzzle();
              _startStopwatch();
            },
            child: Text("Play Again"),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: SizedBox(
          width: double.infinity, // Adjust title width
          child: AnimatedTextKit(
            animatedTexts: [
              ColorizeAnimatedText(
                'Ayo kita susun puzzle-nya!',
                textStyle: colorizeTextStyle,
                colors: colorizeColors,
                textAlign: TextAlign.center,
              ),
            ],
            isRepeatingAnimation: true,
            onTap: () {
              print("Dialog Title Tapped");
            },
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                myurl,
                fit: BoxFit.cover,
                width: 300,
                height: 300,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    print("Gambar selesai dimuat.");
                    return child;
                  }
                  print("Gambar sedang dimuat...");
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text("Periksa Internet Kamu"),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Visibility(
            //   visible: widget.naratorSound != '',
            Column(
              children: [
                Text(
                  "Ayo bermain sambil mendengarkan kisahnya!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (aktifkanTombolSound)
                  ToggleSwitch(
                    minWidth: 100.0,
                    initialLabelIndex: _isMuted ? 1 : 0,
                    cornerRadius: 20.0,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    totalSwitches: 2,
                    labels: ['Putar', 'Bisukan'],
                    icons: [FontAwesomeIcons.play, FontAwesomeIcons.volumeMute],
                    activeBgColors: [
                      [Colors.green],
                      [Colors.red],
                    ],
                    onToggle: (index) {
                      final mute = index == 1;
                      _toggleSound(mute, index!, _narratorVolume);
                      print('Switched to: $index, mute: $mute');
                    },
                  ),
              ],
              // ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _preparePuzzleImagesFromUrl(myurl);
              PaintingBinding.instance.imageCache.clear();
              _generatePuzzle();
              _startStopwatch();
              _playBackgroundMusic();
              setState(() {
                isLoading = false;
              });
              setState(() {
                showAnimatedContainer = true;
              });
              Future.delayed(Duration(milliseconds: 1500), () {
                _reduceBox();
                _moveBox();
              });
            },
            child: Text("Mulai"),
          ),
          TextButton(
            onPressed: () {
              _toggleSound(true, 1, 0);
              _checkInternetConnection();

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text("Batal"),
          ),
        ],
      ),
    );
  }

  Future<void> _preparePuzzleImagesFromUrl(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        print("Gagal mengunduh gambar dari URL.");
        return;
      }

      final Uint8List imageBytes = response.bodyBytes;
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        print("Gambar tidak dapat didekode.");
        return;
      }

      final int minSide = originalImage.width < originalImage.height
          ? originalImage.width
          : originalImage.height;
      final img.Image squareImage = img.copyCrop(
        originalImage,
        x: (originalImage.width - minSide) ~/ 2,
        y: (originalImage.height - minSide) ~/ 2,
        width: minSide,
        height: minSide,
      );

      // Tentukan folder penyimpanan lokal
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String targetDirectory = '${appDir.path}/puzzle_tiles';
      final Directory directory = Directory(targetDirectory);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      if (directory.existsSync()) {
        final files = directory.listSync();
        for (var file in files) {
          if (file is File) {
            try {
              imagePaths.clear();
              file.deleteSync();
            } catch (e) {
              print('sux1 An error occurred: $e');
            }
          }
        }
      }

      const int rows = 3;
      const int columns = 3;
      final int tileWidth = (squareImage.width / columns).floor();
      final int tileHeight = (squareImage.height / rows).floor();

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          final img.Image tile = img.copyCrop(
            squareImage,
            x: col * tileWidth,
            y: row * tileHeight,
            width: tileWidth,
            height: tileHeight,
          );

          final String filePath =
              '$targetDirectory/tile_${row * columns + col + 1}.jpg';
          final File file = File(filePath);
          await file.writeAsBytes(img.encodeJpg(tile));
          imagePaths.add(filePath);
          print('sux Tile disimpan: ${file.path}');
          print("sux2 " + imagePaths.length.toString());
        }
        print("sux " + imagePaths.toString());
      }

      print("sux Semua tile telah disimpan di: $targetDirectory");
    } catch (e) {
      print("sux Terjadi kesalahan: $e");
    }
  }
}
