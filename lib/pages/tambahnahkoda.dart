import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahNahkodaPage extends StatefulWidget {
  @override
  _TambahNahkodaPageState createState() => _TambahNahkodaPageState();
}

class _TambahNahkodaPageState extends State<TambahNahkodaPage> {
  List<Map<String, dynamic>> nahkodaList = [];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNahkodaList();
  }

  Future<void> fetchNahkodaList() async {
    final response = await http.get(Uri.parse('http://localhost:9008/get-all-nahkoda'));

    if (response.statusCode == 200) {
      setState(() {
        nahkodaList = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      // Handle error
    }
  }

  Future<void> addNahkoda(String name, String phone, String gender) async {
    final response = await http.post(
      Uri.parse('http://localhost:9008/add-nahkoda'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nama': name,
        'nomor_hp': phone,
        'jenis_kelamin': gender,
      }),
    );

    if (response.statusCode == 201) {
      fetchNahkodaList();
    } else {
      // Handle error
      print('Failed to add nahkoda: ${response.body}');
    }
  }

  Future<void> editNahkoda(int id, String name, String phone, String gender) async {
    final response = await http.put(
      Uri.parse('http://localhost:9008/edit-nahkoda/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nama': name,
        'nomor_hp': phone,
        'jenis_kelamin': gender,
      }),
    );

    if (response.statusCode == 200) {
      fetchNahkodaList();
    } else {
      // Handle error
      print('Failed to edit nahkoda: ${response.body}');
    }
  }

  Future<void> deleteNahkoda(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:9008/delete-nahkoda/$id'),
    );

    if (response.statusCode == 200) {
      fetchNahkodaList();
    } else {
      // Handle error
      print('Failed to delete nahkoda: ${response.body}');
    }
  }

  void _showAddNahkodaDialog() {
    _nameController.clear();
    _phoneController.clear();
    _genderController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Nahkoda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Nahkoda'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Nomor HP'),
              ),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Jenis Kelamin'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty &&
                    _genderController.text.isNotEmpty) {
                  addNahkoda(_nameController.text, _phoneController.text, _genderController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditNahkodaDialog(int id, int index) {
    _nameController.text = nahkodaList[index]['nama'];
    _phoneController.text = nahkodaList[index]['nomor_hp'];
    _genderController.text = nahkodaList[index]['jenis_kelamin'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Nahkoda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Nahkoda'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Nomor HP'),
              ),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Jenis Kelamin'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty &&
                    _genderController.text.isNotEmpty) {
                  editNahkoda(
                    id,
                    _nameController.text,
                    _phoneController.text,
                    _genderController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Nahkoda'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks di bagian paling atas dengan ikon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.anchor, color: Colors.blueAccent, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Data Nahkoda',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: nahkodaList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(nahkodaList[index]['nama'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nomor HP: ${nahkodaList[index]['nomor_hp']}'),
                          Text('Jenis Kelamin: ${nahkodaList[index]['jenis_kelamin']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditNahkodaDialog(nahkodaList[index]['id'], index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteNahkoda(nahkodaList[index]['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Tambah Nahkoda'),
                onPressed: _showAddNahkodaDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TambahNahkodaPage(),
  ));
}
