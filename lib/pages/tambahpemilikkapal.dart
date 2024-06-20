import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model untuk pemilik kapal
class ShipOwner {
  String id;
  String name;
  String address;
  String phoneNumber;
  int numberOfShips;

  ShipOwner({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.numberOfShips,
  });

  factory ShipOwner.fromJson(Map<String, dynamic> json) {
    return ShipOwner(
      id: json['id'].toString(),
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      numberOfShips: json['number_of_ships'],
    );
  }
}

class TambahPemilikKapalPage extends StatefulWidget {
  @override
  _TambahPemilikKapalPageState createState() => _TambahPemilikKapalPageState();
}

class _TambahPemilikKapalPageState extends State<TambahPemilikKapalPage> {
  List<ShipOwner> shipOwners = [];

  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _numberOfShipsController = TextEditingController();

  bool isEditing = false;
  String editingId = '';

  @override
  void initState() {
    super.initState();
    fetchShipOwners();
  }

  Future<void> fetchShipOwners() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8080/shipowners'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        shipOwners = jsonResponse.map((data) => ShipOwner.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load ship owners');
    }
  }

  Future<void> addShipOwner() async {
    String name = _nameController.text;
    String address = _addressController.text;
    String phoneNumber = _phoneNumberController.text;
    int numberOfShips = int.tryParse(_numberOfShipsController.text) ?? 0;

    if (name.isNotEmpty && address.isNotEmpty && phoneNumber.isNotEmpty && numberOfShips > 0) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8080/shipowners'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'address': address,
          'phone_number': phoneNumber,
          'number_of_ships': numberOfShips,
        }),
      );

      if (response.statusCode == 200) {
        _nameController.clear();
        _addressController.clear();
        _phoneNumberController.clear();
        _numberOfShipsController.clear();
        fetchShipOwners();
      } else {
        throw Exception('Failed to add ship owner');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Peringatan'),
            content: Text('Semua field harus diisi dan jumlah kapal harus lebih dari 0.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> editShipOwner() async {
    String name = _nameController.text;
    String address = _addressController.text;
    String phoneNumber = _phoneNumberController.text;
    int numberOfShips = int.tryParse(_numberOfShipsController.text) ?? 0;

    if (name.isNotEmpty && address.isNotEmpty && phoneNumber.isNotEmpty && numberOfShips > 0) {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8080/shipowners/$editingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'address': address,
          'phone_number': phoneNumber,
          'number_of_ships': numberOfShips,
        }),
      );

      if (response.statusCode == 200) {
        _nameController.clear();
        _addressController.clear();
        _phoneNumberController.clear();
        _numberOfShipsController.clear();
        setState(() {
          isEditing = false;
        });
        fetchShipOwners();
      } else {
        throw Exception('Failed to edit ship owner');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Peringatan'),
            content: Text('Semua field harus diisi dan jumlah kapal harus lebih dari 0.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> deleteShipOwner(String id) async {
    final response = await http.delete(Uri.parse('http://127.0.0.1:8080/shipowners/$id'));
    if (response.statusCode == 200) {
      fetchShipOwners();
    } else {
      throw Exception('Failed to delete ship owner');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Pemilik Kapal' : 'Tambah Pemilik Kapal'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_boat, color: Colors.blueAccent, size: 28),
                SizedBox(width: 10),
                Text(
                  'PEMILIK KAPAL',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama', prefixIcon: Icon(Icons.person)),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Alamat', prefixIcon: Icon(Icons.home)),
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Nomor Telepon', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _numberOfShipsController,
              decoration: InputDecoration(labelText: 'Jumlah Kapal', prefixIcon: Icon(Icons.directions_boat)),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: isEditing ? editShipOwner : addShipOwner,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Simpan' : 'Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: shipOwners.length,
                itemBuilder: (context, index) {
                  final owner = shipOwners[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.directions_boat, color: Colors.blueAccent),
                      title: Text(owner.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alamat: ${owner.address}'),
                          Text('Nomor Telepon: ${owner.phoneNumber}'),
                          Text('Jumlah Kapal: ${owner.numberOfShips}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Color.fromARGB(255, 29, 189, 8)),
                            onPressed: () {
                              setState(() {
                                _nameController.text = owner.name;
                                _addressController.text = owner.address;
                                _phoneNumberController.text = owner.phoneNumber;
                                _numberOfShipsController.text = owner.numberOfShips.toString();
                                isEditing = true;
                                editingId = owner.id;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteShipOwner(owner.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
    home: TambahPemilikKapalPage(),
  ));
}
