import 'package:decimus/models/models_devedores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FinanceiroServiceDevedores {
  static List<Devedor> listDevedor = [];
  static double get devedoresPagos =>
      listDevedor.where((p) => p.pago).fold(0.0, (soma, p) => soma + p.valor);
  static double get devedoresPendentes =>
      listDevedor.where((p) => !p.pago).fold(0.0, (soma, p) => soma + p.valor);

  // Total de pagamentos recebidos (parciais + totais)
  static double _totalPagamentosRecebidos = 0.0;
  static double get totalPagamentosRecebidos => _totalPagamentosRecebidos;

  // Lista de devedores pagos
  static List<Devedor> get ultimosDevedoresPagos {
    final pagos =
        listDevedor.where((d) => d.pago).toList()
          ..sort((a, b) => b.dataVencimento.compareTo(a.dataVencimento));
    return pagos.take(10).toList();
  }

  static Future<void> salvarDevedor(Devedor devedor) async {
    await FirebaseFirestore.instance.collection('devedores').add({
      'nome': devedor.nome,
      'descricao': devedor.descricao,
      'endereco': devedor.endereco,
      'valorOriginal': devedor.valorOriginal,
      'valor': devedor.valor,
      'data-vencimento': Timestamp.fromDate(devedor.dataVencimento),
      'pago': devedor.pago,
      'createdAt': Timestamp.now(),
    });
  }

  static Future<void> carregarDevedores() async {
    try {
      // Limpa a lista antes de recarregar para evitar duplicações
      listDevedor.clear();

      // Carrega pagamentos para conseguir reconstruir o valor original se faltar
      final pagamentosSnapshot =
          await FirebaseFirestore.instance
              .collection('pagamentos_devedores')
              .get();

      final Map<String, double> totalPagoPorDevedor = {};
      for (final doc in pagamentosSnapshot.docs) {
        final data = doc.data();
        final String devedorId = (data['devedorId'] ?? '').toString();
        final double valorPago = (data['valorPago'] ?? 0).toDouble();
        if (devedorId.isEmpty) continue;
        totalPagoPorDevedor[devedorId] =
            (totalPagoPorDevedor[devedorId] ?? 0.0) + valorPago;
      }

      final snapshot =
          await FirebaseFirestore.instance.collection('devedores').get();

      listDevedor = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final bool pago = data['pago'] ?? false;
          final double valorAtual = (data['valor'] ?? 0).toDouble();
          final double valorOriginalDoc =
              (data['valorOriginal'] ?? 0).toDouble();
          final double totalPago = totalPagoPorDevedor[doc.id] ?? 0.0;
          final double valorOriginalCalculado =
              valorOriginalDoc > 0
                  ? valorOriginalDoc
                  : (totalPago + valorAtual);

          // Backfill no Firebase quando valorOriginal estiver faltando e for possível calcular
          if ((valorOriginalDoc <= 0) && (valorOriginalCalculado > 0)) {
            try {
              await FirebaseFirestore.instance
                  .collection('devedores')
                  .doc(doc.id)
                  .update({'valorOriginal': valorOriginalCalculado});
            } catch (_) {}
          }

          final devedor = Devedor(
            id: doc.id,
            nome: data['nome'] ?? '',
            descricao: data['descricao'] ?? '',
            endereco: data['endereco'] ?? '',
            valorOriginal: valorOriginalCalculado,
            valor: pago ? 0.0 : valorAtual,
            dataVencimento:
                data['data-vencimento'] is Timestamp
                    ? (data['data-vencimento'] as Timestamp).toDate()
                    : DateTime.tryParse(data['data-vencimento'] ?? '') ??
                        DateTime.now(),
            pago: pago,
          );
          return devedor;
        }).toList(),
      );
      _debugLog('Devedores carregados: ${listDevedor.length}');

      // Carrega o total de pagamentos para atualizar o caixa
      await carregarTotalPagamentos();
    } catch (e, s) {
      _debugError('Erro ao carregar devedores', e, s);
    }
  }

  static Future<void> marcarComoPago(String id) async {
    final firestore = FirebaseFirestore.instance;
    final devedorRef = firestore.collection('devedores').doc(id);
    final pagamentoRef = firestore.collection('pagamentos_devedores').doc();

    await firestore.runTransaction((transaction) async {
      final devedorSnapshot = await transaction.get(devedorRef);
      if (!devedorSnapshot.exists) {
        throw Exception('Devedor nao encontrado.');
      }

      final data = devedorSnapshot.data() ?? <String, dynamic>{};
      final bool jaPago = data['pago'] == true;
      final double valorAtual = _toDouble(data['valor']);
      final String devedorNome = (data['nome'] ?? '').toString();

      if (jaPago || valorAtual <= 0) {
        throw Exception('Este devedor ja esta quitado.');
      }

      transaction.set(pagamentoRef, {
        'devedorId': id,
        'devedorNome': devedorNome,
        'valorPago': valorAtual,
        'dataPagamento': Timestamp.now(),
        'tipo': 'total',
        'valorRestante': 0.0,
      });

      transaction.update(devedorRef, {'pago': true, 'valor': 0.0});
    });

    await carregarDevedores(); // recarrega lista
  }

  static Future<void> registrarPagamentoParcial(
    String id,
    double valorPago,
  ) async {
    try {
      if (valorPago <= 0) {
        throw Exception('O valor do pagamento deve ser maior que zero.');
      }

      final firestore = FirebaseFirestore.instance;
      final devedorRef = firestore.collection('devedores').doc(id);
      final pagamentoRef = firestore.collection('pagamentos_devedores').doc();

      await firestore.runTransaction((transaction) async {
        final devedorSnapshot = await transaction.get(devedorRef);
        if (!devedorSnapshot.exists) {
          throw Exception('Devedor nao encontrado.');
        }

        final data = devedorSnapshot.data() ?? <String, dynamic>{};
        final bool jaPago = data['pago'] == true;
        final double valorAtual = _toDouble(data['valor']);
        final String devedorNome = (data['nome'] ?? '').toString();

        if (jaPago || valorAtual <= 0) {
          throw Exception('Este devedor ja esta quitado.');
        }

        if (valorPago > valorAtual) {
          throw Exception(
            'O valor do pagamento excede o saldo atual do devedor.',
          );
        }

        final novoValor = valorAtual - valorPago;
        final bool quitado = novoValor <= 0.000001;

        transaction.set(pagamentoRef, {
          'devedorId': id,
          'devedorNome': devedorNome,
          'valorPago': valorPago,
          'dataPagamento': Timestamp.now(),
          'tipo': quitado ? 'total' : 'parcial',
          'valorRestante': quitado ? 0.0 : novoValor,
        });

        if (quitado) {
          transaction.update(devedorRef, {'valor': 0.0, 'pago': true});
        } else {
          transaction.update(devedorRef, {'valor': novoValor, 'pago': false});
        }
      });

      // Recarrega a lista do Firebase para garantir sincronização
      await carregarDevedores();
    } catch (e, s) {
      _debugError('Erro no registrarPagamentoParcial', e, s);
      rethrow;
    }
  }

  // Carrega o total de pagamentos recebidos
  static Future<void> carregarTotalPagamentos() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('pagamentos_devedores')
              .get();

      _totalPagamentosRecebidos = snapshot.docs.fold(0.0, (soma, doc) {
        final data = doc.data();
        return soma + _toDouble(data['valorPago']);
      });

      _debugLog(
        'Total de pagamentos carregado: R\$ ${_totalPagamentosRecebidos.toStringAsFixed(2)}',
      );
    } catch (e, s) {
      _debugError('Erro ao carregar total de pagamentos', e, s);
      _totalPagamentosRecebidos = 0.0;
    }
  }

  static double _toDouble(dynamic valor) {
    if (valor is num) return valor.toDouble();
    if (valor is String) return double.tryParse(valor) ?? 0.0;
    return 0.0;
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint('[FinanceiroServiceDevedores] $message');
  }

  static void _debugError(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[FinanceiroServiceDevedores] $message: $error');
    debugPrint('$stackTrace');
  }
}
