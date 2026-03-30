import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
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

      emit(ProfileLoaded(user: UserModel.fromMap(data!)));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update(updatedUser.toMap());

      emit(ProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
  ////

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
      // final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileName = 'profile.jpg';
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
        final cleanUrl = supabase.storage.from('voxa').getPublicUrl(path);

        // 3. Update Firestore (Since your profile data lives there)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'photoUrl': cleanUrl});

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

  /// delete supabase.profile codes
  Future<bool> deleteMyProfileImage() async {
    if (user == null) return false;

    try {
      final supabase = Supabase.instance.client;
      final path = 'profiles/${user!.uid}/profile.jpg';

      // 1. Attempt to delete from Supabase
      final result = await supabase.storage.from('voxa').remove([path]);
      print("Supabase Delete Result: $result");

      // 2. Safeguard: If the result is empty, Supabase didn't delete it (RLS issue or file missing)
      if (result.isEmpty) {
        print("Warning: File not deleted from Supabase. Check RLS policies.");
        // Optional: Return false here if you want to prevent Firestore from updating
        // when the storage deletion fails.
        // return false;
      }

      // 3. Delete from Firestore ONLY if we got past the storage check safely
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'photoUrl': FieldValue.delete()});

      // 4. Refresh UI
      await loadProfile();
      return true;
    } catch (e) {
      print("Delete failed: $e");
      return false;
    }
  }
}
