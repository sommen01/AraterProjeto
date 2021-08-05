import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final item;
  DetailPage({Key key, this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final levelIndicator = Container(
      child: Container(
        child: Text(
          item['numberCalled'],
        ),
      ),
    );

    final coursePrice = Container(
      padding: const EdgeInsets.all(7.0),
      child: new Text(
        item['date'],
        style: TextStyle(
          color: Color.fromRGBO(58, 66, 86, 1.0),
        ),
      ),
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
          color: Color.fromRGBO(58, 66, 86, 1.0),
          height: MediaQuery.of(context).size.height * 0.7,
          child: GridView.builder(
              itemCount: item['image'].length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                                image: new NetworkImage(item['image'][index]),
                                scale: 80.0,
                                fit: BoxFit.cover))));
              }),
        ),
      ],
    );

    final bottomContentText = Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: new Divider(color: Colors.green),
          ),
          SizedBox(height: 10.0),
          Text(
            item['coordinates'],
            style: TextStyle(
                color: Color.fromRGBO(58, 66, 86, 1.0), fontSize: 45.0),
          ),
          SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: levelIndicator),
              Expanded(
                  flex: 6,
                  child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        item['description'],
                        style:
                            TextStyle(color: Color.fromRGBO(58, 66, 86, 1.0)),
                      ))),
              Expanded(flex: 1, child: coursePrice)
            ],
          ),
        ],
      ),
    );

    final bottomContent = Container(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(
          children: <Widget>[
            bottomContentText,
            Container(
              width: 90.0,
              child: new Divider(color: Colors.green),
            ),
          ],
        ),
      ),
    );
    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      title: Text(item['numberCalled']),
    );
    return Scaffold(
      appBar: topAppBar,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[topContent, bottomContent],
        ),
      ),
    );
  }

  int gridController(int itens) {
    if (itens == 1)
      return 1;
    else
      return itens;
  }
}
