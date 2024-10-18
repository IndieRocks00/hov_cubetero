

abstract class RestApi{

  final int rcode;
  final String message;
  final String? balance;
  final String? boletos;

  RestApi({
      required this.rcode, required this.message, this.balance, this.boletos
  });

}