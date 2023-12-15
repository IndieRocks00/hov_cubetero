

import 'package:intl/intl.dart';

class DataFormater{
  static String formatCurrency(double amount){
    try{

      return NumberFormat.currency(
        locale: 'en', // Puedes cambiar la localización si es necesario
        symbol: '\$', // Símbolo de la moneda
      ).format(amount);
    }catch(e){
      return 'Error Formater';
    }
  }
}