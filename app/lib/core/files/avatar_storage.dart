import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Abre a [source] (câmera ou galeria) e copia a imagem escolhida para a
/// pasta de documentos do app. Devolve o arquivo salvo, ou `null` se o
/// usuário cancelar.
///
/// O [ImagePicker] devolve um arquivo no cache do sistema, que o sistema
/// pode apagar a qualquer momento. A cópia na pasta de documentos fica
/// entre as sessões.
Future<File?> pickAndStoreAvatar(ImageSource source) async {
  final picked = await ImagePicker().pickImage(source: source);
  if (picked == null) return null;

  final docsDir = await getApplicationDocumentsDirectory();
  final ext = p.extension(picked.path);
  final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$ext';
  return File(picked.path).copy(p.join(docsDir.path, fileName));
}
