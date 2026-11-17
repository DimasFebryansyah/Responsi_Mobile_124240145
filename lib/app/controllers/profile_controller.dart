import 'dart:convert';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  ProfileController(this._preferences, {ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker(),
      displayName =
          (_preferences.getString(_displayNameKey) ?? 'Hydra Player').obs,
      bio = (_preferences.getString(_bioKey) ?? '').obs,
      photoBase64 = (_preferences.getString(_photoKey) ?? '').obs;

  static const _displayNameKey = 'profile_display_name';
  static const _bioKey = 'profile_bio';
  static const _photoKey = 'profile_photo_base64';
  static const _maxPhotoBytes = 1024 * 1024;

  final SharedPreferences _preferences;
  final ImagePicker _imagePicker;
  final RxString displayName;
  final RxString bio;
  final RxString photoBase64;

  Future<void> saveProfile({
    required String displayName,
    required String bio,
  }) async {
    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      throw const ProfileException('Nama tampilan wajib diisi.');
    }

    final nameSaved = await _preferences.setString(
      _displayNameKey,
      normalizedName,
    );
    final bioSaved = await _preferences.setString(_bioKey, bio.trim());
    if (!nameSaved || !bioSaved) {
      throw const ProfileException('Perubahan profil tidak dapat disimpan.');
    }

    this.displayName.value = normalizedName;
    this.bio.value = bio.trim();
  }

  Future<bool> pickPhoto(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );
    if (image == null) return false;

    final bytes = await image.readAsBytes();
    if (bytes.length > _maxPhotoBytes) {
      throw const ProfileException(
        'Ukuran foto terlalu besar. Pilih foto di bawah 1 MB.',
      );
    }

    final encoded = base64Encode(bytes);
    final saved = await _preferences.setString(_photoKey, encoded);
    if (!saved) {
      throw const ProfileException('Foto profil tidak dapat disimpan.');
    }
    photoBase64.value = encoded;
    return true;
  }

  Future<void> removePhoto() async {
    final removed = await _preferences.remove(_photoKey);
    if (!removed) {
      throw const ProfileException('Foto profil tidak dapat dihapus.');
    }
    photoBase64.value = '';
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}
