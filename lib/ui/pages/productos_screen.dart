

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/api/api_provider.dart';
import 'package:indierocks_cubetero/core/providers/api/api_state.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/data/models/categoria_producto_model.dart';
import 'package:indierocks_cubetero/data/models/cortesia_cliente_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/res_scan_dialog_model.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/domain/entities/producto.dart';
import 'package:indierocks_cubetero/ui/components/dialog_options_scan.dart';
import 'package:indierocks_cubetero/ui/components/dialog_scan_handler.dart';
import 'package:indierocks_cubetero/ui/components/producto_card.dart';
import 'package:indierocks_cubetero/ui/enum/enum_alert_status.dart';
import 'package:indierocks_cubetero/ui/enum/enum_banks.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/alert_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/app_bar_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/loading_screen.dart';
import 'package:indierocks_cubetero/ui/widgets/loading_widget.dart';
import 'package:indierocks_cubetero/ui/widgets/menu_drawer_app.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';

class ProductosScreen extends ConsumerStatefulWidget {
  List<CortesiaClienteModel> cortesias;
  ProductosScreen({Key? key, required this.cortesias}) : super(key: key);

  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends ConsumerState<ProductosScreen> {
  UserModel? userOperativo = null;
  late Future<void> _initialized;
  double total = 0;
  BankType banco = BankType.NFC;
  Map<ProductoModel, int> listCompra = {};
  var isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    userOperativo = ref.read(userLogued.notifier).state;
    _initialized = getprod();
  }

