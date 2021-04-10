import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ifms_form/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';

class Formulario extends StatefulWidget {
  @override
  _FormularioState createState() => _FormularioState();
}

class _FormularioState extends State<Formulario> {
  @override
  void initState() {
    _getCurrentLocation();
    _getDateNow();
    // SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  double val = 0;
  CollectionReference imgRef;

  List<File> _image = List<File>();
  final picker = ImagePicker();
  Position _currentPosition;
  String _currentAddress;
  String date;
  String time;
  Map<String, dynamic> formData = Map();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _numberCalled = TextEditingController();
  final __description = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: <Widget>[
          Row(
            children: [
              Text('Listagem'),
              IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/list');
                },
              ),
            ],
          )
        ],
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        brightness: Brightness.dark,
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          if (model.isLoading)
            return Center(
              child: CircularProgressIndicator(),
            );

          return Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.green, Colors.green.shade400],
                        ),
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(90))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Spacer(),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              cameraImage();

                              print(_currentAddress);
                              print(_currentPosition);
                            },
                            child: Column(
                              children: [
                                displaySelectedFile(_image),
                                SizedBox(
                                  height: 10,
                                ),
                                Icon(
                                  Icons.photo_camera_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 32, right: 32),
                            child: Text(
                              'FORMULÁRIO DE DADOS',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 30),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 45,
                          padding: EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ]),
                          child: TextField(
                              controller: _numberCalled,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Icon(
                                  Icons.format_list_numbered,
                                  color: Colors.grey,
                                ),
                                hintText: 'Número do Chamado',
                              )),
                        ),
                        SizedBox(
                          height: 35,
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width / 1,
                          height: MediaQuery.of(context).size.height / 3.7,
                          padding: EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ]),
                          child: TextField(
                            controller: __description,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.text_fields,
                                color: Colors.grey,
                              ),
                              hintText: 'Descrição',
                            ),
                          ),
                        ),
                        // Container(child: _buildTextField()),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, right: 32),
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () async {
                            if (time == null ||
                                date == null ||
                                _currentPosition == null) {
                              _getDateNow();
                              _getCurrentLocation();
                            }
                            formData = {
                              "name": await model.userData["name"],
                              "image": await uploadFile(),
                              "coordinates": await _currentPosition.toString(),
                              "time": time,
                              "date": date,
                              "description": __description.text,
                              "numberCalled": _numberCalled.text,
                            };
                            model.saveCalled(
                                formData: formData,
                                onSuccess: _onSuccess,
                                onFail: _onFail);
                          },
                          child: Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width / 1.2,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green, Colors.green[400]],
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: Center(
                              child: Text(
                                'Enviar'.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSuccess() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Sucesso ao enviar dados!"),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
    formData = {};
    _numberCalled.clear();
    __description.clear();
    time = null;
    _currentPosition = null;
    _image = null;
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao envidar dados!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  _getDateNow() {
    DateTime data = DateTime.now();
    String dat = DateFormat("dd/MM/yyyy").format(data);
    String tim = DateFormat.Hms().format(data);
    date = dat;
    time = tim;

    print(time);
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}, ";
      });
    } catch (e) {
      print(e);
    }
  }

  Future uploadFile() async {
    int i = 1;
    FirebaseStorage storage = FirebaseStorage.instance;
    Future<String> url;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      Reference ref =
          storage.ref().child("$_currentPosition" + DateTime.now().toString());
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          url = ref.getDownloadURL();
          imgRef.add({'url': value});

          i++;
        });
      });
      return imgRef;
    }
  }

  // Future uploadFile() async {
  //   for (var img in _image) {
  // Future<String> url;
  //     FirebaseStorage storage = FirebaseStorage.instance;

  //     Reference ref =
  //         storage.ref().child("$_currentPosition" + DateTime.now().toString());
  //     UploadTask uploadTask = ref.putFile(img);
  // await uploadTask.whenComplete(() {
  //   url = ref.getDownloadURL();
  // }).catchError((onError) {
  //   print(onError);
  // });
  //   }
  //   // return url;
  // }

  Widget displaySelectedFile(List<File> file) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width * 0.35,
      child: file == null
          ? new Container(
              width: 300.0,
              height: 300.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text('Aguardando foto...',
                      style: TextStyle(color: Colors.white, fontSize: 18))),
            )
          : new ListView.builder(
              itemCount: _image.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Container(
                        width: 300.0,
                        height: 300.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: FileImage(file[index])))));
              },
            ),
    );
  }

  Future cameraImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxHeight: 1000.0,
      maxWidth: 1000.0,
    );
    if (pickedFile == null) {
      return;
    } else {
      setState(() {
        _image.add(File(pickedFile?.path));
      });
      if (pickedFile.path == null) retrieveLostData();
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file.path));
      });
    } else {
      print(response.file);
    }
  }

  // Future cameraImageGaleria() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);
  //   if (pickedFile == null) {
  //     return;
  //   } else {
  //     setState(() {
  //       _image.add(File(pickedFile.path));
  //     });
  //   }
  // }

  Widget _buildTextField() {
    final maxLines = 5;

    return Container(
      color: Colors.white,
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: "Descrição",
          filled: true,
        ),
      ),
    );
  }
}
