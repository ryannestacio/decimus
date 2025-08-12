class Devedor {
  final String? id;
  final String nome;
  final String descricao;
  final String endereco;
  final double valor;
  final DateTime dataVencimento;
  final bool pago;

  Devedor({
    this.id,
    required this.nome,
    required this.descricao,
    required this.endereco,
    required this.valor,
    required this.dataVencimento,
    this.pago = false,
  });

  Devedor copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? endereco,
    double? valor,
    DateTime? dataVencimento,
    bool? pago,
  }) {
    return Devedor(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      endereco: endereco ?? this.endereco,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      pago: pago ?? this.pago,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'endereco': endereco,
      'valor': valor,
      'dataVencimento': dataVencimento.toIso8601String(),
      'pago': pago,
    };
  }

  factory Devedor.fromMap(Map<String, dynamic> map, String id) {
    return Devedor(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      endereco: map['endereco'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      dataVencimento:
          DateTime.tryParse(map['dataVencimento'] ?? '') ?? DateTime.now(),
      pago: map['pago'] ?? false,
    );
  }
}
