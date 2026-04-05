import 'package:decimus/services/global_services.dart';
import 'package:decimus/services/services_despesas.dart';

class FinanceiroServiceCaixa {
  static double get saldoFinalDoCaixa {
    return FinanceiroServicesGlobal.totalEmCaixa -
        FinanceiroServiceDespesas.totalDespesasPagas;
  }
}
