import 'package:decimus/models/models_recebiveis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceiroServiceRecebiveis {
  static List<Recebimento> listaRecebimentos = [];

  /*static double get totalRecebiveis => listaRecebimentos
      .where((r) => r.pago)
      .fold(0.0, (soma, r) => soma + r.valor);*/

  static double totalRecebiveis = 0;

  static Future<void> calcularTotalRecebiveis() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('recebiveis').get();

    totalRecebiveis = snapshot.docs.fold(0.0, (soma, doc) {
      return soma + (doc['valor'] ?? 0);
    });
  }
}
