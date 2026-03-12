import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voxa/feature/task/profile_cubit/prifile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final user = FirebaseAuth.instance.currentUser;

  Future<void> loadProfile() async {
    if (user == null) return;

    emit(ProfileLoading());

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final data = doc.data();

      emit(
        ProfileLoaded(
          name: data?['name'] ?? '',
          email: data?['email'] ?? '',
          photoUrl: data?['photoUrl'],
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<File?> compressImage(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressed == null) return null;

    return File(compressed.path);
  }

  Future<void> pickAndUploadImage() async {
    if (user == null) return; // This is the Firebase User

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      emit(ProfileLoading());

      final File? compressedFile = await compressImage(File(picked.path));
      if (compressedFile == null) return;

      final supabase = Supabase.instance.client;

      // Create a path using the Firebase UID to keep it organized
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'profiles/${user!.uid}/$fileName';

      try {
        // 1. Upload to Supabase
        await supabase.storage
            .from('voxa')
            .upload(
              path,
              compressedFile,
              fileOptions: const FileOptions(upsert: true),
            );

        // 2. Get the URL
        final String imageUrl = supabase.storage
            .from('voxa')
            .getPublicUrl(path);

        // 3. Update Firestore (Since your profile data lives there)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'photoUrl': imageUrl});

        print("Upload and Firestore update success");

        await loadProfile(); // Refresh the UI
      } catch (e) {
        print("Upload failed: $e");
        emit(ProfileError("Upload failed: $e"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
