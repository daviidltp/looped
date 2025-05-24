import '../data/users_data.dart';

String getProfilePicForUser(String username, {String defaultPic = 'https://randomuser.me/api/portraits/men/32.jpg'}) {
  try {
    final user = usersData.firstWhere((u) => u['username'] == username);
    return user['profilePic'] as String? ?? defaultPic;
  } catch (e) {
    // User not found or profilePic is null
    return defaultPic;
  }
}