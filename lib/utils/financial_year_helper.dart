/// India financial year: April 1 to March 31.
/// FY "2024-25" = 1 Apr 2024 to 31 Mar 2025.
class FinancialYearHelper {
  /// Current FY string from today's date (e.g. "2024-25").
  static String currentFy() {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final endYear = startYear + 1;
    return '$startYear-${endYear.toString().substring(2)}';
  }

  /// Next FY after [fy] (e.g. "2024-25" -> "2025-26").
  static String nextFy(String fy) {
    final parts = fy.split('-');
    if (parts.length != 2) return currentFy();
    final start = int.tryParse(parts[0]) ?? DateTime.now().year;
    final end = int.tryParse(parts[1]) ?? (start + 1) % 100;
    final nextStart = start + 1;
    final nextEnd = end == 99 ? 1 : end + 1;
    return '$nextStart-${nextEnd.toString().padLeft(2, '0')}';
  }

  /// Previous FY before [fy] (e.g. "2024-25" -> "2023-24").
  static String previousFy(String fy) {
    final parts = fy.split('-');
    if (parts.length != 2) return currentFy();
    final start = int.tryParse(parts[0]) ?? DateTime.now().year;
    final end = int.tryParse(parts[1]) ?? (start + 1) % 100;
    if (start <= 2000) return fy;
    final prevStart = start - 1;
    final prevEnd = end == 1 ? 0 : end - 1;
    return '$prevStart-${prevEnd.toString().padLeft(2, '0')}';
  }

  /// List of previous [count] FYs before [fromFy] (e.g. fromFy=2024-25, count=5 -> [2023-24, 2022-23, ...]).
  static List<String> previousFyList(String fromFy, {int count = 10}) {
    final list = <String>[];
    String fy = fromFy;
    for (int i = 0; i < count; i++) {
      fy = previousFy(fy);
      list.add(fy);
    }
    return list;
  }

  /// List of next [count] FYs starting from [fromFy] (including fromFy). E.g. fromFy=2024-25, count=3 -> [2024-25, 2025-26, 2026-27].
  static List<String> upcomingFyList(String fromFy, {int count = 3}) {
    final list = <String>[fromFy];
    String fy = fromFy;
    for (int i = 0; i < count - 1; i++) {
      fy = nextFy(fy);
      list.add(fy);
    }
    return list;
  }

  /// Parse "2024-25" -> (2024, 2025). Returns null if invalid.
  static (int startYear, int endYear)? parseFy(String fy) {
    final parts = fy.split('-');
    if (parts.length != 2) return null;
    final start = int.tryParse(parts[0]);
    int? end = int.tryParse(parts[1]);
    if (start == null) return null;
    if (end == null) return null;
    if (end < 100) end = (start ~/ 100) * 100 + end;
    if (end != start + 1) return null;
    return (start, end);
  }

  /// Display label for FY (e.g. "2024-25" -> "FY 2024-25").
  static String displayLabel(String fy) => 'FY $fy';
}
