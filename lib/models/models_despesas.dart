import 'package:cloud_firestore/cloud_firestore.dart';

enum FrequenciaRecorrencia {
  semanal,
  quinzenal,
  mensal,
  bimestral,
  trimestral,
  semestral,
  anual,
}

extension FrequenciaRecorrenciaX on FrequenciaRecorrencia {
  String get value => name;

  String get label {
    switch (this) {
      case FrequenciaRecorrencia.semanal:
        return 'Semanal';
      case FrequenciaRecorrencia.quinzenal:
        return 'Quinzenal';
      case FrequenciaRecorrencia.mensal:
        return 'Mensal';
      case FrequenciaRecorrencia.bimestral:
        return 'Bimestral';
      case FrequenciaRecorrencia.trimestral:
        return 'Trimestral';
      case FrequenciaRecorrencia.semestral:
        return 'Semestral';
      case FrequenciaRecorrencia.anual:
        return 'Anual';
    }
  }

  static FrequenciaRecorrencia fromValue(String? value) {
    return FrequenciaRecorrencia.values.firstWhere(
      (item) => item.value == value,
      orElse: () => FrequenciaRecorrencia.mensal,
    );
  }
}

class ContaCad {
  final String? id;
  final String? tipoConta;
  final String? descricao;
  final String? observacao;
  final double valor;
  final bool pago;
  final DateTime? createdAt;
  final bool recorrente;
  final bool isTemplateRecorrente;
  final String? frequenciaRecorrencia;
  final DateTime? proximaExecucao;
  final String? recorrenciaId;
  final String? competencia;

  ContaCad({
    this.id,
    required this.tipoConta,
    required this.descricao,
    this.observacao,
    required this.valor,
    this.pago = false,
    this.createdAt,
    this.recorrente = false,
    this.isTemplateRecorrente = false,
    this.frequenciaRecorrencia,
    this.proximaExecucao,
    this.recorrenciaId,
    this.competencia,
  });

  ContaCad copyWith({
    String? id,
    String? tipoConta,
    String? descricao,
    String? observacao,
    double? valor,
    bool? pago,
    DateTime? createdAt,
    bool? recorrente,
    bool? isTemplateRecorrente,
    String? frequenciaRecorrencia,
    DateTime? proximaExecucao,
    String? recorrenciaId,
    String? competencia,
  }) {
    return ContaCad(
      id: id ?? this.id,
      tipoConta: tipoConta ?? this.tipoConta,
      descricao: descricao ?? this.descricao,
      observacao: observacao ?? this.observacao,
      valor: valor ?? this.valor,
      pago: pago ?? this.pago,
      createdAt: createdAt ?? this.createdAt,
      recorrente: recorrente ?? this.recorrente,
      isTemplateRecorrente: isTemplateRecorrente ?? this.isTemplateRecorrente,
      frequenciaRecorrencia:
          frequenciaRecorrencia ?? this.frequenciaRecorrencia,
      proximaExecucao: proximaExecucao ?? this.proximaExecucao,
      recorrenciaId: recorrenciaId ?? this.recorrenciaId,
      competencia: competencia ?? this.competencia,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tipoConta': tipoConta ?? '',
      'descricao': descricao ?? '',
      'observacao': observacao ?? '',
      'valor': valor,
      'pago': pago,
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
      'recorrente': recorrente,
      'isTemplateRecorrente': isTemplateRecorrente,
      'frequenciaRecorrencia': frequenciaRecorrencia,
      'proximaExecucao':
          proximaExecucao != null ? Timestamp.fromDate(proximaExecucao!) : null,
      'recorrenciaId': recorrenciaId,
      'competencia': competencia,
    };
  }

  factory ContaCad.fromMap(Map<String, dynamic> map, {String? id}) {
    return ContaCad(
      id: id,
      tipoConta: (map['tipoConta'] ?? '').toString(),
      descricao: (map['descricao'] ?? '').toString(),
      observacao: (map['observacao'] ?? '').toString(),
      valor: _toDouble(map['valor']),
      pago: map['pago'] == true,
      createdAt: _toDate(map['createdAt']),
      recorrente: map['recorrente'] == true,
      isTemplateRecorrente: map['isTemplateRecorrente'] == true,
      frequenciaRecorrencia: map['frequenciaRecorrencia']?.toString(),
      proximaExecucao: _toDate(map['proximaExecucao']),
      recorrenciaId: map['recorrenciaId']?.toString(),
      competencia: map['competencia']?.toString(),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class Conta {
  String tipoConta;

  Conta({required this.tipoConta});
}
