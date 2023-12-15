
enum BankType {
  QR,
  NFC,
  EFECTIVO,
  TD,
  TC,
  DEVOLUCION,
}


extension ScanTypeExtension on BankType{
  int getBank(){
    switch (this){
      case BankType.TD:
        return 1;
      case BankType.NFC:
        return 3;
      case BankType.TC:
        return 4;
      case BankType.QR:
        return 5;
      case BankType.EFECTIVO:
        return 6;
      case BankType.DEVOLUCION:
        return 7;
      default:
        return 5;
    }
  }
}