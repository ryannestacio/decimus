class ContaCad {
  final String? id;
  final String? tipoConta;
  final String? descricao;
  final String? observacao;
  final double valor;
  final bool pago;

  ContaCad({
    this.id,
    required this.tipoConta,
    required this.descricao,
    this.observacao,
    required this.valor,
    this.pago = false,
  });
}

class Conta {
  String tipoConta;

  Conta({required this.tipoConta});
}
