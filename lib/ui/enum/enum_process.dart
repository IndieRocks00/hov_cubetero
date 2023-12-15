

enum ProcessType {
  ADD_CORTESIA,
  REMOVE_CORTESIA,
  READ_PULSERA,
}


extension ProcessTypeExtension on ProcessType{
  String getName(){
    switch (this){
      case ProcessType.ADD_CORTESIA:
        return 'AGREGAR';
      case ProcessType.REMOVE_CORTESIA:
        return 'REMOVER';
      case ProcessType.READ_PULSERA:
        return 'LEER PULSERA';
      default:
        return '';
    }
  }
}