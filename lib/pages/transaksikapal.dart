import 'package:flutter/material.dart';

// Model untuk pesanan
class Order {
  final String id;
  final String userName;
  final String route;
  final String schedule;
  final double price;
  bool isApproved;
  bool isPaid;

  Order({
    required this.id,
    required this.userName,
    required this.route,
    required this.schedule,
    required this.price,
    this.isApproved = false,
    this.isPaid = false,
  });
}

class TransaksiKapalPage extends StatefulWidget {
  @override
  _TransaksiKapalPageState createState() => _TransaksiKapalPageState();
}

class _TransaksiKapalPageState extends State<TransaksiKapalPage> {
  // Daftar pesanan (dummy data)
  List<Order> orders = [
    Order(id: '1', userName: 'John Doe', route: 'Tomok - Ajibata', schedule: '2024-05-15 09:00', price: 150000, isPaid: true),
    Order(id: '2', userName: 'Jane Smith', route: 'Tomok - Ajibata', schedule: '2024-05-16 10:00', price: 150000, isPaid: true),
    Order(id: '3', userName: 'Alice Johnson', route: 'Tomok - Ajibata', schedule: '2024-05-17 11:00', price: 150000, isPaid: false),
    Order(id: '4', userName: 'Bob Williams', route: 'Tomok - Ajibata', schedule: '2024-05-18 12:00', price: 150000, isPaid: false),
    Order(id: '5', userName: 'Eve Brown', route: 'Tomok - Ajibata', schedule: '2024-05-19 13:00', price: 150000, isPaid: false),
  ];

  // Pesanan yang dipilih untuk ditampilkan formulir transaksi
  Order? selectedOrder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi Kapal'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Teks di bagian paling atas halaman dengan ikon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, color: Colors.blueAccent, size: 28),
                SizedBox(width: 10),
                Text(
                  'Halaman Kelola Pesanan Tiket',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text('Nama: ${orders[index].userName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rute: ${orders[index].route}'),
                          Text('Jadwal: ${orders[index].schedule}'),
                          Text('Harga: Rp ${orders[index].price.toStringAsFixed(0)}'),
                          Text('Status Pembayaran: ${orders[index].isPaid ? 'Dibayar' : 'Belum Dibayar'}', style: TextStyle(color: orders[index].isPaid ? Colors.green : Colors.red)),
                        ],
                      ),
                      trailing: orders[index].isApproved
                          ? orders[index].isPaid
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                        onPressed: () {
                          // Menandai pesanan sebagai dibayar
                          setState(() {
                            orders[index].isPaid = true;
                          });
                        },
                        child: Text('Tandai Bayar'),
                      )
                          : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            orders[index].isApproved = true;
                            selectedOrder = orders[index];
                          });
                        },
                        child: Text('Setujui'),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedOrder != null) _buildTransactionForm(selectedOrder!)
          ],
        ),
      ),
    );
  }

  // Metode untuk membangun formulir transaksi
  Widget _buildTransactionForm(Order order) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasil Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Nama: ${order.userName}'),
            Text('Rute: ${order.route}'),
            Text('Jadwal: ${order.schedule}'),
            Text('Harga: Rp ${order.price.toStringAsFixed(0)}'),
            Text('Status Pembayaran: ${order.isPaid ? 'Dibayar' : 'Belum Dibayar'}'),
            SizedBox(height: 20),
            if (!order.isPaid)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Tambahkan logika penyimpanan transaksi di sini
                  },
                  icon: Icon(Icons.save),
                  label: Text('Simpan Transaksi'),
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
    home: TransaksiKapalPage(),
  ));
}
