import 'package:decimus/services/global_services.dart';
import 'package:decimus/services/services_despesas.dart';

class FinanceiroServiceCaixa {
  static double get saldoFinalDoCaixa {
    final total =
        FinanceiroServicesGlobal.totalEmCaixa -
        FinanceiroServiceDespesas.totalDespesasPagas;
    print('=== CAIXA ATUALIZADO ===');
    print(
      'Total em caixa: R\$ ${FinanceiroServicesGlobal.totalEmCaixa.toStringAsFixed(2)}',
    );
    print(
      'Total despesas pagas: R\$ ${FinanceiroServiceDespesas.totalDespesasPagas.toStringAsFixed(2)}',
    );
    print('Saldo final: R\$ ${total.toStringAsFixed(2)}');
    print('=== FIM CAIXA ===');
    return total;
  }
}
