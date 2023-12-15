

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/Utils/Tools.dart';
import 'package:indierocks_cubetero/Utils/UITools.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/login/login_provider.dart';
import 'package:indierocks_cubetero/core/providers/login/login_state.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/core/providers/sql/sql_provider.dart';
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/ui/widgets/buttom_loading.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/textfield_component.dart';
import 'package:indierocks_cubetero/ui/components/top_alert_message.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {

  final etUserController = TextEditingController(text: 'cubetero_prueba');
  final etPassController = TextEditingController(text: '1234');


  @override
  Widget build(BuildContext context)  {

    final  loginState = ref.watch(loginNotifier);

    if (loginState is LoginAvailable) {
      ref.watch(sqlRepository).insertUser(loginState.userModel);
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
        ref.read(userLogued.notifier).state=loginState.userModel;
        /*ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackbarCustom(
              message: 'OK',
              backgroundColor: AppColors.alert_ok,
              textColor: AppColors.textColorOk,
              icon: Icons.check_circle,
              context: context,
            )
        );*/
        ref.read(loginNotifier.notifier).reset();
        Navigator.pushReplacementNamed(context, AppPageRoutes.HOME.getPage());
      });

    } else if (loginState is Error) {
      var logins = loginState;
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackbarCustom(
              message: 'Error ${logins.statuscode} : ${logins.message}',
              backgroundColor: AppColors.alert_error,
              textColor: AppColors.textColorError,
              icon: Icons.error,
              context: context,
            )
        );
        ref.read(loginNotifier.notifier).reset();
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset("assets/images/foro_ir_white.png",
                    width: MediaQuery.of(context).size.width-100,
                    height: 200,
                  ),
                ),

                Column(
                  children: [

                    TextfieldComponent(
                      controller: etUserController,
                      hint_label: 'Usuario',
                      icon: Icons.person,
                    ),
                    TextfieldComponent(
                      controller: etPassController,
                      hint_label: 'Contraseña',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    ButtomLoading(
                      loading: loginState,
                      onPressed: () async{

                        await ref.read(loginNotifier.notifier).doLogin(etUserController.text.toString(),etPassController.text.toString());

                      },
                      text: "Inicias Sesión",
                    )
                  ],
                ),

              ],
            ),
          ],

        ),
      ),
    );


  }
}
