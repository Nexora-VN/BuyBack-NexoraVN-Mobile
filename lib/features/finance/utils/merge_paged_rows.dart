/// Keeps page order while ignoring rows repeated at a page boundary.
List<T> mergePagedRows<T>(
  Iterable<List<T>> pages,
  String Function(T row) idOf,
) {
  final seen = <String>{};
  final rows = <T>[];
  for (final page in pages) {
    for (final row in page) {
      final id = idOf(row);
      if (id.isEmpty || seen.add(id)) rows.add(row);
    }
  }
  return rows;
}
