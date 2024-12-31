import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tes/view/eight_tile.dart';
import 'package:tes/widgets/sound_controller.dart';

bool isLoading = true;
bool isConnected = false;
bool showNoConnectionMessage = false;

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
  String erlStatusId = '';
  List<Map<String, String>> categories = [];
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadBannerData('');
    _loadCategories();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    setState(() {
      isLoading = true;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      if (connectivityResult.toString() == "[ConnectivityResult.none]") {
        isConnected = false;
      } else {
        isConnected = true;
      }

      isLoading = false;
    });

    if (isConnected) {
      setState(() {
        isConnected = true;
      });
      _reloadPage();
    } else {
      setState(() {
        isConnected = false;
        _reloadPage();
      });
    }
  }

  void _reloadPage() {
    setState(() {
      // Logika memuat ulang data, contoh:
      bannerImages = [];
      _loadBannerData('');
      _loadCategories();
    });
    print("Page reloaded!");
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
    if (isLoading) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Pilih Kategori',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          content: kategoriXProduct.isEmpty
              ? const Center(
                  child: Text(
                    'Periksa Koneksi Internet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(kategoriXProduct.length, (index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                            title: Text(
                              kategoriXProduct[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              _loadBannerData(idXProduct[index]);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final myAppBar = AppBar(
      centerTitle: true,
      title: const Text(
        'EIGHT TILE PUZZLE',
        style: TextStyle(
          color: Colors.white,
          fontFamily: "ComicSans",
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
      leading: IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.white),
        onPressed: _onFilterPressed,
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
      backgroundColor: Colors.purple,
      elevation: 4,
    );

    final bodyHeight = mediaQueryHeight -
        myAppBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: myAppBar,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade100, Colors.purple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : !isConnected
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No Internet Connection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'ComicSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await _checkInternetConnection();
                              if (isConnected) {
                                await _loadBannerData('');
                                await _loadCategories();
                              }
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: (bannerImages.length / 2).ceil(),
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EightTilePuzzle(
                                          myurl: productUrls[firstIndex],
                                          naratorSound:
                                              narationSound[firstIndex],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                productUrls[firstIndex],
                                                fit: BoxFit.cover,
                                                // height: 200,
                                                height: bodyHeight * 0.3,
                                                width: double.infinity,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                    Icons.broken_image,
                                                    size: 100,
                                                    color: Colors.grey,
                                                  );
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 8,
                                              right: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '${kategoriProduct[firstIndex]}',
                                                  style: TextStyle(
                                                    color: Colors.purple,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '${bannerImages[firstIndex]}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple.shade700,
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
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.network(
                                                  productUrls[secondIndex],
                                                  fit: BoxFit.cover,
                                                  height: bodyHeight * 0.3,
                                                  width: double.infinity,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Icon(
                                                      Icons.broken_image,
                                                      size: 100,
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 8,
                                                right: 8,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    '${kategoriProduct[secondIndex]}',
                                                    style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${bannerImages[secondIndex]}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Expanded(child: SizedBox()),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
