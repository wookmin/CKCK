class AppRoutes {
  const AppRoutes._();

  static const String root = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String roomPrefix = '/rooms';

  static String room(String roomId) => '$roomPrefix/$roomId';

  static String? parseRoomId(String? location) {
    if (location == null || location.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(location);
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments;
    if (segments.length == 2 && segments.first == 'rooms') {
      final roomId = segments.last.trim();
      if (roomId.isNotEmpty) {
        return roomId;
      }
    }
    return null;
  }
}
