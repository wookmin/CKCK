import 'package:ckck_app/models/player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playersProvider =
    NotifierProvider<PlayersNotifier, List<Player>>(PlayersNotifier.new);

class PlayersNotifier extends Notifier<List<Player>> {
  @override
  List<Player> build() => const <Player>[];

  void setPlayers(List<Player> players) {
    state = players;
  }

  void markReady(String userId) {
    state = state
        .map(
          (player) => player.id == userId
              ? player.copyWith(isReady: true)
              : player,
        )
        .toList();
  }
}
