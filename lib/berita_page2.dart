import 'package:flutter/material.dart';
import 'package:flutter_news_app/api.dart';
import 'package:flutter_news_app/detail_berita.dart';
import 'package:flutter_news_app/model/res_berita.dart';
import 'package:http/http.dart' as http;

class BeritaPage extends StatefulWidget {
  static const String routeName = '/berita_page';
  const BeritaPage({super.key});

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  bool isLoading = false;
  List<Berita> listBerita = [];
  List<Berita> filteredBerita = []; // Menambahkan list untuk hasil pencarian

  Future<void> getBerita() async {
    try {
      setState(() {
        isLoading = true;
      });
      http.Response res = await http.get(Uri.parse("${baseUrl}getBerita.php"));
      List<Berita>? data = resBeritaFromJson(res.body).data;
      setState(() {
        isLoading = false;
        listBerita = data ?? [];
        filteredBerita = listBerita; // Inisialisasi filtered list dengan semua berita
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  // Fungsi untuk melakukan pencarian
  void searchBerita(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBerita = listBerita; // Jika query kosong, tampilkan semua berita
      } else {
        filteredBerita = listBerita
            .where((berita) =>
                berita.judul?.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList(); // Filter berita berdasarkan judul
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getBerita();
  }

  TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextFormField(
                    controller: search,
                    onChanged: (value) {
                      searchBerita(value); // Panggil fungsi search saat text berubah
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.orange.withOpacity(0.2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredBerita.isEmpty
                      ? const Center(
                          child: Text('Tidak ada berita yang ditemukan'),
                        )
                      : ListView.builder(
                          itemCount: filteredBerita.length, // Gunakan filtered list
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, DetailBerita.routeName,
                                      arguments: filteredBerita[index]); // Gunakan filtered list
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        '$imageUrl${filteredBerita[index].gambarBerita}',
                                        height: 250,
                                        width: MediaQuery.of(context).size.width,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      ListTile(
                                        title: Text(
                                          '${filteredBerita[index].judul}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}