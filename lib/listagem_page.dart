import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:ifms_form/formulario.dart';
import 'package:ifms_form/user_model.dart';
import 'package:meet_network_image/meet_network_image.dart';
import 'package:scoped_model/scoped_model.dart';

import 'detail_page.dart';

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
  List lessons;

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    dataOS = fetchData();
    super.initState();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      extendBodyBehindAppBar: true,
      appBar: topAppBar,
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
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

                            return makeBody(documents.toList());
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

  ListTile makeListTile(var item) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24))),
          child: Icon(Icons.autorenew, color: Colors.green),
        ),
        title: Text(
          item['date'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(item['numberCalled'],
                      style: TextStyle(color: Colors.white))),
            )
          ],
        ),
        trailing:
            Icon(Icons.keyboard_arrow_right, color: Colors.green, size: 30.0),
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DetailPage(item: item)));
        },
      );
  final topAppBar = AppBar(
    elevation: 0.1,
    backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
    title: Text(
      'Ordens de Serviços',
    ),
  );

  Card makeCard(var item) => Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: makeListTile(item),
        ),
      );
  Container makeBody(var item) => Container(
        // decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: item.length,
          itemBuilder: (BuildContext context, int index) {
            return makeCard(item[index]);
          },
        ),
      );
  showAlertDialog(BuildContext context, String date, String coordinates,
      String message, var image, String time) {
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
      insetPadding: EdgeInsets.symmetric(vertical: 10),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: GridView.builder(
                  itemCount: image.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                            decoration: new BoxDecoration(
                                image: new DecorationImage(
                                    image: new NetworkImage(image[index]),
                                    fit: BoxFit.cover))));
                  }),
            ),

            SizedBox(
              height: 30,
            ),
            Flexible(
              child: Row(
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
            ),
            Flexible(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coordenadas',
                          style: TextStyle(
                            fontWeight: FontWeight.w200,
                          )),
                      Flexible(
                        child: Text(
                          '$coordinates' == 'null' ? '' : '$coordinates',
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),

            Flexible(
              child: Text('Descrição',
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                  )),
            ),
            Flexible(
                child: Text(
                    'djnfjksdbfksdbfkjsdbfbsdfsdbfdsfsldjbfljsdbfjlblsjdfbjlsdbfljsdbfjlbsdlfbsdlfblsdbfljsdbfjlbjoldbfjldblfjsdblfjbsdjlfbsdjlfbljsdfbljb')),
            // Text('Coordenadas : $coordinates'),
          ],
        ),
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
