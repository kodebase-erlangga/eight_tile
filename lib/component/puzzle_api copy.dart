import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tes/view/eight_tile.dart';
import '../widgets/sound_controller.dart';

class PuzzleItem {
  final String puzzleCover;
  final String linkUrl;
  final String sound;
  PuzzleItem(this.puzzleCover, this.linkUrl, this.sound);
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> idProduct = [];
  List<String> kategoriProduct = [];
  List<String> bannerImages = [];
  List<String> idXProduct = [];
  List<String> kategoriXProduct = [];
  List<String> productUrls = [];
  List<String> narationSound = [];
  bool isLoading = true;
  String erlStatusId = '';
  List<Map<String, String>> categories = [];
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadBannerData('');
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    const url = 'https://ebook.erlanggaonline.co.id/';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'id': '19',
        'aksi': 'ambil_kategoripuzzle',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['erlStatusId'];

        setState(() {
          erlStatusId = (status is bool) ? status.toString() : status as String;
        });

        if (erlStatusId == 'true') {
          final puzzleArray = data['data'] as List<dynamic>;
          setState(() {
            idXProduct = puzzleArray
                .map<String>((item) => item['kategori_idx'] as String)
                .toList();
            kategoriXProduct = puzzleArray
                .map<String>((item) => item['kategori_title'] as String)
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            erlStatusId = 'Error: $erlStatusId';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          erlStatusId =
              'Failed to load data. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      setState(() {
        erlStatusId = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _onFilterPressed() {
    if (isLoading) return; // Prevent filter if categories are still loading

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: kategoriXProduct.isEmpty
              ? const Center(child: Text('No categories available'))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(kategoriXProduct.length, (index) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              kategoriXProduct[index],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            // print('ihsan' + idXProduct[index]);
                            Navigator.of(context).pop();
                            _loadBannerData(idXProduct[index]);
                          },
                        ),
                      );
                    }),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadBannerData(String kategori) async {
    var url = 'https://ebook.erlanggaonline.co.id/';
    var response = await http.post(Uri.parse(url), body: {
      'id': '19',
      'kategori': kategori,
      'token': '1',
      'aksi': 'ambil_listpuzzle',
    });

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        var status = data['erlStatusId'];

        if (status is String) {
          erlStatusId = status;
        } else if (status is bool) {
          erlStatusId = status.toString();
        }

        if (erlStatusId == 'true') {
          List<dynamic> puzzleArray = data['data'];
          setState(() {
            idProduct =
                puzzleArray.map<String>((item) => item['galery_idx']).toList();
            kategoriProduct = puzzleArray
                .map<String>((item) => item['galery_kategori_puzzle'])
                .toList();
            bannerImages = puzzleArray
                .map<String>((item) => item['galery_title_puzzle'])
                .toList();
            productUrls = puzzleArray
                .map<String>((item) => item['galery_cover_puzzle'])
                .toList();
            narationSound = puzzleArray
                .map<String>((item) => item['galery_audio_puzzle'])
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            erlStatusId = 'Error: $erlStatusId';
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        setState(() {
          erlStatusId = 'Error: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        erlStatusId =
            'Failed to load data. Status code: ${response.statusCode}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          onPressed: _onFilterPressed,
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bannerImages.isEmpty
              ? Center(child: Text('Periksa Koneksi Internet'))
              : ListView.builder(
                  itemCount:
                      (bannerImages.length / 2).ceil(), // Hitung jumlah baris
                  itemBuilder: (context, rowIndex) {
                    int firstIndex = rowIndex * 2;
                    int secondIndex = firstIndex + 1;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EightTilePuzzle(
                                      myurl: productUrls[firstIndex],
                                      naratorSound: narationSound[firstIndex],
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Image.network(
                                      productUrls[firstIndex],
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.broken_image,
                                          size: 100,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${bannerImages[firstIndex]}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (secondIndex < bannerImages.length)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EightTilePuzzle(
                                        myurl: productUrls[secondIndex],
                                        naratorSound:
                                            narationSound[secondIndex],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.network(
                                        productUrls[secondIndex],
                                        fit: BoxFit.cover,
                                        height: 200,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.broken_image,
                                            size: 100,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${bannerImages[secondIndex]}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                                child:
                                    SizedBox()), // Kolom kosong jika tidak ada data
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
