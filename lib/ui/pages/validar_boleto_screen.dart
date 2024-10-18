

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/api/api_provider.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/data/models/cortesia_cliente_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/result_cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/ui/components/dialog_scan_handler.dart';
import 'package:indierocks_cubetero/ui/enum/enum_alert_status.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/alert_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/app_bar_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/loading_screen.dart';
import 'package:indierocks_cubetero/ui/widgets/loading_widget.dart';
import 'package:indierocks_cubetero/ui/widgets/menu_drawer_app.dart';

class ValidarBoletoScreen extends ConsumerStatefulWidget {
  const ValidarBoletoScreen({Key? key}) : super(key: key);

  @override
  ValidarBoletoScreenState createState() => ValidarBoletoScreenState();
}

class ValidarBoletoScreenState extends ConsumerState<ValidarBoletoScreen> {

  UserModel? userOperativo = null;

  var isLoading = false;
  ResApiModel? resApiModel;
  int vans = 1;

  late List<bool> _selectedVans = <bool>[true, false];
  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    userOperativo = ref.read(userLogued.notifier).state;

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      ref.read(accesToEventNotifier.notifier).reset();
      ref.read(apiNotiier.notifier).reset();
    });
  }

  Widget cardFirma (int status, String text, int acompid, int eventID){
    return status != 0 ?
    Padding(padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
      child: Card(
        color: AppColors.background_general_second,
        elevation: 5,
        child: Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Column(
                      children: [
                        Text(text,
                          style: TextStyle(color: AppColors.primaryColor, fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                        const Text('Documento firmado',
                          style: TextStyle(color: AppColors.primaryColor, fontSize: 15),
                          textAlign: TextAlign.justify,
                        ),

                      ],
                    )),


                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.alert_ok,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.alert_ok,
                            blurRadius: 10,
                            offset: Offset(6, 5), // Shadow position
                          ),
                        ],
                      ),
                      child: const Icon(Icons.done,
                        color: AppColors.textColorOk,
                        size: 20,
                      ),
                    ),
                  ],
                )
              ],
            )
        ),
      ),
    ):
    GestureDetector(
      onTap: () {

      },
      child: Padding(padding: EdgeInsets.only(top: 5, bottom: 5,  left: 15, right: 15),
        child: Card(
          color: AppColors.background_general_second,
          elevation: 5,
          child: Container(
              margin: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Column(
                        children: [
                          Text(text,
                            style: TextStyle(color: AppColors.primaryColor, fontSize: 18),
                            textAlign: TextAlign.left,
                          ),
                          const Text('Pendiente de firmar',
                            style: TextStyle(color: AppColors.primaryColor, fontSize: 15),
                            textAlign: TextAlign.justify,
                          ),

                        ],
                      )),


                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.alert_information,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.alert_information,
                              blurRadius: 10,
                              offset: Offset(6, 5), // Shadow position
                            ),
                          ],
                        ),
                        child: const Icon(Icons.warning,
                          color: AppColors.textColorOk,
                          size: 20,
                        ),
                      ),
                    ],
                  )
                ],
              )
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    final apinotifier = ref.watch(apiNotiier);
    final accesToEvent = ref.watch(accesToEventNotifier);
    accesToEvent.when(
      available: (result) {

        isLoading = false;
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          //ref.read(accesToEventNotifier.notifier).reset();
          Navigator.pushReplacementNamed(context, AppPageRoutes.ACCESS_TO_EVENT.getPage(),
              arguments: {
                'resTransaction' :result
              }
          );
        });


      },
      initial: () {
        isLoading = false;
        //print('cortesia disponible inicial');
      },
      loading: () {
        isLoading = true;
      },
      error: (statusCode, message) {

        isLoading = false;
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
          ref.read(accesToEventNotifier.notifier).reset();
          AlertCustomDialog(
            context: context,
            alert_type: AlertCustomDialogType.ERROR,
            msg: message,).show();
        });
      },);



    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarCustom(name:userOperativo?.user ?? '',),
      drawer: MenuDrawerApp(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20,),
                const Text(
                  'Validar Boleto',
                  style: TextStyle(fontSize: 30),
                ),
                ButtomCustom(text: 'Escanear Cliente',
                  background: AppColors.backgroundColor,
                  onPressed: () async {
                    DialogScanHandler(
                      process: ProcessType.READ_PULSERA,
                      parentContext: context,
                      dataCallback: (data, banco) {
                        print('Data_leido Escaner Cliente: $data');

                        ref.read(apiNotiier.notifier).validarBoleto(data, userOperativo!.data_encripted);
                        //ref.read(getCortesiaNotifier.notifier).reset();

                      },
                    ).showDialogOption().whenComplete(() {
                      if(Navigator.of(context).canPop()){
                        Navigator.of(context).pop();
                      }
                    },);

                  },
                  textColor: AppColors.primaryColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                apinotifier.when(
                  available: (resultCortesiaModel) {

                    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                      ref.read(getCortesiaNotifier.notifier).reset();
                    });
                    if(resultCortesiaModel.rcode == 1){
                      return Column(
                        children: [

                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: AppColors.alert_information,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.alert_information,
                                  blurRadius: 10,
                                  offset: Offset(4, 8), // Shadow position
                                ),
                              ],
                            ),
                            child: const Icon(Icons.warning,
                                color: AppColors.textColorInformation,
                                size: 40
                            ),
                          ),
                          SizedBox(height: 10,),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              resultCortesiaModel!.message,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),


                        ],
                      );
                    }
                    print(resultCortesiaModel.toJson());
                    var boleto = jsonDecode(resultCortesiaModel.boletos!);
                    String? selfieImgBase64 = jsonDecode(resultCortesiaModel.message)['selfie_img'];

                    print('Acompañantes: ${boleto['acompanantes']}');
                    List<dynamic> acomp = boleto['acompanantes'];

                    return resultCortesiaModel!.rcode == 0 ?
                    Column(
                      children: [

                        const Text(
                          'Hola',
                          style: TextStyle(fontSize: 20),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(jsonDecode(resultCortesiaModel!.message)['name'],
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),),
                        selfieImgBase64 == null ? Container(
                          margin: EdgeInsets.only(top:10, bottom: 20),
                          child: const Text('No se encontro foto del usuario',
                            style: TextStyle(fontSize: 18),
                          ),
                        ):
                        Image.network(
                          selfieImgBase64!,
                          fit: BoxFit.cover, // ajustar la imagen al tamaño del widget
                          width: 200, // ancho de la imagen
                          height: 200, // altura de la imagen
                        ),

                        const Text('Saldo disponible:',
                          style: TextStyle(fontSize: 18),
                        ),
                        resultCortesiaModel!.balance != null ? Text(DataFormater.formatCurrency( double.parse(jsonDecode(resultCortesiaModel!.message)['balance'].toString())),
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ) :SizedBox(height: 0,),

                        resultCortesiaModel!.boletos == "" || resultCortesiaModel!.boletos == null ?
                        Column(
                          children: [

                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: AppColors.alert_information,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.alert_information,
                                    blurRadius: 10,
                                    offset: Offset(4, 8), // Shadow position
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.warning,
                                  color: AppColors.textColorInformation,
                                  size: 40
                              ),
                            ),
                            SizedBox(height: 10,),
                            const Text(
                              'No cuentas con un boleto disponible',
                              style: TextStyle(fontSize: 20),
                            ),

                          ],
                        ):
                        Column(
                          children: [

                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: AppColors.alert_ok,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.alert_ok,
                                    blurRadius: 10,
                                    offset: Offset(4, 8), // Shadow position
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.done,
                                  color: AppColors.textColorOk,
                                  size: 40
                              ),
                            ),
                            SizedBox(height: 10,),
                            const Text(
                              'Boleto  valido',
                              style: TextStyle(fontSize: 20),
                            ),

                            const Text(
                              'Disfuta del evento',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              boleto['evento']['name'],
                              style: TextStyle(fontSize: 30),
                            ),
                            SizedBox(height: 20,),
                            cardFirma(boleto['usuario']['status_firma'], 'Carta Deslinde', 0, boleto['evento']['ID']),
                            SizedBox(height: 20,),
                            boleto['evento']['type'] == 1?
                                 Column(
                                  children: [
                                    const Text(
                                      'Acompañantes:',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(height: 20,),
                                    Container(
                                      child: acomp.isEmpty ?

                                      Container(
                                        child: const Text('No cuenta con acompañantes registrados',textAlign: TextAlign.center, style: TextStyle(color: AppColors.primaryColor, fontSize: 18),),

                                      ):
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: acomp.length,
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                final person = acomp[index];
                                                print(person);
                                                return
                                                  cardFirma(person['status_firma'], '${person['nombre']} ${person['apellido']}', person['ID'], boleto['evento']['ID']);

                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ):const SizedBox(),

                            SizedBox(height: 20,),
                            Text('Cortesias', style: TextStyle(fontSize: 20),),
                            ToggleButtons(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                constraints: const BoxConstraints(
                                  minHeight: 60.0,
                                  minWidth: 130.0,
                                ),
                              selectedColor: AppColors.backgroundColor,
                              fillColor: AppColors.secondaryColor,
                              color: AppColors.alert_information,
                              onPressed: (index) {
                                if(index == 0){
                                  setState(() {
                                    _selectedVans = [true, false];
                                    vans = index+1;
                                  });
                                }
                                else{
                                  setState(() {
                                    vans = index+1;
                                    _selectedVans = [false, true];
                                  });
                                }
                              }, isSelected: _selectedVans,
                                children: const [
                              Text('CON VANS', style: TextStyle(fontSize: 20),),
                              Text('SIN VANS', style: TextStyle(fontSize: 20),),
                            ]),
                            ButtomCustom(text: 'Dar Acceso', onPressed: () async{
                                ref.read(accesToEventNotifier.notifier).accesToEvent(userOperativo!.data_encripted, boleto['usuario']['ID'], vans);
                            },),
                            const SizedBox(height: 40,)
                          ],
                        ),

                      ],
                    ):
                    Column(
                      children: [

                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: AppColors.alert_information,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.alert_information,
                                blurRadius: 10,
                                offset: Offset(4, 8), // Shadow position
                              ),
                            ],
                          ),
                          child: const Icon(Icons.warning,
                              color: AppColors.textColorInformation,
                              size: 40
                          ),
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            resultCortesiaModel!.message,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Text(
                            'Intenta de nuevo, o prueba con otro',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                      ],
                    );


                  },
                  initial: () {
                    return const Column(
                      children: [
                        Text(
                          'Sin información por mostrar',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Debes escanear una pulsera o QR para poder ver informacion de boletos',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    );
                  },
                  loading: () {

                    return const Column(

                      children: [

                        LoadingWidget(),

                        SizedBox(height: 30,),
                        Text('Obteniendo información. ',style:TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ],
                    );
                  },
                  error: (statusCode, message) {

                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: AppColors.alert_error,
                            shape: BoxShape.circle,
                            boxShadow: [
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
                        SizedBox(height: 20,),
                        Text(message,style:const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ],
                    );
                  },),
              ],
            ),
          ),
          isLoading?LoadingScreen():SizedBox(),
        ],
      ),
    );
  }
}
