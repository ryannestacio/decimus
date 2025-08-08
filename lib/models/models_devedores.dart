class Devedor {
  final String? id;
  final String nome;
  final double valor;
  final bool pago;

  Devedor({
    this.id,
    required this.nome,
    required this.valor,
    this.pago = false,
  });

  Devedor copyWith({String? id, String? nome, double? valor, bool? pago}) {
    return Devedor(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valor: valor ?? this.valor,
      pago: pago ?? this.pago,
    );
  }
}
