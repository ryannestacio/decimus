import 'package:decimus/services/global_services.dart';
import 'package:decimus/services/services_despesas.dart';

class FinanceiroServiceCaixa {
  static double get totalCaixaDef =>
      FinanceiroServicesGlobal.totalEmCaixa -
      FinanceiroServiceDespesas.totalDespesasPagas;
}
