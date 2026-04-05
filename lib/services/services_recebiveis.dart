import 'package:decimus/models/models_recebiveis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FinanceiroServiceRecebiveis {
  static List<Recebimento> listaRecebimentos = [];

  static double totalRecebiveis = 0;

  static Future<void> calcularTotalRecebiveis() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('recebiveis').get();

    totalRecebiveis = snapshot.docs.fold(0.0, (soma, doc) {
      return soma + _toDouble(doc.data()['valor']);
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
              nome: (data['nome'] ?? '').toString(),
              tipo: (data['tipo'] ?? data['descricao'] ?? '').toString(),
              valor: _toDouble(data['valor']),
              data:
                  data['data'] is Timestamp
                      ? (data['data'] as Timestamp).toDate()
                      : DateTime.tryParse(data['data'] ?? '') ?? DateTime.now(),
              pago: _toBool(data['pago']),
            );
          }).toList();

      // Sort by date (most recent first)
      listaRecebimentos.sort((a, b) => b.data.compareTo(a.data));
    } catch (e, s) {
      _debugError('Erro ao carregar recebiveis', e, s);
    }
  }

  static List<Recebimento> get ultimosRecebiveis {
    return listaRecebimentos.take(10).toList();
  }

  static double _toDouble(dynamic valor) {
    if (valor is num) return valor.toDouble();
    if (valor is String) return double.tryParse(valor) ?? 0.0;
    return 0.0;
  }

  static bool _toBool(dynamic valor) {
    if (valor is bool) return valor;
    if (valor is String) {
      final normalized = valor.toLowerCase().trim();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    // Backward compatibility: old records had no `pago` field.
    return true;
  }

  static void _debugError(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[FinanceiroServiceRecebiveis] $message: $error');
    debugPrint('$stackTrace');
  }
}
