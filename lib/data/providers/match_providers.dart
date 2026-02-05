import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/match_repository.dart';
import '../models/match_data.dart';
import '../models/dummy_data.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final matchListProvider =
    AsyncNotifierProvider<MatchListNotifier, List<MatchData>>(
  MatchListNotifier.new,
);

class MatchListNotifier extends AsyncNotifier<List<MatchData>> {
  @override
  Future<List<MatchData>> build() async {
    final repo = ref.watch(matchRepositoryProvider);
    final matches = await repo.getAllMatches();
    // Seed with dummy data if empty (first launch)
    if (matches.isEmpty) {
      for (final m in DummyData.recentMatches) {
        await repo.saveMatch(m);
      }
      return DummyData.recentMatches;
    }
    return matches;
  }

  Future<void> addMatch(MatchData match) async {
    final repo = ref.read(matchRepositoryProvider);
    await repo.saveMatch(match);
    ref.invalidateSelf();
  }

  Future<void> deleteMatch(String id) async {
    final repo = ref.read(matchRepositoryProvider);
    await repo.deleteMatch(id);
    ref.invalidateSelf();
  }
}

/// 주간 통계 Provider
/// - 로딩/에러 상태를 그대로 전파하여 UI에서 구분 가능
/// - matchListProvider 변경 시 자동 갱신
final weeklyStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  // matchListProvider를 await하여 로딩/에러 상태가 그대로 전파됨
  final matches = await ref.watch(matchListProvider.future);

  if (matches.isEmpty) {
    return const WeeklyStats();
  }

  // Repository를 통해 통계 계산
  final repo = ref.read(matchRepositoryProvider);
  return repo.getWeeklyStats();
});

/// 선택된 경기 ID만 저장 (메모리 경량화)
final selectedMatchIdProvider = StateProvider<String?>((ref) => null);

/// 선택된 경기 데이터 조회 (ID 기반)
/// - selectedMatchIdProvider의 ID로 repository에서 조회
/// - 캐시된 matchListProvider에서 먼저 찾고, 없으면 DB 조회
final selectedMatchProvider = FutureProvider<MatchData?>((ref) async {
  final id = ref.watch(selectedMatchIdProvider);
  if (id == null) return null;

  // 먼저 이미 로드된 목록에서 검색 (빠름)
  final matchesAsync = ref.watch(matchListProvider);
  final matches = matchesAsync.valueOrNull;
  if (matches != null) {
    final found = matches.where((m) => m.id == id).firstOrNull;
    if (found != null) return found;
  }

  // 목록에 없으면 DB에서 직접 조회
  final repo = ref.read(matchRepositoryProvider);
  return repo.getMatch(id);
});
