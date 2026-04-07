import 'dart:async';
import 'dart:developer';
import 'package:meta/meta.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int oneDay = 1;

class SharedPreferencesService {
  late DateService _dateService;
  late SharedPreferences _sharedPreferences;

  SharedPreferencesService._create(DateService dateService) {
    _dateService = dateService;
  }

  static Future<SharedPreferencesService> create(DateService dateService) async {
    return _createInternal(dateService);
  }

  @visibleForTesting
  static Future<SharedPreferencesService> createForTesting(
      DateService dateService,
      {int? migrationYear}) async {
    return _createInternal(dateService, migrationYear: migrationYear);
  }

  static Future<SharedPreferencesService> _createInternal(
      DateService dateService,
      {int? migrationYear}) async {
    SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService._create(dateService);

    sharedPreferencesService._sharedPreferences =
        await SharedPreferences.getInstance();

    await sharedPreferencesService._migrateKeys(migrationYear: migrationYear);

    return sharedPreferencesService;
  }

  Future<void> _migrateKeys({int? migrationYear}) async {
    await _migrateToYearlyKeys(migrationYear: migrationYear);
    await _migrateToPrefixedKeys();
    await _migrateToDelimiterKeys();
  }

  Future<void> _migrateToYearlyKeys({int? migrationYear}) async {
    if (_sharedPreferences.getBool(migratedToYearlyKeysKey) ?? false) {
      return;
    }

    const String legacyTakenKey = "pillsTaken";

    final keys = _sharedPreferences.getKeys().toList();
    final currentYear = migrationYear ?? _dateService.now().year;
    bool allSucceeded = true;

    for (String key in keys) {
      if (key == timeAppOpenedKey ||
          key == darkModeKey ||
          key == migratedToYearlyKeysKey ||
          key == migratedToPrefixedKeysKey ||
          key == migratedToDelimiterKeysKey) {
        continue;
      }

      final legacyValue = _sharedPreferences.getString(key);
      if (legacyValue == null) continue;

      try {
        if (key.startsWith(legacyTakenKey)) {
          final datePart = key.substring(legacyTakenKey.length);
          // Match "M/D" or "MM/DD" but NOT "YYYY/M/D"
          if (RegExp(r'^\d{1,2}/\d{1,2}$').hasMatch(datePart)) {
            final legacyPills = PillTaken.decode(legacyValue);
            final Map<int, List<PillTaken>> pillsByYear = {};
            for (final pill in legacyPills) {
              final trimmedPill =
                  pill.copyWith(pillName: pill.pillName.trim());
              final year = trimmedPill.lastTaken?.year ?? currentYear;
              pillsByYear.putIfAbsent(year, () => []).add(trimmedPill);
            }

            bool currentKeyMigrationSucceeded = true;
            for (final entry in pillsByYear.entries) {
              final year = entry.key;
              final pillsForYear = entry.value;
              final targetKey = "$legacyTakenKey$year/$datePart";
              final existingYearlyValue =
                  _sharedPreferences.getString(targetKey);

              String migratedValue;
              if (existingYearlyValue != null) {
                final existingPills = PillTaken.decode(existingYearlyValue);
                // For taken pills, combine and deduplicate exact matches
                final trimmedExisting = existingPills
                    .map((p) => p.copyWith(pillName: p.pillName.trim()))
                    .toList();
                final merged =
                    {...pillsForYear, ...trimmedExisting}.toList();
                migratedValue = PillTaken.encode(merged);
              } else {
                migratedValue = PillTaken.encode(pillsForYear);
              }

              if (!(await _sharedPreferences.setString(
                  targetKey, migratedValue))) {
                log("Failed to write migrated value for key '$targetKey'",
                    level: 1000);
                currentKeyMigrationSucceeded = false;
              }
            }

            if (currentKeyMigrationSucceeded) {
              if (!(await _sharedPreferences.remove(key))) {
                log("Failed to remove legacy key '$key' after successful migration",
                    level: 1000);
                allSucceeded = false;
              }
            } else {
              allSucceeded = false;
            }
          }
        } else if (RegExp(r'^\d{1,2}/\d{1,2}$').hasMatch(key)) {
          // PillToTake key (legacy "M/D")
          final targetKey = "$currentYear/$key";
          final legacyPills = PillToTake.decode(legacyValue)
              .map((p) => p.copyWith(pillName: p.pillName.trim()))
              .toList();
          final existingYearlyValue = _sharedPreferences.getString(targetKey);

          String migratedValue;
          if (existingYearlyValue != null) {
            final existingPills = PillToTake.decode(existingYearlyValue)
                .map((p) => p.copyWith(pillName: p.pillName.trim()))
                .toList();
            // For pills to take, prefer the newer ones if names match (case-insensitive)
            final Map<String, PillToTake> mergedMap = {};
            for (final pill in legacyPills) {
              mergedMap[pill.pillName.toLowerCase()] = pill;
            }
            for (final pill in existingPills) {
              mergedMap[pill.pillName.toLowerCase()] = pill;
            }
            migratedValue = PillToTake.encode(mergedMap.values.toList());
          } else {
            migratedValue = PillToTake.encode(legacyPills);
          }

          if (await _sharedPreferences.setString(targetKey, migratedValue)) {
            if (!(await _sharedPreferences.remove(key))) {
              log("Failed to remove legacy key '$key' after successful migration to '$targetKey'",
                  level: 1000);
              allSucceeded = false;
            }
          } else {
            log("Failed to write migrated value for key '$targetKey'",
                level: 1000);
            allSucceeded = false;
          }
        }
      } catch (e, st) {
        log("Error migrating key '$key': $e", level: 1000, stackTrace: st);
        allSucceeded = false;
      }
    }

    if (allSucceeded) {
      if (!(await _sharedPreferences.setBool(migratedToYearlyKeysKey, true))) {
        log("Failed to set migration completion flag '$migratedToYearlyKeysKey'",
            level: 1000);
      }
    }
  }

