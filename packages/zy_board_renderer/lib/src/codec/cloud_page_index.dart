part of 'board_file.dart';

/// Cloud Note stores Android directory names in index.json and passes each
/// existing directory to TheSketchFragment in list order, including repeats.
void _applyCloudPageIndexes(BoardArchive board, List<String> members) {
  final roots = <String, List<String>>{};
  for (final name in members.where((n) => _leaf(n) == 'index.json')) {
    final Object? value;
    try {
      value = jsonDecode(utf8.decode(board.read(name)));
    } on FormatException {
      continue;
    }
    if (value is List && value.every((p) => p is String && p.startsWith('/'))) {
      roots[_dir(name)] = value.cast<String>();
    }
  }
  if (roots.isEmpty) return;
  final scope = <String, List<String>>{};
  for (final entry in board.entries) {
    if (_leaf(entry) != 'actions.bin') continue;
    var dir = _dir(entry);
    while (dir.isNotEmpty) {
      dir = _dir(dir.substring(0, dir.length - 1));
      if (roots.containsKey(dir)) {
        (scope[dir] ??= []).add(entry);
        break;
      }
    }
  }
  // Each root owns only its Sketch pages. Sibling notebooks, protobuf page
  // routers, unrelated data, and original archive members retain their identity.
  final replacements = <String, List<String>>{};
  final grouped = <String>{};
  for (final group in scope.entries) {
    final root = group.key;
    final candidates = group.value;
    final relative = {
      for (final entry in candidates)
        _dir(entry).substring(root.length, _dir(entry).length - 1): entry,
    };
    final paths = roots[root]!;
    final scores = <String, (int, int)>{};
    for (final path in paths.toSet()) {
      for (
        var cut = path.indexOf('/');
        cut >= 0;
        cut = path.indexOf('/', cut + 1)
      ) {
        final suffix = path.substring(cut + 1);
        if (!relative.containsKey(suffix)) continue;
        final prefix = path.substring(0, cut + 1);
        final old = scores[prefix] ?? (0, 0);
        scores[prefix] = (old.$1 + 1, old.$2 + suffix.length);
      }
    }
    if (scores.isEmpty) {
      replacements[candidates.first] = [];
    } else {
      final best = scores.entries.toList()
        ..sort((a, b) {
          final count = b.value.$1.compareTo(a.value.$1);
          return count != 0 ? count : b.value.$2.compareTo(a.value.$2);
        });
      final tied = best
          .where((e) => e.value == best.first.value)
          .map((e) => e.key)
          .toList();
      if (tied.length > 1) {
        final resources = _cloudLocalResources(board, root);
        final counts = {
          for (final prefix in tied)
            prefix: resources
                .where(
                  (p) =>
                      p.startsWith(prefix) &&
                      board.has(root + p.substring(prefix.length)),
                )
                .length,
        };
        final highest = counts.values.reduce(math.max);
        tied.removeWhere((prefix) => counts[prefix] != highest);
      }
      if (tied.length != 1) {
        throw const FormatException('云笔记页面目录有多个同等匹配的来源');
      }
      final prefix = tied.single;
      replacements[candidates.first] = [
        for (final path in paths)
          if (path.startsWith(prefix))
            if (relative[path.substring(prefix.length)] case final String entry)
              entry,
      ];
    }
    grouped.addAll(candidates);
  }
  final ordered = [
    for (final entry in board.entries)
      if (replacements[entry] case final List<String> group)
        ...group
      else if (!grouped.contains(entry))
        entry,
  ];
  board.entries
    ..clear()
    ..addAll(ordered);
}

Set<String> _cloudLocalResources(BoardArchive board, String root) {
  final name = '${root}res.json';
  if (!board.has(name)) return {};
  try {
    final data = jsonDecode(utf8.decode(board.read(name)));
    if (data is List) {
      return {
        for (final row in data)
          if (row is Map && row['service'] is String && row['local'] is String)
            row['local'] as String,
      };
    }
  } on FormatException {
    return {};
  }
  return {};
}
