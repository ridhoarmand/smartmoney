import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/edit_profile_repository.dart';

final editProfileRepositoryProvider =
    StateNotifierProvider<EditProfileRepository, bool>((ref) {
  return EditProfileRepository(ref);
});
