class Recebimento {
  String tipo;
  double valor;
  DateTime data;
  bool pago;

  Recebimento({
    required this.tipo,
    required this.valor,
    required this.data,
    this.pago = true,
  });
}
