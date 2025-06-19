import 'package:decimus/models/models_recebiveis.dart';

class FinanceiroServiceRecebiveis {
  static List<Recebimento> listaRecebimentos = [];

  static double get totalRecebiveis => listaRecebimentos
      .where((r) => r.pago)
      .fold(0.0, (soma, r) => soma + r.valor);
}
