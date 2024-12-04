import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

void saveTemplateData() async {
  // Data yang akan disimpan dalam Firestore
  List<Map<String, dynamic>> data = [
    {
      "id": "4HP5hbmX4JDWawnvvh23",
      "name": "Bisnis",
      "type": "Income",
      "icon": 57627,
      "parentId": null
    },
    {
      "id": "4ZK7R3vpGor5d9qH2ya3",
      "name": "Layanan Streaming",
      "icon": 58904,
      "parentId": "YWuUnti9KA10pS3QowF6",
      "type": "Expense"
    },
    {
      "id": "8HOF64lOwjQcmCr32tMa",
      "icon": 57946,
      "name": "Makanan & Minuman",
      "type": "Expense",
      "parentId": null
    },
    {
      "id": "8ISMCTyP49KRyaTmXNew",
      "parentId": "nYV2j5P7k1DmfcCn1zmq",
      "name": "Tagihan Listrik / Token",
      "type": "Expense",
      "icon": 58452
    },
    {
      "id": "9zxDoKY0nmQ1lGQlQrbQ",
      "parentId": null,
      "icon": 57434,
      "name": "Belanja",
      "type": "Expense"
    },
    {
      "id": "Bdwhsv1Mpp8fAcGuKLDI",
      "name": "Lainnya",
      "type": "Income",
      "parentId": null,
      "icon": 58359
    },
    {
      "id": "DImA6h3CX4PLqRV7KrVO",
      "icon": 59050,
      "type": "Expense",
      "name": "Game",
      "parentId": "YWuUnti9KA10pS3QowF6"
    },
    {
      "id": "DJePtyFQ43oxPvWPFwuE",
      "parentId": "YWuUnti9KA10pS3QowF6",
      "icon": 58009,
      "name": "Liburan",
      "type": "Expense"
    },
    {
      "id": "EyKeKfWWpj9bqEHhKdqk",
      "icon": 57662,
      "parentId": "V3dHh3uAOkG5F693EeNj",
      "name": "Hadiah atau Giveaway",
      "type": "Income"
    },
    {
      "id": "IyD9NZ0nYLxYSQCkaSPX",
      "type": "Income",
      "name": "Freelance",
      "icon": 58217,
      "parentId": "V3dHh3uAOkG5F693EeNj"
    },
    {
      "id": "MKcOaTY0egGRXrE21c0p",
      "name": "Lainnya",
      "type": "Expense",
      "icon": 58370,
      "parentId": null
    },
    {
      "id": "NC2F0ALlipJpxLdEeVrr",
      "name": "Bensin Kendaraan",
      "type": "Expense",
      "parentId": "Yz2K6WFDQvOGkM38tKE2",
      "icon": 58378
    },
    {
      "id": "Q7mjlPxpJ9ZxKCEQOtHl",
      "icon": 58780,
      "type": "Expense",
      "parentId": "9zxDoKY0nmQ1lGQlQrbQ",
      "name": "Keperluan Rumah"
    },
    {
      "id": "SFyOTLDQOyzGVAOb4KuR",
      "type": "Expense",
      "parentId": "nYV2j5P7k1DmfcCn1zmq",
      "name": "Tagihan Air",
      "icon": 984482
    },
    {
      "id": "Sf6CSBU6UDF6MN3HI9ks",
      "type": "Income",
      "icon": 58313,
      "parentId": null,
      "name": "Gaji"
    },
    {
      "id": "V3dHh3uAOkG5F693EeNj",
      "parentId": null,
      "type": "Income",
      "icon": 58498,
      "name": "Pendapatan Tambahan"
    },
    {
      "id": "YWuUnti9KA10pS3QowF6",
      "icon": 58247,
      "type": "Expense",
      "name": "Hiburan",
      "parentId": null
    },
    {
      "id": "YsQhRcnYIGbhfKWbzW4H",
      "icon": 58997,
      "name": "Transportasi Umum",
      "type": "Expense",
      "parentId": "Yz2K6WFDQvOGkM38tKE2"
    },
    {
      "id": "Yz2K6WFDQvOGkM38tKE2",
      "type": "Expense",
      "icon": 57813,
      "parentId": null,
      "name": "Transportasi"
    },
    {
      "id": "aivYZNgYTVvtB4r1LFxC",
      "icon": 58805,
      "name": "Tagihan Internet",
      "parentId": "nYV2j5P7k1DmfcCn1zmq",
      "type": "Expense"
    },
    {
      "id": "bzJMmmZWyFuduioYAxzi",
      "name": "Bonus",
      "parentId": "Sf6CSBU6UDF6MN3HI9ks",
      "icon": 57662,
      "type": "Income"
    },
    {
      "id": "eHfNKurwz9lFd4wNUgal",
      "name": "Keperluan Pribadi",
      "icon": 57650,
      "parentId": "9zxDoKY0nmQ1lGQlQrbQ",
      "type": "Expense"
    },
    {
      "id": "gkOPPZDf27cOTgzi6jlN",
      "type": "Income",
      "parentId": "4HP5hbmX4JDWawnvvh23",
      "icon": 58715,
      "name": "Hasil Investasi"
    },
    {
      "id": "lpNeqH0z1WWzWs4dcavb",
      "name": "Tunjangan",
      "type": "Income",
      "parentId": "Sf6CSBU6UDF6MN3HI9ks",
      "icon": 59122
    },
    {
      "id": "nYV2j5P7k1DmfcCn1zmq",
      "type": "Expense",
      "icon": 58636,
      "name": "Tagihan",
      "parentId": null
    },
    {
      "id": "nywNkp76xzy8m34jL6C5",
      "parentId": "Sf6CSBU6UDF6MN3HI9ks",
      "name": "Gaji Bulanan",
      "type": "Income",
      "icon": 985051
    },
    {
      "id": "qBJOkWwx9yxeibYPuAKy",
      "icon": 58736,
      "name": "Keuntungan Penjualan",
      "parentId": "4HP5hbmX4JDWawnvvh23",
      "type": "Income"
    },
    {
      "id": "zITLLeJ7FYcXSK8DAiGY",
      "parentId": "V3dHh3uAOkG5F693EeNj",
      "icon": 984424,
      "name": "Jual Barang Bekas",
      "type": "Income"
    }
  ];

  // Referensi ke koleksi Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  // Menyimpan data ke koleksi "categories"
  for (var item in data) {
    await firestore
        .collection('users/$uid/categories')
        .doc(item['id'])
        .set(item);
  }

  // Membuat collection wallets kosong dan

  debugPrint('Data berhasil disimpan ke Firestore');
}
