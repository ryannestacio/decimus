import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class MuralUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _bucketPath = 'mural_imagens';

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint('[MuralUploadService] $message');
  }

  static void _debugError(String scope, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[MuralUploadService][$scope] $error');
    debugPrint('$stackTrace');
  }

  /// Faz upload de um arquivo de imagem local para o Firebase Storage.
  /// Retorna a URL da imagem armazenada.
  static Future<String> uploadImagemMural(File arquivo) async {
    try {
      _debugLog('Upload mobile iniciado: ${arquivo.path}');
      final fileSize = await arquivo.length();
      _debugLog('Upload mobile tamanho: $fileSize bytes');

      const uuid = Uuid();
      final nomeArquivo =
          '${uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _debugLog('Upload mobile arquivo: $nomeArquivo');

      final referencia = _storage.ref('$_bucketPath/$nomeArquivo');
      _debugLog('Upload mobile referencia criada');

      _debugLog('Upload mobile putFile iniciado');
      final tarefa = await referencia
          .putFile(arquivo)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('Upload excedeu 60 segundos');
            },
          );
      _debugLog('Upload mobile concluido, solicitando URL');

      final url = await tarefa.ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('getDownloadURL excedeu 30 segundos');
        },
      );
      _debugLog('Upload mobile URL obtida');

      return url;
    } catch (e, s) {
      _debugError('uploadImagemMural', e, s);
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Faz upload de bytes de imagem (para web).
  /// Retorna a URL da imagem armazenada.
  static Future<String> uploadImagemMuralBytes(Uint8List bytes) async {
    try {
      _debugLog('Upload web iniciado: ${bytes.length} bytes');

      const uuid = Uuid();
      final nomeArquivo =
          '${uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _debugLog('Upload web arquivo: $nomeArquivo');

      final referencia = _storage.ref('$_bucketPath/$nomeArquivo');
      _debugLog('Upload web referencia criada');

      _debugLog('Upload web putData iniciado');
      final tarefa = await referencia
          .putData(bytes)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('Upload excedeu 60 segundos');
            },
          );
      _debugLog('Upload web concluido, solicitando URL');

      final url = await tarefa.ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('getDownloadURL excedeu 30 segundos');
        },
      );
      _debugLog('Upload web URL obtida');

      return url;
    } catch (e, s) {
      _debugError('uploadImagemMuralBytes', e, s);
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Deleta uma imagem do Firebase Storage pela URL.
  static Future<void> deletarImagemMural(String urlImagem) async {
    try {
      final referencia = _storage.refFromURL(urlImagem);
      await referencia.delete();
    } catch (e) {
      throw Exception('Erro ao deletar imagem: $e');
    }
  }
}
