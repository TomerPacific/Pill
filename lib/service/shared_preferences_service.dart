import 'dart:async';
import 'dart:convert';
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

      final rawValue = _sharedPreferences.get(key);
      if (rawValue is! String) continue;
      final legacyValue = rawValue;

      try {
        if (key.startsWith(legacyTakenKey)) {
          final datePart = key.substring(legacyTakenKey.length);
          // Match "M/D" or "MM/DD" but NOT "YYYY/M/D"
          if (RegExp(r'^\d{1,2}/\d{1,2}$').hasMatch(datePart)) {
            if (!_isValidJsonList(legacyValue, key)) {
              if (!(await _sharedPreferences.remove(key))) {
                log("Failed to remove invalid JSON key '$key' during yearly migration (taken)",
                    level: 1000);
                allSucceeded = false;
              }
              continue;
            }
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
          if (!_isValidJsonList(legacyValue, key)) {
            if (!(await _sharedPreferences.remove(key))) {
              log("Failed to remove invalid JSON key '$key' during yearly migration (to take)",
                  level: 1000);
              allSucceeded = false;
            }
            continue;
          }
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
    final migratedToYearly =
        _sharedPreferences.getBool(migratedToYearlyKeysKey) ?? false;
    if (!migratedToYearly) {
      return;
    }

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
        try {
          final rawValue = _sharedPreferences.get(key);
          if (rawValue is String) {
            if (!_isValidJsonList(rawValue, key)) {
              if (!(await _sharedPreferences.remove(key))) {
                log("Failed to remove invalid JSON key '$key' during prefixed migration",
                    level: 1000);
                allSucceeded = false;
              }
              continue;
            }
            final targetKey = "$legacyToTakeKey$key";
            final existingValue = _sharedPreferences.getString(targetKey);

            String migratedValue;
            if (existingValue != null) {
              final legacyPills = PillToTake.decode(rawValue)
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
              migratedValue = rawValue;
            }

            if (await _sharedPreferences.setString(targetKey, migratedValue)) {
              if (!(await _sharedPreferences.remove(key))) {
                log("Failed to remove non-prefixed key '$key' after migration to '$targetKey'",
                    level: 1000);
                allSucceeded = false;
              }
            } else {
              log("Failed to write prefixed key '$targetKey'", level: 1000);
              allSucceeded = false;
            }
          }
        } catch (e, st) {
          log("Error migrating prefixed key '$key': $e",
              level: 1000, stackTrace: st);
          allSucceeded = false;
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
    final migratedToYearly =
        _sharedPreferences.getBool(migratedToYearlyKeysKey) ?? false;
    final migratedToPrefixed =
        _sharedPreferences.getBool(migratedToPrefixedKeysKey) ?? false;

    if (!migratedToYearly || !migratedToPrefixed) {
      return;
    }

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

      // Restrict migration to expected pre-delimiter yearly shapes
      if (RegExp(r'^pillsTaken\d{4}/\d{1,2}/\d{1,2}$').hasMatch(key)) {
        targetKey = "$pillsTakenPrefix${key.substring(legacyTakenKey.length)}";
        isTaken = true;
      } else if (RegExp(r'^pillsToTake\d{4}/\d{1,2}/\d{1,2}$').hasMatch(key)) {
        targetKey = "$pillsToTakePrefix${key.substring(legacyToTakeKey.length)}";
        isTaken = false;
      }

      if (targetKey != null) {
        try {
          final rawValue = _sharedPreferences.get(key);
          if (rawValue is String) {
            if (!_isValidJsonList(rawValue, key)) {
              if (!(await _sharedPreferences.remove(key))) {
                log("Failed to remove invalid JSON key '$key' during delimiter migration",
                    level: 1000);
                allSucceeded = false;
              }
              continue;
            }
            final existingValue = _sharedPreferences.getString(targetKey);

            String migratedValue;
            if (existingValue != null) {
              if (isTaken) {
                final legacyPills = PillTaken.decode(rawValue)
                    .map((p) => p.copyWith(pillName: p.pillName.trim()))
                    .toList();
                final existingPills = PillTaken.decode(existingValue)
                    .map((p) => p.copyWith(pillName: p.pillName.trim()))
                    .toList();
                // Combine and deduplicate exact matches
                final merged = {...legacyPills, ...existingPills}.toList();
                migratedValue = PillTaken.encode(merged);
              } else {
                final legacyPills = PillToTake.decode(rawValue)
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
              migratedValue = rawValue;
            }

            if (await _sharedPreferences.setString(targetKey, migratedValue)) {
              if (!(await _sharedPreferences.remove(key))) {
                log("Failed to remove old key '$key' after migration to '$targetKey'",
                    level: 1000);
                allSucceeded = false;
              }
            } else {
              log("Failed to write delimiter key '$targetKey'", level: 1000);
              allSucceeded = false;
            }
          }
        } catch (e, st) {
          log("Error migrating delimiter key '$key': $e",
              level: 1000, stackTrace: st);
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

  Future<bool> _setPillsForDate(String date, List<PillToTake> pills) async {
    final success = await _sharedPreferences.setString(
        pillsToTakePrefix + date, PillToTake.encode(pills));
    if (!success) {
      log("Failed to set pills for date: $date", level: 1000);
    }
    return success;
  }

  Future<bool> _setPillsTakenForDate(String date, List<PillTaken> pillsTaken) async {
    final success = await _sharedPreferences.setString(
        pillsTakenPrefix + date, PillTaken.encode(pillsTaken));
    if (!success) {
      log("Failed to set pills taken for date: $date", level: 1000);
    }
    return success;
  }

  List<PillToTake> getPillsToTakeForDate(String date) {
    final rawValue = _sharedPreferences.get(pillsToTakePrefix + date);
    if (rawValue is String) {
      return PillToTake.decode(rawValue);
    }
    return [];
  }

  List<PillTaken> getPillsTakenForDate(String date) {
    final rawValue = _sharedPreferences.get(pillsTakenPrefix + date);
    if (rawValue is String) {
      return PillTaken.decode(rawValue);
    }
    return [];
  }

  Future<void> addPillToDates(DateTime startDate, PillToTake pill) async {
    DateTime runningDate = startDate;
    int daysToTake = pill.amountOfDaysToTake;
    final pillWithTrimmedName = pill.copyWith(pillName: pill.pillName.trim());
    while (daysToTake > 0) {
      String dateStr = _dateService.formatDateForStorage(runningDate);
      List<PillToTake> pills = getPillsToTakeForDate(dateStr);
      pills.add(pillWithTrimmedName);
      await _setPillsForDate(dateStr, pills);
      runningDate = runningDate.add(const Duration(days: oneDay));
      daysToTake--;
    }
  }

  Future<List<PillTaken>> addTakenPill(PillToTake pillToTake, String date) async {
    PillTaken pill = PillTaken.extractFromPillToTake(pillToTake);
    List<PillTaken> pillsTaken = getPillsTakenForDate(date);
    pillsTaken.add(pill);
    await _setPillsTakenForDate(date, pillsTaken);
    return pillsTaken;
  }

  Future<({List<PillToTake> pillsToTake, List<PillTaken> pillsTaken})?>
      updatePillForDate(PillToTake pillToTake, String currentDate) async {
    List<PillToTake> pillsToTakeList = getPillsToTakeForDate(currentDate);

    final normalizedName = pillToTake.pillName.trim().toLowerCase();
    int pillIndex = pillsToTakeList.indexWhere(
        (element) => element.pillName.trim().toLowerCase() == normalizedName);

    if (pillIndex == -1) {
      return null;
    }

    final existingPill = pillsToTakeList[pillIndex];
    final pillToSave = pillToTake.copyWith(pillName: existingPill.pillName);

    final updatedPillsTaken = await addTakenPill(pillToSave, currentDate);

    if (pillToSave.pillRegiment == 0) {
      pillsToTakeList.removeWhere(
          (element) => element.pillName.trim().toLowerCase() == normalizedName);
      await _setPillsForDate(currentDate, pillsToTakeList);
    } else {
      pillsToTakeList[pillIndex] = pillToSave;
      await _setPillsForDate(currentDate, pillsToTakeList);
    }

    return (pillsToTake: pillsToTakeList, pillsTaken: updatedPillsTaken);
  }

  Future<List<PillToTake>> removePillFromDate(
      PillToTake pillToTake, String currentDate) async {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    final normalizedName = pillToTake.pillName.trim().toLowerCase();
    pills.removeWhere(
        (element) => element.pillName.trim().toLowerCase() == normalizedName);
    await _setPillsForDate(currentDate, pills);
    return pills;
  }

  Future<bool> clearAllPillsFromDate(DateTime dateToRemovePillsFrom) async {
    DateTime now = _dateService.now();
    DateTime runningDate = dateToRemovePillsFrom;
    bool allSucceeded = true;

    while (now.difference(runningDate).inDays >= oneDay) {
      String converted = _dateService.formatDateForStorage(runningDate);
      if (!(await _setPillsForDate(converted, []))) {
        allSucceeded = false;
      }
      if (!(await _setPillsTakenForDate(converted, []))) {
        allSucceeded = false;
      }
      runningDate = runningDate.add(const Duration(days: oneDay));
    }
    return allSucceeded;
  }

  Future<bool> setTimeWhenApplicationWasOpened() async {
    DateTime now = _dateService.now();
    final success = await _sharedPreferences.setString(timeAppOpenedKey, now.toIso8601String());
    if (!success) {
      log("Failed to set $timeAppOpenedKey", level: 1000);
    }
    return success;
  }

  DateTime? getTimeWhenApplicationWasOpened() {
    try {
      final rawValue = _sharedPreferences.get(timeAppOpenedKey);
      if (rawValue is String) {
        return DateTime.parse(rawValue);
      }
    } catch (e) {
      log("Error parsing $timeAppOpenedKey: $e", level: 1000);
    }
    return null;
  }

  Future<bool> clearAllPills() async {
    final keys = _sharedPreferences.getKeys().toList();
    bool allSucceeded = true;
    for (String key in keys) {
      if (key == timeAppOpenedKey ||
          key == darkModeKey ||
          key == migratedToYearlyKeysKey ||
          key == migratedToPrefixedKeysKey ||
          key == migratedToDelimiterKeysKey) {
        continue;
      }
      if (!(await _sharedPreferences.remove(key))) {
        log("Failed to remove key: $key", level: 1000);
        allSucceeded = false;
      }
    }
    return allSucceeded;
  }

  Future<void> clearPillsOfPastDays() async {
    try {
      DateTime? timeWhenApplicationWasOpened =
          getTimeWhenApplicationWasOpened();
      if (timeWhenApplicationWasOpened == null) {
        await setTimeWhenApplicationWasOpened();
      } else {
        DateTime now = _dateService.now();
        if (now.difference(timeWhenApplicationWasOpened).inDays >= oneDay) {
          if (await clearAllPillsFromDate(timeWhenApplicationWasOpened)) {
            await setTimeWhenApplicationWasOpened();
          } else {
            log("Failed to clear some pills of past days", level: 1000);
          }
        }
      }
    } catch (e, st) {
      log("Error clearing pills of past days: $e", level: 1000, stackTrace: st);
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

  Future<bool> saveThemeStatus(bool isDarkModeEnabled) async {
    final success = await _sharedPreferences.setBool(darkModeKey, isDarkModeEnabled);
    if (!success) {
      log("Failed to set $darkModeKey", level: 1000);
    }
    return success;
  }

  bool getThemeStatus() {
    return _sharedPreferences.getBool(darkModeKey) ?? false;
  }

  bool _isValidJsonList(String value, String key) {
    try {
      final decoded = json.decode(value);
      if (decoded is List) {
        return true;
      }
      log("Value for key '$key' is not a JSON list (type: ${decoded.runtimeType})",
          level: 1000);
    } catch (e) {
      log("Value for key '$key' is not valid JSON: $e", level: 1000);
    }
    return false;
  }
}
