import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';
import '../service/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());
final authRepositoryProvider = Provider((ref) => AuthRepository(ref.read(authServiceProvider)));
