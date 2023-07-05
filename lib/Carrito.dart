import 'package:flutter/material.dart';

class CarritoActivity extends StatefulWidget {
  const CarritoActivity({Key? key}) : super(key: key);

  @override
  State<CarritoActivity> createState() => _CarritoActivityState();
}

class _CarritoActivityState extends State<CarritoActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: (
              Column(
                children: [

                ],
              )
          ),
        ),
      ),
    );
  }


  Future<void> _displayProducts(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Agregar Producto'),
            content: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children:  [

                      Row(
                        children: [
                          /*ListView.builder(
                            itemCount: json_products== null ? 0: json_products.length,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Card(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 55,
                                              margin: EdgeInsets.only(top: 10),
                                              child:Text(json_products[index]['producto'],
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),),

                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 55,
                                              margin: EdgeInsets.only(top: 10),
                                              child:Text(MoneyFormatter(amount: double.parse(json_products[index]['MONTO'].toString())).output.symbolOnLeft,
                                                style: TextStyle(fontSize: 20),),
                                            ),),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),*/
                        ],
                      ),
                      /*ListView.builder(
                        itemCount: json_products== null ? 0: json_products.length,
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Card(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 55,
                                          margin: EdgeInsets.only(top: 10),
                                          child:Text(json_products[index]['producto'],
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),),

                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 55,
                                          margin: EdgeInsets.only(top: 10),
                                          child:Text(MoneyFormatter(amount: double.parse(json_products[index]['MONTO'].toString())).output.symbolOnLeft,
                                            style: TextStyle(fontSize: 20),),
                                        ),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),*/
                    ],
                  ),
                )
            ),
            actions: <Widget>[
              TextButton(onPressed: () async {


              },
                  child: Text("Continuar")
              ),
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              },
                  child: Text("Cancelar")
              ),
            ],
          );
        });
  }
}
