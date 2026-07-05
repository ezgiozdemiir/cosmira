import '../../../../core/utils/result.dart';
import '../entities/astrocartography_lines.dart';
import '../entities/astrocartography_unlock.dart';

abstract class AstrocartographyRepository {
  /// Whether Astrocartography has been unlocked for [birthDataVersion].
  /// Editing birth data bumps the version, so this goes back to false until
  /// the user unlocks again — the old unlock row is kept as history.
  Future<Result<bool>> hasUnlock({
    required String userId,
    required int birthDataVersion,
  });

  /// Unlocks Astrocartography for the user's current birth-data version,
  /// spending [amount] Stardust unless it was already unlocked for that
  /// version (never double-charges on repeat calls/re-opening the screen).
  /// [birthCity] is snapshotted so a later history view can show what birth
  /// data this unlock corresponds to.
  Future<Result<bool>> unlock({
    required String userId,
    required int amount,
    String? birthCity,
  });

  /// One entry per birth-data version ever unlocked, newest first.
  Future<Result<List<AstrocartographyUnlock>>> getHistory(String userId);

  /// Loved-One variants: scoped by `lovedOneId` instead of birthDataVersion,
  /// since a `loved_ones` row is immutable once created (no version
  /// dimension to track).
  Future<Result<bool>> hasUnlockForLovedOne(String lovedOneId);
  Future<Result<bool>> unlockForLovedOne({
    required String lovedOneId,
    required int amount,
  });

  /// Real, computed AC/DC/MC/IC lines for all 8 planets, derived from the
  /// given birth data (self or a Loved One via [lovedOneId]). Cached
  /// server-side — deterministic given the same birth data, so a cache hit
  /// never needs recomputation.
  Future<Result<AstrocartographyLines>> getLines({
    required DateTime birthDate,
    required String birthTime,
    required String birthCity,
    String? lovedOneId,
  });
}
