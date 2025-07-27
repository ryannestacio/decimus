import 'package:decimus/models/models_devedores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceiroServiceDevedores {
  static List<Devedor> listDevedor = [];
  static double get devedoresPagos =>
      listDevedor.where((p) => p.pago).fold(0.0, (soma, p) => soma + p.valor);
  static double get devedoresPendentes =>
      listDevedor.where((p) => !p.pago).fold(0.0, (soma, p) => soma + p.valor);

  static Future<void> salvarDevedor(Devedor devedor) async {
    await FirebaseFirestore.instance.collection('devedores').add({
      'nome': devedor.nome,
      'valor': devedor.valor,
      'pago': devedor.pago,
      'createdAt': Timestamp.now(),
    });
  }

  static Future<void> carregarDevedores() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('devedores')
            .orderBy('createdAt', descending: true)
            .get();

    listDevedor =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return Devedor(
            nome: data['nome'] ?? '',
            valor: data['valor']?.toDouble() ?? 0.0,
            pago: data['pago'] ?? false,
            id: doc.id,
          );
        }).toList();
  }

  /*static void calcularValores() {
    devedoresPendentes = 0;
    devedoresPagos = 0;

    for (var dev in listDevedor) {
      if (dev.pago) {
        devedoresPagos += dev.valor;
      } else {
        devedoresPendentes += dev.valor;
      }
    }
  }*/

  static Future<void> marcarComoPago(String id) async {
    await FirebaseFirestore.instance.collection('devedores').doc(id).update({
      'pago': true,
    });
    await carregarDevedores(); // recarrega lista
  }
}