  Future<void> _migrateToPrefixedKeys() async {
    if (_sharedPreferences.getBool(migratedToPrefixedKeysKey) ?? false) {
      return;
    }

    const String legacyTakenKey = "pillsTaken";
    const String legacyToTakeKey = "pillsToTake";

    final keys = _sharedPreferences.getKeys().toList();
    bool allSucceeded = true;

    for (String key in keys) {
      if (key == timeAppOpenedKey ||
          key == darkModeKey ||
          key == migratedToYearlyKeysKey ||
          key == migratedToPrefixedKeysKey ||
          key == migratedToDelimiterKeysKey ||
          key.startsWith(legacyTakenKey) ||
          key.startsWith(legacyToTakeKey)) {
        continue;
      }

      // Identify keys that are YYYY/M/D (already migrated to yearly format but not yet prefixed)
      if (RegExp(r'^\d{4}/\d{1,2}/\d{1,2}$').hasMatch(key)) {
        final legacyValue = _sharedPreferences.getString(key);
        if (legacyValue != null) {
          try {
            final targetKey = "$legacyToTakeKey$key";
            final existingValue = _sharedPreferences.getString(targetKey);

            String migratedValue;
            if (existingValue != null) {
              final legacyPills = PillToTake.decode(legacyValue)
                  .map((p) => p.copyWith(pillName: p.pillName.trim()))
                  .toList();
              final existingPills = PillToTake.decode(existingValue)
                  .map((p) => p.copyWith(pillName: p.pillName.trim()))
                  .toList();

              final Map<String, PillToTake> mergedMap = {};
              for (final pill in legacyPills) {
                mergedMap[pill.pillName.toLowerCase()] = pill;
              }
              for (final pill in existingPills) {
                mergedMap[pill.pillName.toLowerCase()] = pill;
              }
              migratedValue = PillToTake.encode(mergedMap.values.toList());
            } else {
              migratedValue = legacyValue;
            }

            if (await _sharedPreferences.setString(targetKey, migratedValue)) {
              if (!(await _sharedPreferences.remove(key))) {
                log(
                    "Failed to remove non-prefixed key '$key' after migration to '$targetKey'",
                    level: 1000);
                allSucceeded = false;
              }
            } else {
              log("Failed to write prefixed key '$targetKey'", level: 1000);
              allSucceeded = false;
            }
          } catch (e, s) {
            log(
              "Failed to migrate non-prefixed key '$key' to prefixed format",
              error: e,
              stackTrace: s,
              level: 1000,
            );
            allSucceeded = false;
          }
        }
      }
    }

    if (allSucceeded) {
      if (!(await _sharedPreferences.setBool(migratedToPrefixedKeysKey, true))) {
        log("Failed to set migration completion flag '$migratedToPrefixedKeysKey'",
            level: 1000);
      }
    }
  }

