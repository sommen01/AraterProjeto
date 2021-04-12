import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:ifms_form/formulario.dart';
import 'package:ifms_form/user_model.dart';
import 'package:meet_network_image/meet_network_image.dart';
import 'package:scoped_model/scoped_model.dart';

class Listagem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListagemState();
  }
}

class _ListagemState extends State<Listagem> {
  // f45d27
  // f5851f
  Future<QuerySnapshot> dataOS;

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    dataOS = fetchData();
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
      ),
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
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
                      child: Image(image: AssetImage('assets/logo.png')),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32, right: 32),
                        child: Text(
                          'Ordens de Serviços',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ScopedModelDescendant<UserModel>(
                  builder: (context, child, model) {
                if (model.isLoading)
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                // ignore: deprecated_member_use
                return Container(
                    height: MediaQuery.of(context).size.height / 1.7,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 10),
                    child: FutureBuilder<QuerySnapshot>(
                        future: fetchData(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child:
                                  Text('Ocorreu um erro ao carregar os dados.'),
                            );
                          }
                          if (snapshot.hasData == false) {
                            return Center(
                              child: Text('Nao ha dados.'),
                            );
                          }
                          if (snapshot.data != null) {
                            final List<DocumentSnapshot> documents =
                                snapshot.data.docs;
                            return ListView(
                                children: documents
                                    .map((data) => Container(
                                          margin: const EdgeInsets.all(15.0),
                                          padding: const EdgeInsets.all(3.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.green)),
                                          child: GestureDetector(
                                            onTap: () {
                                              showAlertDialog(
                                                context,
                                                data['date'],
                                                data['coordinates'],
                                                data['description'],
                                                data['image'],
                                                data['time'],
                                              );
                                            },
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.add,
                                                color: Colors.green,
                                              ),
                                              trailing: Text(data[
                                                          'coordinates'] ==
                                                      'null'
                                                  ? ''
                                                  : '${data['coordinates']}'),
                                              title: Text(
                                                  '${data['numberCalled']}'),
                                              subtitle: Row(
                                                children: [
                                                  Text('${data['date']}'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList());
                          }
                          return CircularProgressIndicator();
                        }));
              })
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String date, String coordinates,
      String message, String image, String time) {
    Widget cancelButton = TextButton(
      child: Text(
        'Ok',
        style: TextStyle(color: Colors.green),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(vertical: 135),
      content: Column(
        children: [
          FullScreenWidget(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MeetNetworkImage(
                imageUrl: image,
                height: MediaQuery.of(context).size.height / 2.2,
                loadingBuilder: (context) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorBuilder: (context, e) => Center(
                  child: Text('Erro ao processar imagem!'),
                ),
              ),

              // Image.asset(
              //   "assets/image2.jpg",
              //   fit: BoxFit.cover,
              // ),
            ),
          ),

          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data',
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      )),
                  Text('$date'),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hora',
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      )),
                  Text('$time'),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Descrição',
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      )),
                  Text('$message'),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coordenadas',
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      )),
                  Text(
                    '$coordinates' == 'null' ? '' : '$coordinates',
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ],
          ),
          // Text('Coordenadas : $coordinates'),
        ],
      ),
      actions: [
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<QuerySnapshot> fetchData() async {
    var data = await FirebaseFirestore.instance.collection('called').get();

    return data;
  }

  void _onSuccess() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Formulario()),
    );
  }
}

//     void _onFail() {
//   _scaffoldKey.currentState.showSnackBar(SnackBar(
//     content: Text("Falha ao Entrar!"),
//     backgroundColor: Colors.redAccent,
//     duration: Duration(seconds: 2),
//   ));
// }
