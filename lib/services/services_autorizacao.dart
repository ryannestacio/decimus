import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AutorizacaoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fallback para facilitar administração inicial.
  // Recomenda-se usar custom claims no Firebase Auth.
  static const Set<String> _adminEmails = <String>{'ryannestacio@icloud.com'};

  static Future<bool> usuarioAtualEhAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final email = user.email?.trim().toLowerCase();
    if (email != null && _adminEmails.contains(email)) {
      return true;
    }

    final porClaims = await _ehAdminPorClaims(user);
    if (porClaims) return true;

    final porFirestore = await _ehAdminPorFirestore(user.uid);
    if (porFirestore) return true;

    return false;
  }

  static Future<bool> _ehAdminPorClaims(User user) async {
    try {
      final tokenResult = await user.getIdTokenResult();
      final claims = tokenResult.claims ?? const <String, dynamic>{};
      return _mapaIndicaAdmin(claims);
    } catch (e, s) {
      _debugError('Erro ao validar claims de admin', e, s);
      return false;
    }
  }

  static Future<bool> _ehAdminPorFirestore(String uid) async {
    try {
      final refs = <DocumentReference<Map<String, dynamic>>>[
        _firestore.collection('usuarios').doc(uid),
        _firestore.collection('users').doc(uid),
      ];

      for (final ref in refs) {
        final snap = await ref.get();
        if (!snap.exists) continue;
        final data = snap.data();
        if (data == null) continue;
        if (_mapaIndicaAdmin(data)) return true;
      }

      return false;
    } catch (e, s) {
      _debugError('Erro ao validar perfil admin no Firestore', e, s);
      return false;
    }
  }

  static bool _mapaIndicaAdmin(Map<String, dynamic> data) {
    final isAdmin = data['isAdmin'];
    if (isAdmin is bool && isAdmin) return true;
    if (isAdmin is String && isAdmin.toLowerCase().trim() == 'true') {
      return true;
    }

    final role = data['role']?.toString().toLowerCase().trim();
    if (role == 'admin') return true;

    final perfil = data['perfil']?.toString().toLowerCase().trim();
    if (perfil == 'admin') return true;

    final tipo = data['tipo']?.toString().toLowerCase().trim();
    if (tipo == 'admin') return true;

    return false;
  }

  static void _debugError(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[AutorizacaoService] $message: $error');
    debugPrint('$stackTrace');
  }
}
