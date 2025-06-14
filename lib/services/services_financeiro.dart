import 'package:decimus/models/models_despesas.dart';

class FinanceiroService {
  static List<ContaCad> despesas = [];
  static List<ContaCad> recebiveis = [];

  static double get totalDespesasPagas =>
      despesas.where((c) => c.pago).fold(0.0, (soma, c) => soma + c.valor);

  static double get totalDespesasPendentes =>
      despesas.where((c) => !c.pago).fold(0.0, (soma, c) => soma + c.valor);

  static double get totalRecebiveisPrevistos =>
      recebiveis.where((c) => !c.pago).fold(0.0, (soma, c) => soma + c.valor);

  static double get totalRecebiveisRecebidos =>
      recebiveis.where((c) => c.pago).fold(0.0, (soma, c) => soma + c.valor);

  static double get caixaAtual => totalRecebiveisRecebidos - totalDespesasPagas;
}
