import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/data/models/cortesia_cliente_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';


class ProductCardResult extends StatefulWidget {

  final ProductoModel producto;
  final int cant;
  const ProductCardResult({
    Key? key,
    required this.producto,
    required this.cant,
  }) : super(key: key);

  @override
  State<ProductCardResult> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCardResult> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(

            child: InkWell(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    child: Card(
                      color: AppColors.backgCardProdSelect ,
                      child: Column(
                        children: [
                          const Spacer(),
                          Text(
                            DataFormater.formatCurrency(widget.producto.sku_monto),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color:  AppColors.textCardProdcutSelect ,
                            ),
                          ),
                          Text(
                            widget.producto.productName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white ,

                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            )),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            height: 40,
            width: 40,
            child: Card(
              color: AppColors.primaryColor,
              shape: CircleBorder(),
              child: Column(
                children: [
                  Text('${widget.cant}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: AppColors.textAppBarColor),)
                ],
              ),
            ),
          ),
        )
      ],
    );

  }
}