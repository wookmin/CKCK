String buildRoomInviteLink(String roomId) {
  final base = Uri.base;
  if (base.hasAuthority) {
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/rooms/$roomId',
    ).toString();
  }

  return 'https://ckck.app/rooms/$roomId';
}
