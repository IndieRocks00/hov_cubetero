

import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/data/models/categoria_producto_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/ui/components/prodcut_card_result.dart';
import 'package:indierocks_cubetero/ui/components/producto_card.dart';
import 'package:indierocks_cubetero/ui/enum/enum_banks.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';

class VentaResultScreen extends StatefulWidget {

  final ResApiModel resTransaction;
  final double monto;
  final BankType banco;
  final Map<ProductoModel, int> listCompra;
  const VentaResultScreen({Key? key,
    required this.resTransaction,
    required this.monto,
    required this.banco,
    required this.listCompra
  }) : super(key: key);

  @override
  State<VentaResultScreen> createState() => _VentaResultScreenState();
}

class _VentaResultScreenState extends State<VentaResultScreen> {


  @override
  Widget build(BuildContext context) {

    Map<CategoriaProductoModel, List<ProductoModel>> groupedProducts = {};

    widget.listCompra.forEach((producto, cantidad) {
      CategoriaProductoModel categoria = producto.categoria;
      groupedProducts.putIfAbsent(categoria, () => []);
      groupedProducts[categoria]!.add(producto);
    });

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            Positioned.fill(child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40,),
                  widget.resTransaction.rcode == 0 ? Container(
                    padding: EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.alert_ok,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alert_information,
                          blurRadius: 10,
                          offset: Offset(6, 5), // Shadow position
                        ),
                      ],
                    ),
                    child: const Icon(Icons.done,
                        color: AppColors.textColorOk,
                        size: 50
                    ),
                  ):
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.alert_error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alert_information,
                          blurRadius: 10,
                          offset: Offset(4, 8), // Shadow position
                        ),
                      ],
                    ),
                    child: const Icon(Icons.error,
                        color: AppColors.textColorError,
                        size: 50
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(widget.banco.name,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(DataFormater.formatCurrency(widget.monto),
                    style: TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(left: 25,right: 25),
                    child: Text(widget.resTransaction.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 30,

                      ),
                    ),
                  ),


                  widget.resTransaction.rcode == 0 ?
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.only(left: 25,right: 25),
                            child: const Text('Productos entregados:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          ListView.separated(
                            itemCount: groupedProducts.length,
                            shrinkWrap: true,
                            separatorBuilder: (context, index) {
                              return const Divider(
                                height: 20, // Altura del separador
                                thickness: 3, // Grosor del separador
                                color: Colors.grey, // Color del separador
                                indent: 20, // Sangría en el inicio del separador
                                endIndent: 20, // Sangría al final del separador
                              );
                            },
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {

                              CategoriaProductoModel categoria = groupedProducts.keys.elementAt(index);
                              List<ProductoModel> productos = groupedProducts[categoria] ?? [];
                              print('Prodcutos ${productos.length}' );

                              return Column(
                                children: [
                                  const SizedBox(height: 10,),
                                  Text(categoria.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  const SizedBox(height: 20,),
                                  GridView.builder(
                                    shrinkWrap:true,
                                    itemCount: productos.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 0.0,
                                        mainAxisSpacing: 0.0
                                    ),
                                    itemBuilder: (context, index) {
                                      ProductoModel producto = productos.elementAt(index);
                                      int? cantidad =widget.listCompra[producto];
                                      //print('Cantidad ${cantidad}');
                                      return ProductCardResult(
                                        producto: producto,
                                        cant: cantidad!,
                                      );

                                    },
                                  ),

                                  const SizedBox(height: 10,),
                                ],
                              );

                            },
                          )
                        ],
                      )
                      :SizedBox(),


                  const SizedBox(height: 100,),
                ],
              ),
            )),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: ButtomCustom(text: 'Continuar',
              onPressed: () async {
                Navigator.pushReplacementNamed(context, AppPageRoutes.HOME.getPage());
              },
            ),)
          ],
        )
    );
  }
}
