import 'package:decimus/models/models_devedores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceiroServiceDevedores {
  static List<Devedor> listDevedor = [];
  static double get devedoresPagos =>
      listDevedor.where((p) => p.pago).fold(0.0, (soma, p) => soma + p.valor);
  static double get devedoresPendentes =>
      listDevedor.where((p) => !p.pago).fold(0.0, (soma, p) => soma + p.valor);

  // Total de pagamentos recebidos (parciais + totais)
  static double _totalPagamentosRecebidos = 0.0;
  static double get totalPagamentosRecebidos => _totalPagamentosRecebidos;

  static Future<void> salvarDevedor(Devedor devedor) async {
    await FirebaseFirestore.instance.collection('devedores').add({
      'nome': devedor.nome,
      'descricao': devedor.descricao,
      'endereco': devedor.endereco,
      'valor': devedor.valor,
      'data-vencimento': Timestamp.fromDate(devedor.dataVencimento),
      'pago': devedor.pago,
      'createdAt': Timestamp.now(),
    });
  }

  static Future<void> carregarDevedores() async {
    try {
      print('carregarDevedores: Iniciando busca no Firebase...');

      // Limpa a lista antes de recarregar para evitar duplicações
      listDevedor.clear();

      final snapshot =
          await FirebaseFirestore.instance.collection('devedores').get();

      print(
        'carregarDevedores: ${snapshot.docs.length} documentos encontrados',
      );

      listDevedor =
          snapshot.docs.map((doc) {
            final data = doc.data();
            final devedor = Devedor(
              id: doc.id,
              nome: data['nome'] ?? '',
              descricao: data['descricao'] ?? '',
              endereco: data['endereco'] ?? '',
              valor: (data['valor'] ?? 0).toDouble(),
              dataVencimento:
                  data['data-vencimento'] is Timestamp
                      ? (data['data-vencimento'] as Timestamp).toDate()
                      : DateTime.tryParse(data['data-vencimento'] ?? '') ??
                          DateTime.now(),
              pago: data['pago'] ?? false,
            );
            print(
              'carregarDevedores: Devedor carregado - ${devedor.nome}: R\$ ${devedor.valor.toStringAsFixed(2)}',
            );
            return devedor;
          }).toList();

      print(
        'carregarDevedores: Lista atualizada com ${listDevedor.length} devedores',
      );

      // Log detalhado para debug de duplicações
      print('=== VERIFICAÇÃO DE DUPLICAÇÕES ===');
      for (int i = 0; i < listDevedor.length; i++) {
        print('${i + 1}. ${listDevedor[i].nome} - ID: ${listDevedor[i].id}');
      }
      print('=== FIM VERIFICAÇÃO ===');

      // Carrega o total de pagamentos para atualizar o caixa
      await carregarTotalPagamentos();
    } catch (e) {
      print('Erro ao carregar devedores: $e');
      // Tratar o erro adequadamente
    }
  }

  static Future<void> marcarComoPago(String id) async {
    final devedor = listDevedor.firstWhere((d) => d.id == id);

    // Registra o pagamento total na coleção de pagamentos
    await FirebaseFirestore.instance.collection('pagamentos_devedores').add({
      'devedorId': id,
      'devedorNome': devedor.nome,
      'valorPago': devedor.valor,
      'dataPagamento': Timestamp.now(),
      'tipo': 'total',
      'valorRestante': 0.0,
    });

    await FirebaseFirestore.instance.collection('devedores').doc(id).update({
      'pago': true,
    });
    await carregarDevedores(); // recarrega lista
  }

  static Future<void> registrarPagamentoParcial(
    String id,
    double valorPago,
  ) async {
    try {
      print('=== INÍCIO DO PAGAMENTO PARCIAL ===');
      print('ID do devedor: $id');
      print('Valor a pagar: R\$ ${valorPago.toStringAsFixed(2)}');

      final devedor = listDevedor.firstWhere((d) => d.id == id);
      print('Devedor encontrado: ${devedor.nome}');
      print('Valor atual: R\$ ${devedor.valor.toStringAsFixed(2)}');

      final novoValor = devedor.valor - valorPago;
      print('Novo valor calculado: R\$ ${novoValor.toStringAsFixed(2)}');

      // Registra o pagamento na coleção de pagamentos
      await FirebaseFirestore.instance.collection('pagamentos_devedores').add({
        'devedorId': id,
        'devedorNome': devedor.nome,
        'valorPago': valorPago,
        'dataPagamento': Timestamp.now(),
        'tipo': novoValor <= 0 ? 'total' : 'parcial',
        'valorRestante': novoValor <= 0 ? 0.0 : novoValor,
      });

      if (novoValor <= 0) {
        print('Marcando como pago (valor restante <= 0)');
        await FirebaseFirestore.instance.collection('devedores').doc(id).update(
          {'valor': 0.0, 'pago': true},
        );
        print('Firebase atualizado: pago = true, valor = 0.0');
      } else {
        print('Atualizando valor restante');
        await FirebaseFirestore.instance.collection('devedores').doc(id).update(
          {'valor': novoValor},
        );
        print('Firebase atualizado: valor = $novoValor');
      }

      print('Recarregando lista do Firebase...');
      // Recarrega a lista do Firebase para garantir sincronização
      await carregarDevedores();
      print('Lista recarregada com sucesso');
      print('Total de devedores na lista: ${listDevedor.length}');
      print(
        'Devedor atualizado na lista: ${listDevedor.firstWhere((d) => d.id == id).nome} - R\$ ${listDevedor.firstWhere((d) => d.id == id).valor.toStringAsFixed(2)}',
      );

      // Carrega o total de pagamentos para atualizar o caixa
      await carregarTotalPagamentos();

      print('=== FIM DO PAGAMENTO PARCIAL ===');
    } catch (e) {
      print('ERRO no registrarPagamentoParcial: $e');
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
        return soma + (data['valorPago'] ?? 0).toDouble();
      });

      print(
        'Total de pagamentos carregado: R\$ ${_totalPagamentosRecebidos.toStringAsFixed(2)}',
      );
    } catch (e) {
      print('Erro ao carregar total de pagamentos: $e');
      _totalPagamentosRecebidos = 0.0;
    }
  }
}
