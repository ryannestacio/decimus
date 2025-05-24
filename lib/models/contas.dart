class ContaCad {
  final String? tipoConta;
  final String? descricao;
  final String? observacao;
  final double? valor;

  ContaCad({
    required this.tipoConta,
    required this.descricao,
    this.observacao,
    required this.valor,
  });
}

class Conta {
  String tipoConta;

  Conta({required this.tipoConta});
}
