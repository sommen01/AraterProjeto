import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ifms_form/models/os_model.dart';
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
  Future<String> url;

  File _image;
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
  String urls;
  List<OsModel> osModelList = List<OsModel>();
  bool isfinal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
                    height: MediaQuery.of(context).size.height * 0.47,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(58, 66, 86, 1.0),
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(90))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.27,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: displaySelectedFile(_image),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Form(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView(
                        padding: EdgeInsets.all(16),
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.photo_camera_outlined,
                              size: 40,
                            ),
                            onPressed: () {
                              cameraImage();
                              print('foda');
                            },
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 16,
                          ),
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
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 5)
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
                            height: 16,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1,
                            height: MediaQuery.of(context).size.height * 0.3,
                            padding: EdgeInsets.only(
                                top: 4, left: 16, right: 16, bottom: 4),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 5)
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
                          SizedBox(
                            height: 16,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (url == null) {
                                await uploadFile();
                              }
                              addOsObject(
                                  model.userData["name"],
                                  await url,
                                  _currentPosition.toString(),
                                  time,
                                  date,
                                  __description.text,
                                  _numberCalled.text);

                              showAlertDialog(context);
                              if (isfinal == true) {
                                model.saveCalled(
                                    formData: osModelList,
                                    onSuccess: _onSuccess,
                                    onFail: _onFail);
                              }
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.08,
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
                    ),
                  ),
                  // Visibility(
                  //   visible: false,
                  //   child: Container(
                  //     height: MediaQuery.of(context).size.height * 0.60,
                  //     width: MediaQuery.of(context).size.width,
                  //     padding: EdgeInsets.only(top: 30),
                  //     child: Column(
                  //       children: <Widget>[
                  //
                  //         SizedBox(
                  //           height: MediaQuery.of(context).size.height * 0.025,
                  //         ),

                  //         Container(
                  //           width: MediaQuery.of(context).size.width / 1,
                  //           height: MediaQuery.of(context).size.height * 0.3,
                  //           padding: EdgeInsets.only(
                  //               top: 4, left: 16, right: 16, bottom: 4),
                  //           decoration: BoxDecoration(
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(50)),
                  //               color: Colors.white,
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                     color: Colors.black12, blurRadius: 5)
                  //               ]),
                  //           child: TextField(
                  //             controller: __description,
                  //             maxLines: null,
                  //             expands: true,
                  //             keyboardType: TextInputType.multiline,
                  //             decoration: InputDecoration(
                  //               border: InputBorder.none,
                  //               icon: Icon(
                  //                 Icons.text_fields,
                  //                 color: Colors.grey,
                  //               ),
                  //               hintText: 'Descrição',
                  //             ),
                  //           ),
                  //         ),
                  //         SizedBox(
                  //           height: MediaQuery.of(context).size.height * 0.025,
                  //         ),

                  //         // Container(child: _buildTextField()),
                  //         Align(
                  //           alignment: Alignment.centerRight,
                  //           child: Padding(
                  //             padding:
                  //                 const EdgeInsets.only(top: 16, right: 32),
                  //             child: Text(
                  //               '',
                  //               style: TextStyle(color: Colors.grey),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // )
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
    url = null;
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao envidar dados!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  addOsObject(String name, String url, String _curret, String time, String date,
      String des, String number) async {
    var x = new OsModel(await name, await url, await _curret.toString(), time,
        date, des, number);
    print(x);
    osModelList.add(x);
    print(osModelList);
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

  uploadFile() async {
    var url;
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(DateTime.now().millisecond.toString());
    UploadTask uploadTask = ref.putFile(_image);
    uploadTask.whenComplete(() async {
      try {
        url = await ref.getDownloadURL();
        print(url);
      } catch (onError) {
        print("Error");
      }
    });

    return url;
  }

  Widget displaySelectedFile(File file) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width * 1.0,
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
          : Container(
              width: double.infinity,
              height: 200,
              child: GestureDetector(
                onLongPress: () {
                  setState(() {
                    _image = null;
                  });
                },
                child: Container(
                    width: MediaQuery.of(context).size.height * 0.25,
                    height: MediaQuery.of(context).size.width * 1.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0) //
                            ),
                        image: DecorationImage(
                            fit: BoxFit.fill, image: FileImage(file)))),
              ),
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
        _image = File(pickedFile?.path);
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
        // _image.add(File(response.file.path));
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

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Finalizar"),
      onPressed: () {
        isfinal = !isfinal;
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continuar"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Finalizar OS?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