  Future<void> _migrateToDelimiterKeys() async {
    if (_sharedPreferences.getBool(migratedToDelimiterKeysKey) ?? false) {
      return;
    }

    const String legacyTakenKey = "pillsTaken";
    const String legacyToTakeKey = "pillsToTake";

    final keys = _sharedPreferences.getKeys().toList();
    bool allSucceeded = true;

    for (String key in keys) {
      String? targetKey;
      bool isTaken = false;
      if (key.startsWith(legacyTakenKey) && !key.startsWith(pillsTakenPrefix)) {
        targetKey = "$pillsTakenPrefix${key.substring(legacyTakenKey.length)}";
        isTaken = true;
      } else if (key.startsWith(legacyToTakeKey) &&
          !key.startsWith(pillsToTakePrefix)) {
        targetKey = "$pillsToTakePrefix${key.substring(legacyToTakeKey.length)}";
        isTaken = false;
      }

      if (targetKey != null) {
        try {
          final legacyValue = _sharedPreferences.getString(key);
          if (legacyValue != null) {
            final existingValue = _sharedPreferences.getString(targetKey);

            String migratedValue;
            if (existingValue != null) {
              if (isTaken) {
                final legacyPills = PillTaken.decode(legacyValue)
                    .map((p) => p.copyWith(pillName: p.pillName.trim()))
                    .toList();
                final existingPills = PillTaken.decode(existingValue)
                    .map((p) => p.copyWith(pillName: p.pillName.trim()))
                    .toList();
                migratedValue = PillTaken.encode(
                    {...legacyPills, ...existingPills}.toList());
              } else {
                final legacyPills = PillToTake.decode(legacyValue)
                    .map((p) => p.copyWith(pillName: p.pillName.trim()))
                    .toList();
                final existingPills = PillToTake.decode(existingValue)
                    .map((p) => p.copyWith(pillName: p.pillName.trim()))
                    .toList();

                final Map<String, PillToTake> mergedMap = {};
                for (final pill in legacyPills) {
                  mergedMap[pill.pillName.toLowerCase()] = pill;
                }
                for (final pill in existingPills) {
                  mergedMap[pill.pillName.toLowerCase()] = pill;
                }
                migratedValue = PillToTake.encode(mergedMap.values.toList());
              }
            } else {
              migratedValue = legacyValue;
            }

            if (await _sharedPreferences.setString(targetKey, migratedValue)) {
              if (!(await _sharedPreferences.remove(key))) {
                log(
                    "Failed to remove old key '$key' after migration to '$targetKey'",
                    level: 1000);
                allSucceeded = false;
              }
            } else {
              log("Failed to write delimiter key '$targetKey'", level: 1000);
              allSucceeded = false;
            }
          }
        } catch (error, stackTrace) {
          log(
            "Failed to migrate key '$key' to '$targetKey'",
            level: 1000,
            error: error,
            stackTrace: stackTrace,
          );
          allSucceeded = false;
        }
      }
    }

    if (allSucceeded) {
      if (!(await _sharedPreferences.setBool(migratedToDelimiterKeysKey, true))) {
        log("Failed to set migration completion flag '$migratedToDelimiterKeysKey'",
            level: 1000);
      }
    }
  }

  // The Future returned by SharedPreferences write methods is intentionally
  // unawaited: SharedPreferences commits writes to its in-memory cache
  // synchronously before the Future resolves, so subsequent reads on the same
  // instance always see the updated value immediately.
  void _setPillsForDate(String date, List<PillToTake> pills) {
    unawaited(_sharedPreferences.setString(
        pillsToTakePrefix + date, PillToTake.encode(pills)));
  }

  void _setPillsTakenForDate(String date, List<PillTaken> pillsTaken) {
    unawaited(_sharedPreferences.setString(
        pillsTakenPrefix + date, PillTaken.encode(pillsTaken)));
  }

  List<PillToTake> getPillsToTakeForDate(String date) {
    String? encodedPills =
        _sharedPreferences.getString(pillsToTakePrefix + date);
    if (encodedPills != null) {
      return PillToTake.decode(encodedPills);
    }
    return [];
  }

  List<PillTaken> getPillsTakenForDate(String date) {
    String? encodedPills =
        _sharedPreferences.getString(pillsTakenPrefix + date);
    if (encodedPills != null) {
      return PillTaken.decode(encodedPills);
    }
    return [];
  }

  // void return: callers should read the specific date they need via
  // getPillsToTakeForDate(date) after this call, since a pill scheduled
  // across multiple days updates each date independently.
  void addPillToDates(DateTime startDate, PillToTake pill) {
    DateTime runningDate = startDate;
    int daysToTake = pill.amountOfDaysToTake;
    final pillWithTrimmedName = pill.copyWith(pillName: pill.pillName.trim());
    while (daysToTake > 0) {
      String dateStr = _dateService.formatDateForStorage(runningDate);
      List<PillToTake> pills = getPillsToTakeForDate(dateStr);
      pills.add(pillWithTrimmedName);
      _setPillsForDate(dateStr, pills);
      runningDate = runningDate.add(const Duration(days: oneDay));
      daysToTake--;
    }
  }

