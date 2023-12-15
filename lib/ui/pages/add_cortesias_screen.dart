

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/api/api_provider.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/ui/components/nfc_controller.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/widgets/app_bar_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/menu_drawer_app.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';

class AddCortesiasScreen extends ConsumerStatefulWidget {
  const AddCortesiasScreen({Key? key}) : super(key: key);

  @override
  _AddCortesiasScreenState createState() => _AddCortesiasScreenState();
}

class _AddCortesiasScreenState extends ConsumerState<AddCortesiasScreen> {

  UserModel? userOperativo = null;
  var isLoading = false;
  var etCantidadControlloler = TextEditingController();
  List<TextEditingController> _controllers = [];

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    userOperativo = ref.read(userLogued.notifier).state;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
      ref.read(getOptionsCortesiaNotifier.notifier).getOptionsCortesia(userOperativo!.data_encripted);
    });
  }
  @override
  Widget build(BuildContext context) {

    final getOptionsCortesia = ref.watch(getOptionsCortesiaNotifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarCustom(name:userOperativo?.user ?? '',),
      drawer: const MenuDrawerApp(),
      body: getOptionsCortesia.when(
          available: (listCortesia) {
            return listCortesia.isEmpty ?
            Container(
              margin: const EdgeInsets.only(left: 20,right: 20),
              width: MediaQuery.of(context).size.width,
              child:  Column(
                children: [
                  const Spacer(),
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
                  const Text('No hay opciones disponibles. Intenta nuevamente o consulta con tu administrador',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const Spacer(),
                  ButtomCustom(text: 'Cargar Opciones',
                    onPressed: () async{
                      WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
                        ref.read(getOptionsCortesiaNotifier.notifier).getOptionsCortesia(userOperativo!.data_encripted);
                      });
                    },),
                  const Spacer(),

                ],
              ),
            ): SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: 100,
                      padding: const EdgeInsets.only(top: 5, left: 20,),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child:
                          Center(
                            child: Image.asset("assets/images/foro_ir_white.png",
                              height: 150,
                            ),
                          ),
                          ),
                        ],
                      ),
                    ),
                    const Text('Ingresa la cantidad de cortesias para el cliente',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30,),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listCortesia.length,
                      itemBuilder: (context, index) {
                        var controller = TextEditingController(text: '0');
                        _controllers.add(controller);
                        return Card(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            margin: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(listCortesia.elementAt(index).descripcion),),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 10,right: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundTextField,
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: TextFormField(
                                          onChanged: (value) {
                                            if (value.isEmpty) {
                                              _controllers[index].text = '0';
                                            } else if (value.startsWith('0')) {
                                              _controllers[index].value = TextEditingValue(
                                                text: value.substring(1),
                                                selection: const TextSelection.collapsed(offset: 1),
                                              );
                                            }
                                          },
                                          textAlign: TextAlign.start,
                                          controller:   _controllers[index],
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp('^[0-9][0-9]'))],
                                          keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                          cursorColor: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    ButtomCustom(text: 'Cargar',
                      margin: EdgeInsets.only(left: 0,right: 0, top: 10),
                      onPressed: () async{
                        var json_cortesias = [];
                        int i = 0;
                        listCortesia.forEach((cortesia) {
                          if(_controllers[i].text != '0'){
                            json_cortesias.add({
                              '"service"': cortesia.service as int,
                              '"cantidad"': _controllers[i].text
                            });
                          }
                          i++;
                        });
                        if(json_cortesias.isEmpty){

                          ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackbarCustom(
                                message: 'Debes ingresar al menos una cortesia',
                                backgroundColor: AppColors.alert_information,
                                textColor: AppColors.textColorInformation,
                                icon: Icons.warning,
                                context: context,
                              )
                          );
                          return;
                        }
                        showDialog(context: context,
                            barrierDismissible: false, builder: (context){
                          return NFCController(process: ProcessType.ADD_CORTESIA,
                            json_cortesia: json_cortesias,
                            onDataChange: (data) {

                              ref.read(apiNotiier.notifier).addCortesia(data, userOperativo!.data_encripted, json_cortesias.toString());

                              print('Data Devuelto de lectura : ${data}');
                            },
                          );
                        }).whenComplete(() {
                          if(Navigator.of(context).canPop()){
                            Navigator.of(context).pop();
                          }
                        },);
                    },),
                    ButtomCustom(text: 'Remover',
                      margin: EdgeInsets.only(left: 0,right: 0, top: 10),
                      onPressed: () async{
                        showDialog(context: context,
                          barrierDismissible: false, builder: (context){
                            return NFCController(process: ProcessType.REMOVE_CORTESIA,
                            );
                          });
                    },),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),
            );
          },
          initial: () {

            return Text("inicial");
          },
          loading: () {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Column(
                children: [
                  Spacer(),
                  CircularProgressIndicator(color: AppColors.primaryColor,),
                  Spacer(),
                ],
              ),
            );
          },
          error: (rcode, message) {

            return Container(
              margin: const EdgeInsets.only(left: 20,right: 20),
              width: MediaQuery.of(context).size.width,
              child:  Column(
                children: [
                  const Spacer(),
                  Container(
                    padding:  const EdgeInsets.all(20),
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
                  Text('Error: ${rcode}. ${message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  ButtomCustom(text: 'Cargar opciones de cortesia',
                    onPressed: () async{
                      WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
                        ref.read(getProductosNotifier.notifier).getProductos(userOperativo!.data_encripted);
                      });
                    },),
                  const Spacer(),

                ],
              ),
            );
          },),
    );
  }
}
