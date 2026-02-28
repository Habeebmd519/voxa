import 'dart:convert';
import 'package:crypto/crypto.dart';

String getGravatarUrl(String email, {int size = 200}) {
  final normalizedEmail = email.trim().toLowerCase();
  final bytes = utf8.encode(normalizedEmail);
  final digest = md5.convert(bytes);
  return "https://www.gravatar.com/avatar/$digest?d=identicon&s=$size";
}