  List<PillTaken> addTakenPill(PillToTake pillToTake, String date) {
    PillTaken pill = PillTaken.extractFromPillToTake(pillToTake);
    List<PillTaken> pillsTaken = getPillsTakenForDate(date);
    pillsTaken.add(pill);
    _setPillsTakenForDate(date, pillsTaken);
    return pillsTaken;
  }

  // Returns updated lists for currentDate so the BLoC can emit state without
  // a second read. Returns null if the pill to update was not found.
  ({List<PillToTake> pillsToTake, List<PillTaken> pillsTaken})?
      updatePillForDate(PillToTake pillToTake, String currentDate) {
    List<PillToTake> pillsToTakeList = getPillsToTakeForDate(currentDate);

    final normalizedName = pillToTake.pillName.trim().toLowerCase();
    int pillIndex = pillsToTakeList.indexWhere(
        (element) => element.pillName.trim().toLowerCase() == normalizedName);

    if (pillIndex == -1) {
      return null;
    }

    final existingPill = pillsToTakeList[pillIndex];
    final pillToSave = pillToTake.copyWith(pillName: existingPill.pillName);

    // Update taken list
    final updatedPillsTaken = addTakenPill(pillToSave, currentDate);

    if (pillToSave.pillRegiment == 0) {
      pillsToTakeList.removeWhere(
          (element) => element.pillName.trim().toLowerCase() == normalizedName);
      _setPillsForDate(currentDate, pillsToTakeList);
    } else {
      pillsToTakeList[pillIndex] = pillToSave;
      _setPillsForDate(currentDate, pillsToTakeList);
    }

    return (pillsToTake: pillsToTakeList, pillsTaken: updatedPillsTaken);
  }

  // Returns the updated list for currentDate.
  List<PillToTake> removePillFromDate(
      PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    final normalizedName = pillToTake.pillName.trim().toLowerCase();
    pills.removeWhere(
        (element) => element.pillName.trim().toLowerCase() == normalizedName);
    _setPillsForDate(currentDate, pills);
    return pills;
  }

  void clearAllPillsFromDate(DateTime dateToRemovePillsFrom) {
    DateTime now = _dateService.now();
    DateTime runningDate = dateToRemovePillsFrom;

    while (now.difference(runningDate).inDays >= oneDay) {
      String converted = _dateService.formatDateForStorage(runningDate);
      _setPillsForDate(converted, []);
      _setPillsTakenForDate(converted, []);
      runningDate = runningDate.add(const Duration(days: oneDay));
    }
  }

  void setTimeWhenApplicationWasOpened() {
    DateTime now = _dateService.now();
    unawaited(
        _sharedPreferences.setString(timeAppOpenedKey, now.toIso8601String()));
  }

  DateTime? getTimeWhenApplicationWasOpened() {
    String? timeApplicationWasOpened =
        _sharedPreferences.getString(timeAppOpenedKey);
    return timeApplicationWasOpened != null
        ? DateTime.parse(timeApplicationWasOpened)
        : null;
  }

  void clearAllPills() {
    final keys = _sharedPreferences.getKeys().toList();
    for (String key in keys) {
      if (key == timeAppOpenedKey ||
          key == darkModeKey ||
          key == migratedToYearlyKeysKey ||
          key == migratedToPrefixedKeysKey ||
          key == migratedToDelimiterKeysKey) {
        continue;
      }
      unawaited(_sharedPreferences.remove(key));
    }
  }

  void clearPillsOfPastDays() {
    DateTime? timeWhenApplicationWasOpened = getTimeWhenApplicationWasOpened();
    if (timeWhenApplicationWasOpened == null) {
      setTimeWhenApplicationWasOpened();
    } else {
      DateTime now = _dateService.now();
      if (now.difference(timeWhenApplicationWasOpened).inDays >= oneDay) {
        clearAllPillsFromDate(timeWhenApplicationWasOpened);
        setTimeWhenApplicationWasOpened();
      }
    }
  }

  bool areThereAnyPillsToTake() {
    Set<String> keys = _sharedPreferences.getKeys();
    if (keys.isEmpty) return false;
    for (String key in keys) {
      if (key.startsWith(pillsToTakePrefix)) {
        List<PillToTake> pills =
            getPillsToTakeForDate(key.substring(pillsToTakePrefix.length));
        if (pills.isNotEmpty) return true;
      }
    }
    return false;
  }

  void saveThemeStatus(bool isDarkModeEnabled) {
    unawaited(_sharedPreferences.setBool(darkModeKey, isDarkModeEnabled));
  }

  bool getThemeStatus() {
    return _sharedPreferences.getBool(darkModeKey) ?? false;
  }
}
