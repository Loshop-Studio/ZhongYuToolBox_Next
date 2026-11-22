/// The built-in index supplied by the ZhongYu Toolbox project.
const String officialPluginIndexUrl =
    'https://git.loshop.com.cn/LoshopStudio/ZytbAddonIndex/raw/branch/main/index.txt';

/// Returns the stable identity of an index source URL.
///
/// The host app adds `v` only to the request URL to bypass caches. It is not a
/// part of the configured source identity and must not make the official
/// source look like a user source after a refresh or restart.
String canonicalPluginSourceUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return value.trim();
  final query = <String, String>{
    for (final entry in uri.queryParameters.entries)
      if (entry.key.toLowerCase() != 'v') entry.key: entry.value,
  };
  final normalized = Uri(
    scheme: uri.scheme.toLowerCase(),
    userInfo: uri.userInfo,
    host: uri.host.toLowerCase(),
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
    queryParameters: query.isEmpty ? null : query,
  );
  return normalized.toString();
}

/// A user-configurable plugin index source.
class PluginIndexSource {
  const PluginIndexSource({
    required this.url,
    this.autoUpdate = false,
    this.displayName = '',
  });

  final String url;
  final bool autoUpdate;
  final String displayName;

  bool get isOfficial =>
      canonicalPluginSourceUrl(url) ==
      canonicalPluginSourceUrl(officialPluginIndexUrl);

  String get title {
    if (displayName.trim().isNotEmpty) return displayName.trim();
    try {
      final host = Uri.parse(url).host;
      if (host.isNotEmpty) return host;
    } catch (_) {
      // Fall through to the URL for malformed user input; validation happens
      // before a request is made.
    }
    return url;
  }

  PluginIndexSource copyWith({bool? autoUpdate, String? displayName}) {
    return PluginIndexSource(
      url: url,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      displayName: displayName ?? this.displayName,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'autoUpdate': autoUpdate,
    if (displayName.trim().isNotEmpty) 'displayName': displayName.trim(),
  };

  factory PluginIndexSource.fromJson(Map<String, dynamic> json) {
    final url = (json['url'] ?? '').toString().trim();
    if (url.isEmpty) throw const FormatException('插件索引源 URL 不能为空');
    return PluginIndexSource(
      url: url,
      autoUpdate: json['autoUpdate'] == true,
      displayName: (json['displayName'] ?? '').toString().trim(),
    );
  }
}

/// A strict three-part plugin version used by index resolution.
class PluginVersion implements Comparable<PluginVersion> {
  const PluginVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static final RegExp pattern = RegExp(r'^(\d+)\.(\d+)\.(\d+)$');

