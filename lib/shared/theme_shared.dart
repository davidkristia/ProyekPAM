import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _kapalList = [];
  final TextEditingController _kapalController = TextEditingController();
  int? _editingIndex;
  String? _selectedImagePath;

  void _addOrEditKapal() {
    if (_kapalController.text.isEmpty || _selectedImagePath == null) return;

    if (_editingIndex == null) {
      setState(() {
        _kapalList.add({
          'name': _kapalController.text,
          'image': _selectedImagePath,
        });
      });
    } else {
      setState(() {
        _kapalList[_editingIndex!] = {
          'name': _kapalController.text,
          'image': _selectedImagePath,
        };
        _editingIndex = null;
      });
    }
    _kapalController.clear();
    _selectedImagePath = null;
  }

  void _editKapal(int index) {
    setState(() {
      _kapalController.text = _kapalList[index]['name'];
      _selectedImagePath = _kapalList[index]['image'];
      _editingIndex = index;
    });
  }

  void _deleteKapal(int index) {
    setState(() {
      _kapalList.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int jumlahKapal = _kapalList.length;
    int jumlahNahkoda = 10; // Example data, replace with real data
    int jumlahPemilikKapal = 5; // Example data, replace with real data

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
                    backgroundImage: AssetImage('assets/profile.jpeg'), // Replace with admin profile image
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
        child: Container(
          color: Colors.lightBlue[100], // Background color
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
                  'CRUD Kapal Tomok Ajibata',
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
                    ElevatedButton.icon(
                      onPressed: _addOrEditKapal,
                      icon: Icon(_editingIndex == null ? Icons.add : Icons.edit),
                      label: Text(_editingIndex == null ? 'Add' : 'Edit'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _selectedImagePath == null
                    ? Container()
                    : Image.file(
                        File(_selectedImagePath!),
                        height: 150,
                      ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Pilih Gambar'),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _kapalList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.primaries[index % Colors.primaries.length].shade100,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: _kapalList[index]['image'] != null
                            ? Image.file(
                                File(_kapalList[index]['image']),
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.directions_boat, size: 50),
                        title: Text(_kapalList[index]['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editKapal(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
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
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String count, Color color, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width / 3) - 24, // Adjust the width to fit three cards in one row with spacing
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color), // Made icon size smaller to fit the smaller card
          SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color), // Made font size smaller
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color), // Made font size smaller
          ),
        ],
      ),
    );
  }
}
