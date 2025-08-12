import 'package:decimus/services/services_recebiveis.dart';
import 'package:decimus/services/services_devedores.dart';

class FinanceiroServicesGlobal {
  static double get totalEmCaixa =>
      FinanceiroServiceRecebiveis.totalRecebiveis +
      FinanceiroServiceDevedores.totalPagamentosRecebidos;
}
