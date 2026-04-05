import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class MuralUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _bucketPath = 'mural_imagens';

  /// Faz upload de um arquivo de imagem local para o Firebase Storage
  /// Retorna a URL da imagem armazenada
  static Future<String> uploadImagemMural(File arquivo) async {
    try {
      print('[Upload Mobile] Iniciando upload do arquivo: ${arquivo.path}');
      final fileSize = await arquivo.length();
      print('[Upload Mobile] Tamanho do arquivo: $fileSize bytes');

      // Gerar ID único para a imagem
      const uuid = Uuid();
      final nomeArquivo =
          '${uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('[Upload Mobile] Nome do arquivo: $nomeArquivo');

      // Referência do Firebase Storage
      final referencia = _storage.ref('$_bucketPath/$nomeArquivo');
      print('[Upload Mobile] Referência criada');

      // Fazer upload do arquivo com timeout
      print('[Upload Mobile] Iniciando putFile...');
      final tarefa = await referencia
          .putFile(arquivo)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('Upload excedeu 60 segundos');
            },
          );
      print('[Upload Mobile] Upload concluído, obtendo URL...');

      // Obter URL da imagem
      final url = await tarefa.ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('getDownloadURL excedeu 30 segundos');
        },
      );
      print('[Upload Mobile] URL obtida: $url');

      return url;
    } catch (e) {
      print('[Upload Mobile] ERRO: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Faz upload de bytes de imagem (para web)
  /// Retorna a URL da imagem armazenada
  static Future<String> uploadImagemMuralBytes(Uint8List bytes) async {
    try {
      print('[Upload Web] Iniciando upload de ${bytes.length} bytes');

      // Gerar ID único para a imagem
      const uuid = Uuid();
      final nomeArquivo =
          '${uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('[Upload Web] Nome do arquivo: $nomeArquivo');

      // Referência do Firebase Storage
      final referencia = _storage.ref('$_bucketPath/$nomeArquivo');
      print('[Upload Web] Referência criada');

      // Fazer upload dos bytes com timeout
      print('[Upload Web] Iniciando putData...');
      final tarefa = await referencia
          .putData(bytes)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('Upload excedeu 60 segundos');
            },
          );
      print('[Upload Web] Upload concluído, obtendo URL...');

      // Obter URL da imagem
      final url = await tarefa.ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('getDownloadURL excedeu 30 segundos');
        },
      );
      print('[Upload Web] URL obtida: $url');

      return url;
    } catch (e) {
      print('[Upload Web] ERRO: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Deleta uma imagem do Firebase Storage pela URL
  static Future<void> deletarImagemMural(String urlImagem) async {
    try {
      final referencia = _storage.refFromURL(urlImagem);
      await referencia.delete();
    } catch (e) {
      throw Exception('Erro ao deletar imagem: $e');
    }
  }
}
