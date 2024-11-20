import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../repositories/auth_repository.dart';

// Provider untuk AuthService
final authServiceProvider = Provider((ref) => AuthService());

// Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService =
      ref.watch(authServiceProvider); // Mendapatkan instance AuthService
  return AuthRepository(
      authService); // Membuat instance AuthRepository dengan AuthService
});
