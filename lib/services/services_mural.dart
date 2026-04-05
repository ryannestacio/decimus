import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimus/models/models_mural.dart';

class MuralService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'mural_items';

  // ✏️ Criar novo item
  static Future<void> criarMuralItem(MuralItem item) async {
    try {
      await _db.collection(_collection).add(item.toJson());
    } catch (e) {
      throw 'Erro ao criar item do mural: $e';
    }
  }

  // ✏️ Editar item existente
  static Future<void> atualizarMuralItem(String id, MuralItem item) async {
    try {
      await _db.collection(_collection).doc(id).update(item.toJson());
    } catch (e) {
      throw 'Erro ao atualizar item do mural: $e';
    }
  }

  // 🗑️ Deletar item
  static Future<void> deletarMuralItem(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      throw 'Erro ao deletar item do mural: $e';
    }
  }

  // 📖 Listar todos (para admin gerenciar)
  static Stream<List<MuralItem>> obterMuralItemsAdmin() {
    return _db
        .collection(_collection)
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MuralItem.fromFirestore(doc))
                  .toList()
                  .cast<MuralItem>(),
        );
  }

  // 🔍 Listar apenas publicados (o que os fieis veem)
  static Stream<List<MuralItem>> obterMuralItemsPublicos() {
    return _db
        .collection(_collection)
        .where('publicado', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final items =
              snapshot.docs.map((doc) => MuralItem.fromFirestore(doc)).toList();
          // Ordenar localmente para evitar índice composto
          items.sort((a, b) => b.data.compareTo(a.data));
          return items.cast<MuralItem>();
        });
  }

  // 🔍 Obter um item específico
  static Future<MuralItem?> obterMuralItemPorId(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (doc.exists) {
        return MuralItem.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Erro ao obter item do mural: $e';
    }
  }

  // 📊 Obter contagem de itens publicados
  static Future<int> obterContagemPublicados() async {
    try {
      final snapshot =
          await _db
              .collection(_collection)
              .where('publicado', isEqualTo: true)
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
