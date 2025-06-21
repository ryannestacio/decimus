import 'package:decimus/models/models_devedores.dart';

class FinanceiroServiceDevedores {
  static List<Devedor> listDevedor = [];
  static double get devedoresPagos =>
      listDevedor.where((p) => p.pago).fold(0.0, (soma, p) => soma + p.valor);
  static double get devedoresPendentes =>
      listDevedor.where((p) => !p.pago).fold(0.0, (soma, p) => soma + p.valor);
}
