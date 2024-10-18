
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/core/providers/sql/sql_provider.dart';
import 'package:indierocks_cubetero/core/providers/sql/sql_user_state.dart' as sql_user_state;
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/images/AppImages.dart';
import 'package:indierocks_cubetero/ui/pages/home_screen.dart';
import 'package:indierocks_cubetero/ui/pages/login_screen.dart';
import 'package:indierocks_cubetero/ui/widgets/loading_widget.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenSate createState() => SplashScreenSate();
}

class SplashScreenSate extends ConsumerState<SplashScreen> {
  late Future<Widget> _initialization;
  bool _isInitialized = false;

  UserModel? userlogued;

  @override
  void initState() {
    super.initState();
    _initialization = initApp(context, ref);
  }

  Future<Widget> initApp(BuildContext context, WidgetRef ref) async {
    Completer<Widget> completer = Completer<Widget>();

    await Future.delayed(Duration(seconds: 3));
    //final userModel = (await ref.read(sqlUserNotifier.notifier)).getUser();
    await ref.read(sqlUserNotifier.notifier).getUser();
    final sqlUserNoti = ref.watch(sqlUserNotifier);
    sqlUserNoti.when(
      available: (userModel) {
        print('Usuario Splash : ${userModel.toJson()}');
        ref.read(userLogued.notifier).state=userModel;
        completer.complete(HomeScreen());
        //Navigator.pushReplacementNamed(context, AppPageRoutes.HOME.getPage());
      },
      initial: () {

        ref.read(userLogued.notifier).state=null;
        completer.complete(LoginScreen());
      },
      loading: () {

      },
      error: () {

        ref.read(userLogued.notifier).state=null;
        completer.complete(LoginScreen());
        //Navigator.pushReplacementNamed(context, AppPageRoutes.LOGIN.getPage());
      },
    );
    return  completer.future ;
    //print(userModel);
    /*if(userModel == null){
      ref.read(userLogued.notifier).state = null;
      completer.complete(LoginScreen());
      return  completer.future ;
    }
    else{
      completer.complete(HomeScreen());
      ref.read(userLogued.notifier).state=userModel;
      return  completer.future ;
    }*/
    //await Future.delayed(Duration(seconds: 5));
    try {
      ref.read(userLogued.notifier).state = null;
      await ref.read(sqlUserNotifier.notifier).getUser();
      final userState = ref.watch(sqlUserNotifier);
      print(userState);
      if (userState is sql_user_state.UserAvailable) {
        ref.read(userLogued.notifier).state=userState.userModel;
        print('user available: ${userState.userModel.toJson()}');
        //print('user devuleto: ${userState.state.user}');

        //ref.read(userLogued.notifier).state = userState.userModel;
        ref.read(sqlUserNotifier.notifier).reset();
      } else if (userState is Error) {
        print('user Error: ${userState}');
        ref.read(sqlUserNotifier.notifier).reset();
        completer.complete(LoginScreen());
      } else {
        print('user Cargando: ${userState}');
        //completer.complete(LoginScreen());
      }
    } catch (error) {
      print('Error en initApp: $error');
      completer.complete(LoginScreen());
    }
    return  completer.future ;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<Widget>(
      future: _initialization,
      builder: (context, snapshot) {
        print('Snapshot Connection state ${snapshot.connectionState}');
        print('Snapshot data  ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "HOV Cubetero",
            onGenerateRoute: AppRouter().generateRoute,
            theme: ThemeData(
              fontFamily: 'Helvetica',
              primaryColor: AppColors.primaryColor,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: AppColors.primaryColor,
                primary: AppColors.backgroundColor,
                background: AppColors.backgroundColor,
              ),
              appBarTheme: AppBarTheme(
                  color: AppColors.primaryColor,
                  iconTheme: IconThemeData(color: AppColors.backgroundColor)
              ),
              scaffoldBackgroundColor: AppColors.primaryColor,
              iconTheme: const IconThemeData(
                color: AppColors.backgroundColor,
              ),

            ),
            home: snapshot.data ?? LoginScreen(),
            // Resto de la configuración MaterialApp
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "HOV Cubetero",
            onGenerateRoute: AppRouter().generateRoute,
            theme: ThemeData(
              fontFamily: 'Helvetica',
              primaryColor: AppColors.backgroundColor,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: AppColors.backgroundColor,
                primary: AppColors.backgroundColor,
                background: AppColors.backgroundColor,
              ),
              appBarTheme: AppBarTheme(
                  color: AppColors.primaryColor,
                  iconTheme: IconThemeData(color: AppColors.backgroundColor)
              ),
              scaffoldBackgroundColor: AppColors.backgroundColor,
              iconTheme: const IconThemeData(
                color: AppColors.backgroundColor,
              ),

            ),
            home: Scaffold(
              body: Column(
                children: [
                  Spacer(),
                  Center(
                    child: AppImages.getLogoBlack(MediaQuery.of(context).size.width - 100, 70),
                  ),
                  const Spacer(),
                  const Center(
                    child: LoadingWidget(),),
                  Spacer(),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
