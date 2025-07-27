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
}
