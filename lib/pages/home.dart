import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tomok-Ajibata Tour',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _kapalList = [];
  final TextEditingController _kapalController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  int? _editingIndex;
  int jumlahNahkoda = 0;
  int jumlahPemilikKapal = 0;

  @override
  void initState() {
    super.initState();
    _fetchKapalList();
    _fetchJumlahNahkoda().then((jumlah) {
      setState(() {
        jumlahNahkoda = jumlah;
      });
    });
    _fetchJumlahPemilikKapal().then((jumlah) {
      setState(() {
        jumlahPemilikKapal = jumlah;
      });
    });
  }

  Future<void> _fetchKapalList() async {
    final response = await http.get(Uri.parse('http://localhost:9010/get-all-kapal'));
    if (response.statusCode == 200) {
      final List<dynamic> kapalData = json.decode(response.body);
      setState(() {
        _kapalList.clear();
        _kapalList.addAll(kapalData.map((data) => {
          'id': data['id'],
          'name': data['nama'],
          'deskripsi': data['deskripsi'],
        }).toList());
      });
    } else {
      print('Failed to load kapal');
    }
  }

  Future<int> _fetchJumlahNahkoda() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:9008/get-all-nahkoda'));
      if (response.statusCode == 200) {
        final List<dynamic> nahkodaData = json.decode(response.body);
        return nahkodaData.length;
      } else {
        print('Failed to load nahkoda');
        return 0;
      }
    } catch (e) {
      print('Error fetching jumlah nahkoda: $e');
      return 0;
    }
  }

  Future<int> _fetchJumlahPemilikKapal() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8080/shipowners'));
      if (response.statusCode == 200) {
        final List<dynamic> pemilikKapalData = json.decode(response.body);
        return pemilikKapalData.length;
      } else {
        print('Failed to load pemilik kapal');
        return 0;
      }
    } catch (e) {
      print('Error fetching jumlah pemilik kapal: $e');
      return 0;
    }
  }

  Future<void> _addOrEditKapal() async {
    if (_kapalController.text.isEmpty || _deskripsiController.text.isEmpty) return;

    final Map<String, String> kapalData = {
      'nama': _kapalController.text,
      'deskripsi': _deskripsiController.text,
      'pemilik_kapal_id': '1', // Example ID, replace with real data
    };

    if (_editingIndex == null) {
      final response = await http.post(
        Uri.parse('http://localhost:9010/create-kapal'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(kapalData),
      );

      if (response.statusCode == 200) {
        final newKapal = json.decode(response.body);
        setState(() {
          _kapalList.add({
            'id': newKapal['id'],
            'name': kapalData['nama'],
            'deskripsi': kapalData['deskripsi'],
          });
        });
        _showToast('Data berhasil ditambah');
      }
    } else {
      final kapalId = _kapalList[_editingIndex!]['id'];
      final response = await http.put(
        Uri.parse('http://localhost:9010/update-kapal'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': kapalId, ...kapalData}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _kapalList[_editingIndex!] = {
            'id': kapalId,
            'name': kapalData['nama'],
            'deskripsi': kapalData['deskripsi'],
          };
          _editingIndex = null;
        });
        _showToast('Data berhasil diubah');
      }
    }

    _kapalController.clear();
    _deskripsiController.clear();
  }

  void _editKapal(int index) {
    setState(() {
      _kapalController.text = _kapalList[index]['name'];
      _deskripsiController.text = _kapalList[index]['deskripsi'];
      _editingIndex = index;
    });
  }

  Future<void> _deleteKapal(int index) async {
    final kapalId = _kapalList[index]['id'];
    final response = await http.delete(
      Uri.parse('http://localhost:9010/delete-kapal/$kapalId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _kapalList.removeAt(index);
      });
      _showToast('Data berhasil dihapus');
    } else {
      print('Failed to delete kapal');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showSuccessAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int jumlahKapal = _kapalList.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tomok-Ajibata Tour'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/profile.jpeg'), // Replace with admin profile image
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Informasi Kapal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/editKapal');
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Transaksi Kapal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/transaksiKapal');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Tambah Pemilik Kapal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tambahPemilikKapal');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_pin),
              title: Text('Tambah Nahkoda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tambahNahkoda');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Admin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDashboardCard(
                    context,
                    'Jumlah Kapal',
                    jumlahKapal.toString(),
                    Colors.blue,
                    Icons.directions_boat,
                  ),
                  _buildDashboardCard(
                    context,
                    'Jumlah Nahkoda',
                    jumlahNahkoda.toString(),
                    Colors.green,
                    Icons.person,
                  ),
                  _buildDashboardCard(
                    context,
                    'Jumlah Pemilik Kapal',
                    jumlahPemilikKapal.toString(),
                    Colors.orange,
                    Icons.person_pin,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Kapal Tomok Ajibata',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _kapalController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nama Kapal',
                        prefixIcon: Icon(Icons.directions_boat),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Deskripsi',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _addOrEditKapal,
                    icon: Icon(_editingIndex == null ? Icons.add : Icons.edit),
                    label: Text(_editingIndex == null ? 'Add' : 'Save'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _kapalList.length,
                itemBuilder: (context, index) {
                  final kapal = _kapalList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Icon(Icons.directions_boat, color: Colors.blue),
                      title: Text(kapal['name']),
                      subtitle: Text(kapal['deskripsi']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _editKapal(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteKapal(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String count, Color color, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 50, color: Colors.white),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            count,
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
