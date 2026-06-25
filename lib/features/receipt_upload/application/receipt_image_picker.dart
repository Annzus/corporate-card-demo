import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final receiptImagePickerProvider = Provider<ReceiptImagePicker>((ref) {
  return ImagePickerReceiptImagePicker(ImagePicker());
});

abstract interface class ReceiptImagePicker {
  Future<PickedReceiptImage?> pickImage();
}

final class PickedReceiptImage {
  const PickedReceiptImage({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

final class ImagePickerReceiptImagePicker implements ReceiptImagePicker {
  const ImagePickerReceiptImagePicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<PickedReceiptImage?> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return null;

    return PickedReceiptImage(
      fileName: _fileName(file),
      bytes: await file.readAsBytes(),
    );
  }

  String _fileName(XFile file) {
    if (file.name.isNotEmpty) return file.name;
    return file.path.split(RegExp(r'[/\\]')).last;
  }
}
