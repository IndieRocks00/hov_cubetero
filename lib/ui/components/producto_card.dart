
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/data/models/cortesia_cliente_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';

class ProductCard extends StatefulWidget {

  final ProductoModel producto;
  final List<CortesiaClienteModel> cortesias;
  final Function(int contador)? callback;
  final Function(int contador)? reset;
  const ProductCard({
    Key? key,
    required this.producto,
    required this.callback,
    required this.reset,
    required this.cortesias
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {

  bool isSelected = false;
  int cont = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(

            child: InkWell(
          onTap: () {
            setState(() {

              if(widget.producto.categoria.ID == 367){//Categoria Cortesia

                if(widget.cortesias.isEmpty){//Validar si tiene cortesias
                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackbarCustom(
                          message: 'No cuentas con cortesias disponibles',
                          backgroundColor: AppColors.alert_error,
                          textColor: AppColors.textColorError,
                          icon: Icons.error,
                          context: context,
                        )
                    );
                  });
                  return;
                }

                CortesiaClienteModel? cortesia = null;
                widget.cortesias.forEach((element) {
                  if(element.serviceId == widget.producto.service){
                    cortesia = element;
                  }
                });
                if(cortesia == null){
                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackbarCustom(
                          message: 'No cuentas con cortesias para este prodcuto.',
                          backgroundColor: AppColors.alert_error,
                          textColor: AppColors.textColorError,
                          icon: Icons.error,
                          context: context,
                        )
                    );
                  });
                  return;
                }
                else if(cortesia!.cantidad<=cont){
                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackbarCustom(
                          message: 'Ya no cuentas con mas cortesias. Disponibles ${cortesia!.cantidad}',
                          backgroundColor: AppColors.alert_error,
                          textColor: AppColors.textColorError,
                          icon: Icons.error,
                          context: context,
                        )
                    );
                  });
                  return;
                }
                else{

                  isSelected = true;
                  if(cont<100){
                    cont ++;

                    widget.callback!(cont);
                  }
                }
              }
              else{
                isSelected = true;
                if(cont<100){
                  cont ++;

                  widget.callback!(cont);
                }
              }


            });
          },
          onLongPress: () {

            setState(() {
              widget.reset!(cont);
              cont=0;
              isSelected = false;
            });
          },
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(5),
                child: Card(
                  color: isSelected ? AppColors.backgCardProdSelect : AppColors.backgCardProdNOSelect,
                  child: Column(
                    children: [
                      const Spacer(),
                      Text(
                        DataFormater.formatCurrency(widget.producto.sku_monto),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: isSelected ? AppColors.textCardProdcutSelect : AppColors.textCardProdcutNOSelect,
                        ),
                      ),
                      Text(
                        widget.producto.productName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? Colors.white : Colors.black,

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
        isSelected? Positioned(
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
                  Text('$cont', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: AppColors.textAppBarColor),)
                ],
              ),
            ),
          ),
        ): SizedBox()
      ],
    );

  }
}
