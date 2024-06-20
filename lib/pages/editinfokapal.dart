import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

class Info {
  final int id;
  final String penjelasan;

  Info({required this.id, required this.penjelasan});

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      id: json['id'],
      penjelasan: json['penjelasan'],
    );
  }
}

class EditInfoPage extends StatefulWidget {
  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  TextEditingController _penjelasanController = TextEditingController();
  late Future<List<Info>> _infoList;
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    _infoList = fetchInfos();
  }

  Future<List<Info>> fetchInfos() async {
    final response = await http.get(Uri.parse('http://localhost:9090/get-all-info'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Info.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load infos: ${response.statusCode}');
    }
  }

  Future<void> saveInfo() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:9090/save-info'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'penjelasan': _penjelasanController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Data info berhasil disimpan
        print('Info berhasil disimpan');
        // Refresh daftar info setelah penyimpanan
        setState(() {
          _infoList = fetchInfos();
        });
      } else {
        // Gagal menyimpan data info
        throw Exception('Failed to save info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to save info: $e');
    }
  }

  Future<void> updateInfo(int id, String newPenjelasan) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:9090/update-info'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': id,
          'penjelasan': newPenjelasan,
        }),
      );

      if (response.statusCode == 200) {
        // Data info berhasil diupdate
        print('Info berhasil diupdate');
        // Refresh daftar info setelah pembaruan
        setState(() {
          _infoList = fetchInfos();
        });
      } else {
        // Gagal mengupdate data info
        throw Exception('Failed to update info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update info: $e');
    }
  }

  Future<void> updateInfoDialog(BuildContext context, int id, String currentPenjelasan) async {
    TextEditingController _newPenjelasanController = TextEditingController(text: currentPenjelasan);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Info'),
          content: TextField(
            controller: _newPenjelasanController,
            decoration: InputDecoration(
              labelText: 'New Penjelasan',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateInfo(id, _newPenjelasanController.text).catchError((error) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text(error.toString()),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [
      'assets/images/kapalpanjang.jpg',
      'assets/images/dosroha3.jpg',
      'assets/images/kapal4.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Informasi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks di atas carousel
            Text(
              'Halaman Informasi Tomok Ajibata',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Carousel di bagian paling atas
            CarouselSlider(
              items: imgList.map((item) => Container(
                child: Center(
                  child: Image.asset(item, fit: BoxFit.cover, width: 1000),
                ),
              )).toList(),
              carouselController: _controller,
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            // Form untuk menyimpan data info
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _penjelasanController,
                      decoration: InputDecoration(
                        labelText: 'Penjelasan',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                    ),
                    SizedBox(height: 20),
                    // Tombol simpan
                    ElevatedButton(
                      onPressed: () {
                        saveInfo().catchError((error) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error'),
                              content: Text(error.toString()),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                      child: Text('Simpan Info'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Daftar info yang sudah tersimpan
            FutureBuilder<List<Info>>(
              future: _infoList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Info:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Info info = snapshot.data![index];
                          return ListTile(
                            title: Text(info.penjelasan),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                updateInfoDialog(context, info.id, info.penjelasan);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return Text("No data available");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Edit Informasi Page',
    home: EditInfoPage(),
  ));
}
