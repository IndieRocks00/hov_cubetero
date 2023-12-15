
import 'dart:core';

class FailureStatus{
  static const int empty_text                   = -1;
  static const int credential_invalid           = -2;
  static const int request_process_error        = -3;
  static const int request_error                = -4;
  static const int exception                    = -5;
  static const int server_exception             = -6;
  static const int not_connection_internet      = -7;
  static const int user_not_found               = -8;
  static const int error_data_escaneado         = -9;
  static const int error_data_user_logeado      = -10;
  static const int monto_invalido               = -11;
  static const int monto_incorrecto             = -12;
  static const int referencia_invalida          = -13;
  static const int timeout                      = -14;

  static String getMessage(int statusCode) {
    switch (statusCode) {
      case FailureStatus.empty_text:
        return "Campo vacío. Verifique.";
      case FailureStatus.credential_invalid:
        return "Credenciales Invalidas.";
      case FailureStatus.request_process_error:
        return "Error al realizar la solicitud.";
      case FailureStatus.request_error:
        return "Error al realizar la solicitud[2].";
      case FailureStatus.exception:
        return 'message';
      case FailureStatus.server_exception:
        return "Server Exception";
      case FailureStatus.not_connection_internet:
        return "Sin conexión a red, revisa tu red.";
      case FailureStatus.user_not_found:
        return "Usuario no encontrado";
      case FailureStatus.error_data_escaneado:
        return "Informacion escaneada no compatible. Prueba Escaneando nuevamente";
      case FailureStatus.error_data_user_logeado:
        return "Información de Usuario logueado invalida. Recomendación: Cerrar Sesión";
      case FailureStatus.monto_invalido:
        return "El monto ingresado es invalido";
      case FailureStatus.monto_incorrecto:
        return "El monto debe ser mayor a cero";
      case FailureStatus.referencia_invalida:
        return "La referencia es invalida. Verifica";
      case FailureStatus.timeout:
        return "La solicitud excedio el tiempo de espera";
      default:
        return 'message';
    }
  }
}


class Failure implements Exception{
  final int statusCode;
  final String message;

  Failure(this.statusCode, this.message);

  @override
  String toString() {
    return message;
  }
}