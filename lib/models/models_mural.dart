import 'package:cloud_firestore/cloud_firestore.dart';

class MuralItem {
  final String id;
  final String titulo;
  final String descricao;
  final String tipo; // 'evento', 'aviso', 'missa', 'culto'
  final DateTime data;
  final String? imagemUrl;
  final bool publicado;
  final DateTime criadoEm;

  MuralItem({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.data,
    this.imagemUrl,
    this.publicado = false,
    required this.criadoEm,
  });

  // Converter para JSON (enviar pro Firestore)
  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'descricao': descricao,
    'tipo': tipo,
    'data': Timestamp.fromDate(data),
    'imagemUrl': imagemUrl,
    'publicado': publicado,
    'criadoEm': Timestamp.fromDate(criadoEm),
  };

  // Converter do Firestore para objeto
  factory MuralItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Converter data com suporte para tanto Timestamp quanto String
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is Timestamp) return dateValue.toDate();
      if (dateValue is String) return DateTime.parse(dateValue);
      return DateTime.now();
    }

    return MuralItem(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      tipo: data['tipo'] ?? 'aviso',
      data: parseDate(data['data']),
      imagemUrl: data['imagemUrl'],
      publicado: data['publicado'] ?? false,
      criadoEm: parseDate(data['criadoEm']),
    );
  }

  // Copiar com mudanças
  MuralItem copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? tipo,
    DateTime? data,
    String? imagemUrl,
    bool? publicado,
    DateTime? criadoEm,
  }) {
    return MuralItem(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      data: data ?? this.data,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      publicado: publicado ?? this.publicado,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