  static PluginVersion? tryParse(String? value) {
    final text = value?.trim() ?? '';
    final match = pattern.firstMatch(text);
    if (match == null) return null;
    return PluginVersion(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static PluginVersion parse(String value) {
    final parsed = tryParse(value);
    if (parsed == null) throw FormatException('版本号必须是 x.y.z：$value');
    return parsed;
  }

  @override
  int compareTo(PluginVersion other) {
    final majorResult = major.compareTo(other.major);
    if (majorResult != 0) return majorResult;
    final minorResult = minor.compareTo(other.minor);
    if (minorResult != 0) return minorResult;
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';

  @override
  bool operator ==(Object other) {
    return other is PluginVersion && compareTo(other) == 0;
  }

  @override
  int get hashCode => Object.hash(major, minor, patch);
}

/// Optional metadata stored next to a plugin package as `detail.txt`.
///
/// The first three lines are author, version and update log.  The parser is
/// intentionally tolerant because older indexes do not provide this file and
/// a malformed detail file must not make an otherwise valid catalog unusable.
class PluginIndexDetail {
  const PluginIndexDetail({
    this.author = '',
    this.version,
    this.updateLog = '',
  });

  final String author;
  final String? version;
  final String updateLog;

  PluginVersion? get parsedVersion => PluginVersion.tryParse(version);

  bool get isEmpty =>
      author.trim().isEmpty &&
      (version == null || version!.trim().isEmpty) &&
      updateLog.trim().isEmpty;
}

/// One row parsed from an index source.
class PluginIndexEntry {
  const PluginIndexEntry({
    required this.uuid,
    required this.version,
    required this.name,
    required this.description,
    required this.source,
    required this.sourceOrder,
    this.detail,
  });

  final String uuid;
  final String? version;
  final String name;
  final String description;
  final PluginIndexSource source;
  final int sourceOrder;
  final PluginIndexDetail? detail;

  String get id => uuid;

  PluginVersion? get parsedVersion => PluginVersion.tryParse(version);

  /// Version declared by the index row, falling back to detail.txt for old
  /// rows that predate the `@version` syntax.  `version` itself remains the
  /// index-row value so cross-source merging preserves its declared priority.
  String? get displayVersion => version ?? detail?.version;

  PluginVersion? get effectiveParsedVersion =>
      parsedVersion ?? detail?.parsedVersion;

  String get sourceUrl => source.url;

  String get downloadUrl => deriveDownloadUrl(source.url, uuid);

  String get detailUrl => deriveDetailUrl(source.url, uuid);

  PluginIndexEntry copyWith({String? version, PluginIndexDetail? detail}) =>
      PluginIndexEntry(
        uuid: uuid,
        version: version ?? this.version,
        name: name,
        description: description,
        source: source,
        sourceOrder: sourceOrder,
        detail: detail ?? this.detail,
      );
}

class PluginIndexDocument {
  const PluginIndexDocument({
    required this.source,
    required this.sourceOrder,
    required this.entries,
    this.issues = const <String>[],
  });

  final PluginIndexSource source;
  final int sourceOrder;
  final List<PluginIndexEntry> entries;
  final List<String> issues;
}

/// Parse all supported index line formats.
///
/// New format: `(uuid@1.2.3)[Name]Description` (parentheses optional).
/// Existing official indexes also use `(uuid)[Name]Description`; in that
/// legacy form the version is null and the package manifest is authoritative.
PluginIndexDocument parsePluginIndex(
  PluginIndexSource source,
  String text, {
  int sourceOrder = 0,
}) {
  final entries = <PluginIndexEntry>[];
  final issues = <String>[];
  final lines = text.split(RegExp(r'\r?\n'));
  for (var index = 0; index < lines.length; index++) {
    final raw = lines[index].trim();
    if (raw.isEmpty || raw.startsWith('#') || raw.startsWith('//')) continue;
    try {
      final parsed = _parsePluginIndexLine(raw);
      entries.add(
        PluginIndexEntry(
          uuid: parsed.uuid,
          version: parsed.version,
          name: parsed.name,
          description: parsed.description.trim(),
          source: source,
          sourceOrder: sourceOrder,
        ),
      );
    } on FormatException catch (error) {
      issues.add('第 ${index + 1} 行：${error.message}');
    }
  }
  return PluginIndexDocument(
    source: source,
    sourceOrder: sourceOrder,
    entries: List.unmodifiable(entries),
    issues: List.unmodifiable(issues),
  );
}

({String uuid, String? version, String name, String description})
_parsePluginIndexLine(String line) {
  var rest = line.trim();
  String header;
  if (rest.startsWith('(')) {
    final close = rest.indexOf(')');
    if (close <= 1) throw const FormatException('缺少有效的 UUID');
    header = rest.substring(1, close).trim();
    rest = rest.substring(close + 1).trimLeft();
  } else {
    final bracket = rest.indexOf('[');
    if (bracket <= 0) throw const FormatException('缺少 UUID');
    header = rest.substring(0, bracket).trim();
    rest = rest.substring(bracket).trimLeft();
  }

  final open = rest.indexOf('[');
  final close = rest.indexOf(']', open + 1);
  if (open != 0 || close < 1) {
    throw const FormatException('格式应为 UUID@版本[插件名称]介绍');
  }
  final name = rest.substring(open + 1, close).trim();
  if (name.isEmpty) throw const FormatException('插件名称不能为空');
  final description = rest.substring(close + 1).trim();

  final at = header.indexOf('@');
  final uuid = (at < 0 ? header : header.substring(0, at)).trim();
  final version = at < 0 ? null : header.substring(at + 1).trim();
  if (!_isSafeIndexId(uuid)) throw FormatException('无效 UUID：$uuid');
  if (at >= 0 && PluginVersion.tryParse(version) == null) {
    throw FormatException('版本号必须是三段式 x.y.z：$version');
  }
  return (
    uuid: uuid,
    version: version?.isEmpty == true ? null : version,
    name: name,
    description: description,
  );
}

bool _isSafeIndexId(String value) {
  return RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{1,127}$').hasMatch(value);
}

/// Resolve the conventional `${uuid}/${uuid}.zytbplugin` artifact path next
/// to an index URL. Query strings and fragments on the index are discarded.
String deriveDownloadUrl(String indexUrl, String uuid) {
  return _deriveArtifactUrl(indexUrl, uuid, '$uuid.zytbplugin');
}

/// Derive the conventional metadata URL `${uuid}/detail.txt` next to an
/// index file.
String deriveDetailUrl(String indexUrl, String uuid) {
  return _deriveArtifactUrl(indexUrl, uuid, 'detail.txt');
}

String _deriveArtifactUrl(String indexUrl, String uuid, String fileName) {
  final uri = Uri.parse(indexUrl);
  if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
    throw FormatException('索引源必须使用 HTTP/HTTPS：$indexUrl');
  }
  final segments = List<String>.from(uri.pathSegments);
  if (segments.isNotEmpty &&
      (segments.last.toLowerCase() == 'index.txt' ||
          segments.last.toLowerCase().endsWith('.txt'))) {
    segments.removeLast();
  }
  segments.add(uuid);
  segments.add(fileName);
  // Construct a fresh URI instead of `Uri.replace(query: '')`: the latter
  // serializes empty query/fragment delimiters (or can preserve them on older
  // Dart SDKs), which would turn a clean artifact URL into `...? #`.
  return Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    pathSegments: segments,
  ).toString();
}

/// Parse the three-line metadata format used by an index source.
PluginIndexDetail parsePluginIndexDetail(String text) {
  final lines = _joinMultilineInlineCode(text.split(RegExp(r'\r?\n')));
  final values = <String>[];

  // The official source uses a Markdown one-column table; allow plain lines
  // as well so third-party indexes need not emit Markdown.
  for (final line in lines) {
    final raw = line.trim();
    if (raw.isEmpty || _isMarkdownSeparator(raw)) continue;
    values.add(_detailLineValue(raw));
  }

  final author = values.isNotEmpty ? values[0].trim() : '';
  final rawVersion = values.length > 1 ? values[1].trim() : '';
  final version = PluginVersion.tryParse(rawVersion) == null
      ? null
      : rawVersion;
  final updateLog = values.length > 2
      ? values.sublist(2).join('\n').trim()
      : '';
  return PluginIndexDetail(
    author: author,
    version: version,
    updateLog: updateLog,
  );
}

List<String> _joinMultilineInlineCode(List<String> lines) {
  final normalized = <String>[];
  var pending = '';
  for (final line in lines) {
    pending = pending.isEmpty ? line : '$pending ${line.trim()}';
    final ticks = '`'.allMatches(pending).length;
    if (ticks.isEven) {
      normalized.add(pending);
      pending = '';
    }
  }
  if (pending.isNotEmpty) normalized.add(pending);
  return normalized;
}

String _detailLineValue(String line) {
  if (!line.contains('|')) return _stripInlineCode(line);
  var content = line;
  if (content.startsWith('|')) content = content.substring(1);
  if (content.endsWith('|')) content = content.substring(0, content.length - 1);
  return content.split('|').map(_stripInlineCode).join(' | ').trim();
}

String _stripInlineCode(String value) {
  return value.trim().replaceAll(RegExp(r'^`+|`+$'), '').trim();
}

bool _isMarkdownSeparator(String line) {
  if (!line.contains('|')) return false;
  var content = line.trim();
  if (content.startsWith('|')) content = content.substring(1);
  if (content.endsWith('|')) content = content.substring(0, content.length - 1);
  final cells = content.split('|').map((cell) => cell.trim());
  return cells.isNotEmpty &&
      cells.every((cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell));
}

/// Merge entries from multiple sources. Higher semantic versions win. For
/// equal versions (or two legacy rows without versions), the first source in
/// the supplied order wins.
List<PluginIndexEntry> mergePluginIndexDocuments(
  Iterable<PluginIndexDocument> documents,
) {
  final selected = <String, PluginIndexEntry>{};
  final orderedDocuments = documents.indexed.toList()
    ..sort((left, right) {
      final bySourceOrder = left.$2.sourceOrder.compareTo(right.$2.sourceOrder);
      return bySourceOrder != 0 ? bySourceOrder : left.$1.compareTo(right.$1);
    });
  for (final (_, document) in orderedDocuments) {
    for (final entry in document.entries) {
      final key = entry.uuid.toLowerCase();
      final current = selected[key];
      if (current == null || _shouldReplaceIndexEntry(current, entry)) {
        selected[key] = entry;
      }
    }
  }
  final result = selected.values.toList(growable: false);
  return List.unmodifiable(result);
}

bool _shouldReplaceIndexEntry(PluginIndexEntry current, PluginIndexEntry next) {
  final currentVersion = current.effectiveParsedVersion;
  final nextVersion = next.effectiveParsedVersion;
  if (currentVersion == null && nextVersion != null) return true;
  if (currentVersion != null && nextVersion == null) return false;
  if (currentVersion == null || nextVersion == null) return false;
  return nextVersion.compareTo(currentVersion) > 0;
}