  Future<void> getprod() async{
    Completer<void>  completer = Completer<void>();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
      ref.read(getProductosNotifier.notifier).getProductos(userOperativo!.data_encripted);

      ref.read(apiNotiier.notifier).reset();
    });
    completer.future;
  }

  @override
  Widget build(BuildContext context) {

    final getProductos = ref.watch(getProductosNotifier);
    final venta = ref.watch(apiNotiier);
    Map<CategoriaProductoModel, List<ProductoModel>> groupedCategoria = {};

    if(venta is ApiAvailable){
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        ref.read(apiNotiier.notifier).reset();

        setState(() {

          isLoading = false;
        });

        Navigator.pushReplacementNamed(context, AppPageRoutes.VENTA_RESULT.getPage(),
            arguments: {
              'resTransaction' :venta.apiState ,
              'banco' : banco,
              'monto' :total ,
              'listCompra' :listCompra ,
            }
        );
      });
    }else if(venta is Loading){

    }else if(venta is Error){
      setState(() {

        isLoading = false;
      });
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        ref.read(apiNotiier.notifier).reset();
        AlertCustomDialog(context: context,alert_type: AlertCustomDialogType.INFO,msg: venta.message,).show();
      });
    }



    return FutureBuilder(future: _initialized ,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBarCustom(name:userOperativo!.user,),
          drawer: MenuDrawerApp(),
          body: Stack(
            children: [
              getProductos.when(
                available: (listProducts) {
                  groupedCategoria = {};

                  print('Cosrtesias Prodcutos Screen ${widget.cortesias.length}');

                  listProducts.forEach((element) {
                    CategoriaProductoModel categoria = element.categoria;
                    groupedCategoria.putIfAbsent(categoria, () => []);
                    groupedCategoria[categoria]?.add(element);
                  });
                  return listProducts.isEmpty ?

                  Container(
                    margin: EdgeInsets.only(left: 20,right: 20),
                    width: MediaQuery.of(context).size.width,
                    child:  Column(
                      children: [
                        Spacer(),
                        Container(
                          padding:  EdgeInsets.all(20),
                          decoration:  const BoxDecoration(
                            color: AppColors.alert_information,
                            shape: BoxShape.circle,
                            boxShadow:  [
                              BoxShadow(
                                color: AppColors.alert_information,
                                blurRadius: 10,
                                offset: Offset(4, 8), // Shadow position
                              ),
                            ],
                          ),
                          child: const Icon(Icons.warning,
                              color: AppColors.textColorError,
                              size: 40
                          ),
                        ),
                        const SizedBox(height: 20,),
                        const Text('No hay productos disponibles en tu barra. Consulta con tu administrador.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),

                        const Spacer(),
                        ButtomCustom(text: 'Cargar Prodcutos',
                          onPressed: () async{
                            WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
                              ref.read(getProductosNotifier.notifier).getProductos(userOperativo!.data_encripted);
                            });
                          },),
                        const Spacer(),

                      ],
                    ),
                  )
                      : Stack(
                    fit: StackFit.expand,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.separated(
                              itemCount: groupedCategoria.length,
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
                                CategoriaProductoModel categoria = groupedCategoria.keys.elementAt(index);
                                List<ProductoModel> productos = groupedCategoria[categoria]??[];

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
                                        ProductoModel prod = productos.elementAt(index);
                                        return ProductCard(
                                          producto: prod,
                                          cortesias: widget.cortesias,
                                          callback: (contador) {
                                            setState(() {

                                              total = total + prod.sku_monto;
                                            });
                                            listCompra.putIfAbsent(prod, () => contador);
                                            listCompra[prod]=contador;
                                            print('Contador${listCompra.length}');
                                          },
                                          reset: (contador) {
                                            setState(() {
                                              total = total -( prod.sku_monto *contador);
                                            });
                                            listCompra.remove(prod);
                                          },
                                        );

                                      },
                                    ),

                                    const SizedBox(height: 10,),
                                  ],
                                );

                              },
                            ),

                            const SizedBox(height: 80,),
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          child: ButtomCustom(text: "TOTAL: ${DataFormater.formatCurrency(total)}",
                            margin: EdgeInsets.all(0),
                            radius: 0,
                            onPressed: () async {

                              if(listCompra.isEmpty){
                                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                                  ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackbarCustom(
                                        message: 'Debes seleccionar al menos un producto',
                                        backgroundColor: AppColors.alert_error,
                                        textColor: AppColors.textColorError,
                                        icon: Icons.error,
                                        context: context,
                                      )
                                  );
                                });
                                return;
                              }

                              var json_venta = [];
                              listCompra.forEach((key, value) {
                                json_venta.add({
                                  'sku': '\'${key.sku}\'',
                                  'nProd': value
                                });
                              });

                              print('Productos ${json_venta.toString()}');

                              DialogScanHandler(
                                process: ProcessType.READ_PULSERA,
                                parentContext: context,

                                dataCallback: (data, banco) {
                                  print('Data_leido Escaner Cliente: $data');

                                  setState(() {

                                    isLoading = true;
                                  });
                                  ref.read(apiNotiier.notifier).venta(data,userOperativo!.data_encripted, json_venta.toString(),total,banco.getBank());
                                  ref.read(apiNotiier.notifier).reset();

                                },
                              ).showDialogOption().whenComplete(() {
                                if(Navigator.of(context).canPop()){
                                  Navigator.of(context).pop();
                                }
                              },);


                              /*var dialog = DialogOptionScan(context: context, process: ProcessType.READ_PULSERA);

                          ResScanDialogModel res = await dialog.showDialogOption();
                          //print(res.toJson());
                          if(res.rcode == 0){
                            banco = res.banco;
                            ref.read(apiNotiier.notifier).venta(res.message,userOperativo!.data_encripted, json_venta.toString(),total,res.banco.getBank());
                          }
                          else{
                            SnackbarCustom(
                              message: res.message,
                              backgroundColor: AppColors.alert_information,
                              textColor: AppColors.textColorInformation,
                              icon: Icons.info,
                              context: context,
                            ).showdialog();
                          }*/
                            },
                          )
                      ),
                    ],
                  );
                },
                initial: () {
                  return Text("inicial");
                },
                loading: () {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: const Column(
                      children: [
                        Spacer(),
                        LoadingWidget(),
                        Spacer(),
                      ],
                    ),
                  );
                },
                error: (statusCode, message) {
                  return Container(
                    margin: EdgeInsets.only(left: 20,right: 20),
                    width: MediaQuery.of(context).size.width,
                    child:  Column(
                      children: [
                        Spacer(),
                        Container(
                          padding:  EdgeInsets.all(20),
                          decoration:  const BoxDecoration(
                            color: AppColors.alert_error,
                            shape: BoxShape.circle,
                            boxShadow:  [
                              BoxShadow(
                                color: AppColors.alert_error,
                                blurRadius: 10,
                                offset: Offset(4, 8), // Shadow position
                              ),
                            ],
                          ),
                          child: const Icon(Icons.error,
                              color: AppColors.textColorError,
                              size: 40
                          ),
                        ),
                        const SizedBox(height: 20,),
                        const Text('No se pudo obtener información de los productos. Intenta de nuevo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 20,),
                        Text('Error: ${statusCode}. ${message}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        ButtomCustom(text: 'Cargar Prodcutos',
                          onPressed: () async{
                            WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
                              ref.read(getProductosNotifier.notifier).getProductos(userOperativo!.data_encripted);
                            });
                          },),
                        const Spacer(),

                      ],
                    ),
                  );
                },
              ),
              isLoading ? LoadingScreen() :SizedBox()
            ],
          )
        );

    },);
  }
}
