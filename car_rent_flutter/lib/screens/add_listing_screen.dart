import 'dart:typed_data';

import 'package:car_rent_flutter/generated/cars.pbgrpc.dart';
import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/models/user.dart';
import 'package:car_rent_flutter/screens/location_popup.dart';
import 'package:car_rent_flutter/screens/map_screen.dart';
import 'package:car_rent_flutter/utils/firebase_manager.dart';
import 'package:car_rent_flutter/utils/utils.dart';
import 'package:car_rent_flutter/widgets/car_card.dart';
import 'package:car_rent_flutter/widgets/text_field_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:datepicker_dropdown/order_format.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:grpc/grpc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final channel = ClientChannel(
    '10.0.2.2',
    port: 4000,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );
  late ChromaServiceClient stub;
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late GeoFirePoint _geoFirePoint;
  final TextEditingController _rateController = TextEditingController();
  String _selectedYear = "2024";
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final FirebaseStorage store = FirebaseStorage.instance;

  Future<String> uploadImageToStorage(
      String childName, Uint8List file, String id) async {
    try {
      print('Uploading image...');
      Reference ref = store
          .ref()
          .child(childName)
          .child(FirebaseManager.instance.user.uid)
          .child(id);
      UploadTask utask = ref.putData(file);
      TaskSnapshot snap = await utask;
      String downloadUrl = await snap.ref.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.message}');
      return 'Failed to upload image: ${e.message}';
    } catch (e) {
      print('Exception: ${e.toString()}');
      return 'Failed to upload image: ${e.toString()}';
    }
  }

  _selectImage(BuildContext context) async {
    Uint8List? file = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Create Post"),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Take a photo"),
              onPressed: () async {
                Navigator.of(context).pop(await pickImage(ImageSource.camera));
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Choose from gallery"),
              onPressed: () async {
                Navigator.of(context).pop(await pickImage(ImageSource.gallery));
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      },
    );
    setState(() {
      _file = file;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stub = ChromaServiceClient(channel);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _file = null;
    _brandController.dispose();
    _modelController.dispose();
    _descriptionController.dispose();
    channel.shutdown();
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void clearFields() {
    _brandController.clear();
    _modelController.clear();
    _rateController.clear();
    _descriptionController.clear();
    _selectedYear = "2024";
    _startDate = DateTime.now();
    _endDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseManager.instance.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("publish your car"),
        actions: [
          _file != null
              ? TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    _geoFirePoint = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LocationScreen(),
                      ),
                    ) as GeoFirePoint;
                    print(_geoFirePoint.data);
                    print(_endDate.toString());
                    print(_startDate.toString());

                    String id = const Uuid().v1();
                    String carUrl =
                        await uploadImageToStorage('listings', _file!, id);
                    print(carUrl);
                    CarListing newCar = CarListing(
                      id: id,
                      availabilityEndDate: Timestamp.fromDate(_endDate),
                      availabilityStartDate: Timestamp.fromDate(_startDate),
                      brand: _brandController.text,
                      modelName: _modelController.text,
                      yearModel: int.parse(_selectedYear),
                      dailyRentalRate: int.parse(_rateController.text),
                      carPhotoURL: carUrl,
                      sellerID: user.uid,
                      location: _geoFirePoint,
                      description: _descriptionController.text,
                    );
                    String result = await addListing(newCar, _file!, id);
                    await stub.addCar(Car(id: id, photoUrl: carUrl));
                    showSnackBar(result, context);
                    setState(() {
                      isLoading = false;
                    });
                    clearFields();
                  },
                  child: const Text(
                    "publish",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ))
              : TextButton(
                  onPressed: () {
                    showSnackBar("Please select an image", context);
                  },
                  child: const Text(
                    "publish",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            isLoading
                ? const LinearProgressIndicator()
                : const Padding(
                    padding: EdgeInsets.only(top: 0),
                  ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextFieldInput(
                    controller: _brandController,
                    hintText: "Brand",
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextFieldInput(
                    controller: _modelController,
                    hintText: "Model",
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adjust the right padding as needed
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextFieldInput(
                    controller: _rateController,
                    hintText: "daily rate",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0), // Adjust the left padding as needed
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: DropdownButtonFormField<String>(
                      value:
                          _selectedYear, // You'll need to declare _selectedYear variable and initialize it with the default value
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedYear = newValue ??
                              ""; // Handle the case when newValue is null
                        });
                      },
                      items: List.generate(
                        20, // Adjust this number as per your requirement to show a range of years
                        (index) {
                          int year = DateTime.now().year - index;
                          return DropdownMenuItem<String>(
                            value: year.toString(),
                            child: Text(year.toString()),
                          );
                        },
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Model Year',
                        labelText: 'Model Year',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const Text("Availability Start Date"),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DropdownDatePicker(
                onChangedDay: (newValue) {
                  if (newValue != null) {
                    _startDate = DateTime(
                        _startDate.year, _startDate.month, int.parse(newValue));
                  }
                },
                onChangedMonth: (newValue) {
                  if (newValue != null) {
                    _startDate = DateTime(
                        _startDate.year, int.parse(newValue), _startDate.day);
                  }
                },
                onChangedYear: (newValue) {
                  if (newValue != null) {
                    _startDate = DateTime(
                        int.parse(newValue), _startDate.month, _startDate.day);
                  }
                },
                dateformatorder: OrderFormat.MYD, // default is myd
                // inputDecoration: InputDecoration(
                //   enabledBorder: const OutlineInputBorder(
                //     borderSide: BorderSide(color: Colors.grey, width: 1.0),
                //   ),
                //   // border: OutlineInputBorder(
                //   //     borderRadius: BorderRadius.circular(7)),
                // ), // optional
                startYear: _startDate.year, // optional
                endYear: _startDate.year + 1, // optional
                selectedDay: _startDate.day, // optional
                selectedMonth: _startDate.month, // optional
                selectedYear: _startDate.year, // optional
                boxDecoration: BoxDecoration(
                  color: Colors.grey[200],
                ), // optional
                // showDay: false, // optional
                // locale: "zh_CN",// optional
                // hintDay: 'Day', // optional
                // hintMonth: 'Month', // optional
                // hintYear: 'Year', // optional
                // hintTextStyle: TextStyle(color: Colors.grey), // optional
              ),
            ),
            const Divider(),
            const Text("Availability End Date"),
            SizedBox(
              child: DropdownDatePicker(
                onChangedDay: (newValue) {
                  if (newValue != null) {
                    _endDate = DateTime(
                        _endDate.year, _endDate.month, int.parse(newValue));
                  }
                },
                onChangedMonth: (newValue) {
                  if (newValue != null) {
                    _endDate = DateTime(
                        _endDate.year, int.parse(newValue), _endDate.day);
                  }
                },
                onChangedYear: (newValue) {
                  if (newValue != null) {
                    _endDate = DateTime(
                        int.parse(newValue), _endDate.month, _endDate.day);
                  }
                },
                dateformatorder: OrderFormat.MYD, // default is myd
                // inputDecoration: InputDecoration(
                //     enabledBorder: const OutlineInputBorder(
                //       borderSide: BorderSide(color: Colors.grey, width: 1.0),
                //     ),
                //     border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(10))), // optional
                isFormValidator: true, // optional
                startYear: _endDate.year, // optional
                endYear: _endDate.year + 1, // optional
                // selectedDay: 14, // optional
                selectedMonth: _endDate.month, // optional
                selectedYear: _endDate.year, // optional
                boxDecoration: BoxDecoration(
                  color: Colors.grey[200],
                ), // optional
                // showDay: false,// optional
                // locale: "zh_CN",// optional
                // hintDay: 'Day', // optional
                // hintMonth: 'Month', // optional
                // hintYear: 'Year', // optional
                // hintTextStyle: TextStyle(color: Colors.grey), // optional
              ),
            ),
            const Divider(),
            const Text("Description"),
            TextFieldInput(
                hintText: "V8 5 seater", controller: _descriptionController),
            _file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.upload,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          _selectImage(context);
                        },
                      ),
                      const Text(
                        "Choose your best car image.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
