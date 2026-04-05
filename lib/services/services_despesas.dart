import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimus/models/models_despesas.dart';

class FinanceiroServiceDespesas {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _despesasCollection =>
      _firestore.collection('despesas');

  static const int _maxRecurrenceIterations = 120;

  static List<ContaCad> listaConta = [];

  static double get totalDespesasPagas =>
      listaConta.where((c) => c.pago).fold(0.0, (soma, c) => soma + c.valor);

  static double get totalDespesasPendentes =>
      listaConta.where((c) => !c.pago).fold(0.0, (soma, c) => soma + c.valor);

  static double get totalDespesas =>
      listaConta.fold(0.0, (soma, c) => soma + c.valor);

  static List<FrequenciaRecorrencia> get frequenciasRecorrenciaDisponiveis =>
      FrequenciaRecorrencia.values;

  static String rotuloFrequencia(String? valor) {
    return FrequenciaRecorrenciaX.fromValue(valor).label;
  }

  static Future<ContaCad> salvarConta(ContaCad conta) async {
    final agora = DateTime.now();

    if (conta.recorrente) {
      final frequencia =
          FrequenciaRecorrenciaX.fromValue(conta.frequenciaRecorrencia).value;
      final proximaExecucao = _startOfDay(conta.proximaExecucao ?? agora);

      final template = conta.copyWith(
        pago: false,
        recorrente: true,
        isTemplateRecorrente: true,
        frequenciaRecorrencia: frequencia,
        proximaExecucao: proximaExecucao,
        createdAt: agora,
      );

      final docRef = await _despesasCollection.add(template.toMap());
      await processarDespesasRecorrentesPendentes(apenasTemplateId: docRef.id);
      return template.copyWith(id: docRef.id);
    }

    final contaUnica = conta.copyWith(
      pago: false,
      recorrente: false,
      isTemplateRecorrente: false,
      frequenciaRecorrencia: null,
      proximaExecucao: null,
      recorrenciaId: null,
      competencia: null,
      createdAt: agora,
    );

    final docRef = await _despesasCollection.add(contaUnica.toMap());
    return contaUnica.copyWith(id: docRef.id);
  }

  static Future<List<ContaCad>> sincronizarECarregarDespesas() async {
    await processarDespesasRecorrentesPendentes();
    return carregarDespesasDoFirestore();
  }

  static Future<List<ContaCad>> carregarDespesasDoFirestore() async {
    final snapshot = await _despesasCollection.get();

    final lista =
        snapshot.docs
            .map((doc) => ContaCad.fromMap(doc.data(), id: doc.id))
            .where((conta) => !conta.isTemplateRecorrente)
            .toList()
          ..sort((a, b) {
            final dataA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dataB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dataA.compareTo(dataB);
          });

    listaConta = lista;
    return lista;
  }

  static Future<void> marcarComoPago(String id) async {
    await _despesasCollection.doc(id).update({'pago': true});
  }

  static Future<void> processarDespesasRecorrentesPendentes({
    String? apenasTemplateId,
  }) async {
    if (apenasTemplateId != null && apenasTemplateId.isNotEmpty) {
      await _processarTemplateRecorrente(
        _despesasCollection.doc(apenasTemplateId),
      );
      return;
    }

    final templates =
        await _despesasCollection
            .where('isTemplateRecorrente', isEqualTo: true)
            .get();

    for (final templateDoc in templates.docs) {
      await _processarTemplateRecorrente(templateDoc.reference);
    }
  }

  static Future<void> _processarTemplateRecorrente(
    DocumentReference<Map<String, dynamic>> templateRef,
  ) async {
    await _firestore.runTransaction((transaction) async {
      final templateSnapshot = await transaction.get(templateRef);
      if (!templateSnapshot.exists) return;

      final template = ContaCad.fromMap(
        templateSnapshot.data() ?? <String, dynamic>{},
        id: templateSnapshot.id,
      );

      if (!template.recorrente || !template.isTemplateRecorrente) return;

      final frequencia =
          FrequenciaRecorrenciaX.fromValue(
            template.frequenciaRecorrencia,
          ).value;
      final hoje = _startOfDay(DateTime.now());
      var proximaExecucao = _startOfDay(
        template.proximaExecucao ?? template.createdAt ?? hoje,
      );
      var iteracoes = 0;
      var houveAvanco = false;

      while (!proximaExecucao.isAfter(hoje)) {
        if (iteracoes >= _maxRecurrenceIterations) {
          throw StateError(
            'Limite de geracao de recorrencia excedido para ${templateRef.id}.',
          );
        }

        final competencia = _competenciaKey(proximaExecucao);
        final instanciaId = '${templateRef.id}_$competencia';
        final instanciaRef = _despesasCollection.doc(instanciaId);
        final instanciaSnapshot = await transaction.get(instanciaRef);

        if (!instanciaSnapshot.exists) {
          final instancia = template.copyWith(
            id: instanciaId,
            pago: false,
            isTemplateRecorrente: false,
            recorrenciaId: templateRef.id,
            competencia: competencia,
            createdAt: proximaExecucao,
            proximaExecucao: proximaExecucao,
          );
          final mapa = instancia.toMap();
          mapa['createdAt'] = Timestamp.fromDate(proximaExecucao);
          mapa['proximaExecucao'] = Timestamp.fromDate(proximaExecucao);
          mapa['isTemplateRecorrente'] = false;
          mapa['recorrente'] = true;
          mapa['recorrenciaId'] = templateRef.id;
          mapa['competencia'] = competencia;
          transaction.set(instanciaRef, mapa);
        }

        proximaExecucao = calcularProximaExecucao(proximaExecucao, frequencia);
        iteracoes++;
        houveAvanco = true;
      }

      if (houveAvanco || template.proximaExecucao == null) {
        transaction.update(templateRef, <String, dynamic>{
          'recorrente': true,
          'isTemplateRecorrente': true,
          'frequenciaRecorrencia': frequencia,
          'proximaExecucao': Timestamp.fromDate(proximaExecucao),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  static DateTime calcularProximaExecucao(
    DateTime referencia,
    String? frequenciaRaw,
  ) {
    final frequencia = FrequenciaRecorrenciaX.fromValue(frequenciaRaw);
    final base = _startOfDay(referencia);

    switch (frequencia) {
      case FrequenciaRecorrencia.semanal:
        return _startOfDay(base.add(const Duration(days: 7)));
      case FrequenciaRecorrencia.quinzenal:
        return _startOfDay(base.add(const Duration(days: 14)));
      case FrequenciaRecorrencia.mensal:
        return _addMonths(base, 1);
      case FrequenciaRecorrencia.bimestral:
        return _addMonths(base, 2);
      case FrequenciaRecorrencia.trimestral:
        return _addMonths(base, 3);
      case FrequenciaRecorrencia.semestral:
        return _addMonths(base, 6);
      case FrequenciaRecorrencia.anual:
        return _addMonths(base, 12);
    }
  }

  static DateTime _addMonths(DateTime date, int months) {
    final totalMonths = (date.year * 12) + (date.month - 1) + months;
    final year = totalMonths ~/ 12;
    final month = (totalMonths % 12) + 1;
    final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final day =
        date.day <= lastDayOfTargetMonth ? date.day : lastDayOfTargetMonth;
    return DateTime(year, month, day);
  }

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _competenciaKey(DateTime date) {
    final ano = date.year.toString().padLeft(4, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final dia = date.day.toString().padLeft(2, '0');
    return '$ano$mes$dia';
  }
}
