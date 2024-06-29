import 'package:car_rent_flutter/generated/cars.pbgrpc.dart';
import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/widgets/car_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cfire;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart' as grpc;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final db = cfire.FirebaseFirestore.instance;
  final channel = grpc.ClientChannel(
    '10.0.2.2',
    port: 4000,
    options: const grpc.ChannelOptions(
      credentials: grpc.ChannelCredentials.insecure(),
    ),
  );
  late ChromaServiceClient stub;
  TextEditingController _searchController = TextEditingController();
  late String _searchQuery = '';
  List<CarListing> _searchResults = [];

  @override
  void initState() {
    super.initState();
    stub = ChromaServiceClient(channel);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    List<CarListing> result = [];
    try {
      var res = await stub.searchCars(Query(query: _searchQuery));
      print('Search results: ${res.ids}');

      // Assuming res.ids[0] contains the concatenated IDs
      var concatenatedIds = res.ids[0];
      var ids = concatenatedIds.split(',');

      for (var id in ids) {
        print("id: $id");
        var snapshot = await db.collection('car_listings').doc(id).get();
        if (snapshot.exists) {
          var data = snapshot.data();
          if (data != null) {
            result.add(CarListing.fromSnap(snapshot));
          } else {
            print('No data found for ID: $id');
          }
        } else {
          print('Document does not exist for ID: $id');
        }
      }
      setState(() {
        print(result);
        _searchResults = result;
        print(_searchResults);
      });
    } catch (e) {
      print('Error searching: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: [
          IconButton(
            onPressed: () async {
              await _performSearch();
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter search query',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) async {
                await _performSearch();
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        var carData = _searchResults[index];
                        return FutureBuilder<cfire.DocumentSnapshot>(
                          future: db
                              .collection('users')
                              .doc(carData.sellerID)
                              .get(),
                          builder: (context, sellerSnapshot) {
                            if (sellerSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(); // Placeholder widget while loading
                            } else if (sellerSnapshot.hasError) {
                              return const Text(
                                  'Error loading sesller details');
                            } else if (!sellerSnapshot.hasData ||
                                !sellerSnapshot.data!.exists) {
                              return const Text('Seller details unavailable');
                            } else {
                              var sellerDoc = sellerSnapshot.data!;
                              var sellerEmail = sellerDoc['email'];
                              var personRating = sellerDoc['rating'].toString();
                              var sellerPhoneNumber = sellerDoc['phoneNumber'];
                              return CarCard(
                                car: carData,
                                sellerEmail: sellerEmail,
                                personRating: double.parse(personRating),
                                sellerPhoneNumber: sellerPhoneNumber,
                                profile: false,
                              );
                            }
                          },
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
