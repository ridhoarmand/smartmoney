import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Fungsi filter transaksi
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Saldo Total
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).cardColor,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo Total', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Rp 2,500,000',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pemasukan',
                        style: TextStyle(fontSize: 14, color: Colors.green)),
                    Text('Rp 3,000,000', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Pengeluaran',
                        style: TextStyle(fontSize: 14, color: Colors.red)),
                    Text('Rp 500,000', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          // List Transaksi
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Misalnya ada 10 transaksi
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  title: Text('Transaksi #$index'),
                  subtitle: const Text('15 Nov 2024 • Kategori: Belanja'),
                  trailing: Text(
                    index % 2 == 0 ? '+ Rp 500,000' : '- Rp 250,000',
                    style: TextStyle(
                      color: index % 2 == 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Tampilkan detail transaksi
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi untuk menambah transaksi baru
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
