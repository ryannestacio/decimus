import 'package:decimus/models/models_despesas.dart';

class FinanceiroServiceDespesas {
  static List<ContaCad> listaConta = [];

  static double get totalDespesasPagas =>
      listaConta.where((c) => c.pago).fold(0.0, (soma, c) => soma + c.valor);

  static double get totalDespesasPendentes =>
      listaConta.where((c) => !c.pago).fold(0.0, (soma, c) => soma + c.valor);

  static double get totalDespesas =>
      listaConta.fold(0.0, (soma, c) => soma + c.valor);
}
