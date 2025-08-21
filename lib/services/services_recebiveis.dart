import 'package:decimus/models/models_recebiveis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceiroServiceRecebiveis {
  static List<Recebimento> listaRecebimentos = [];

  static double totalRecebiveis = 0;

  static Future<void> calcularTotalRecebiveis() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('recebiveis').get();

    totalRecebiveis = snapshot.docs.fold(0.0, (soma, doc) {
      return soma + (doc['valor'] ?? 0);
    });
  }

  static Future<void> carregarRecebiveis() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('recebiveis').get();

      listaRecebimentos =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Recebimento(
              nome: data['nome'] ?? '',
              tipo: data['tipo'] ?? '',
              valor: (data['valor'] ?? 0).toDouble(),
              data:
                  data['data'] is Timestamp
                      ? (data['data'] as Timestamp).toDate()
                      : DateTime.tryParse(data['data'] ?? '') ?? DateTime.now(),
              pago: data['pago'] ?? true,
            );
          }).toList();

      // Ordenar por data (mais recentes primeiro)
      listaRecebimentos.sort((a, b) => b.data.compareTo(a.data));
    } catch (e) {
      print('Erro ao carregar recebíveis: $e');
    }
  }

  static List<Recebimento> get ultimosRecebiveis {
    // Retorna os últimos 10 recebíveis cadastrados
    return listaRecebimentos.take(10).toList();
  }
}
