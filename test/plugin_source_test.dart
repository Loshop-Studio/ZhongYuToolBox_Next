import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/core/plugins/plugin_source_models.dart';

void main() {
  group('PluginVersion', () {
    test('compares each numeric component instead of lexically', () {
      expect(
        PluginVersion.parse('1.10.0').compareTo(PluginVersion.parse('1.9.99')),
        greaterThan(0),
      );
      expect(
        PluginVersion.parse('2.0.0').compareTo(PluginVersion.parse('1.99.99')),
        greaterThan(0),
      );
      expect(PluginVersion.parse('1.2.3'), PluginVersion(1, 2, 3));
    });

    test('accepts only three-part numeric versions', () {
      for (final value in ['1.2', '1.2.3.4', 'v1.2.3', '1.2.x', '']) {
        expect(PluginVersion.tryParse(value), isNull, reason: value);
      }
    });
  });

  group('plugin index parser', () {
    const source = PluginIndexSource(url: officialPluginIndexUrl);

    test('parses versioned rows with or without parentheses', () {
      final document = parsePluginIndex(
        source,
        '(com.example.one@1.2.3)[One] first plugin\n'
        'com.example.two@2.0.0[Two]second plugin',
      );

      expect(document.issues, isEmpty);
      expect(document.entries, hasLength(2));
      expect(document.entries[0].uuid, 'com.example.one');
      expect(document.entries[0].version, '1.2.3');
      expect(document.entries[0].name, 'One');
      expect(document.entries[0].description, 'first plugin');
      expect(document.entries[1].uuid, 'com.example.two');
      expect(document.entries[1].version, '2.0.0');
    });

    test('keeps legacy rows without a version and reports invalid rows', () {
      final document = parsePluginIndex(
        source,
        '(com.example.legacy)[Legacy] old index row\n'
        '(com.example.bad@1.2)[Bad] invalid version',
      );

      expect(document.entries, hasLength(1));
      expect(document.entries.single.version, isNull);
      expect(document.entries.single.name, 'Legacy');
      expect(document.issues, hasLength(1));
      expect(document.issues.single, contains('版本号'));
    });
  });

  group('plugin source identity', () {
    test(
      'keeps the official source official when a cache-busting v exists',
      () {
        const source = PluginIndexSource(
          url: '$officialPluginIndexUrl?v=1763720000000',
        );
        expect(source.isOfficial, isTrue);
        expect(canonicalPluginSourceUrl(source.url), officialPluginIndexUrl);
      },
    );

    test(
      'does not treat an unrelated query parameter as the official source',
      () {
        const source = PluginIndexSource(
          url: '$officialPluginIndexUrl?channel=mirror',
        );
        expect(source.isOfficial, isFalse);
      },
    );
  });

  group('plugin index detail parser', () {
    test(
      'parses author, strict three-part version, and multiline update log',
      () {
        final detail = parsePluginIndexDetail(
          'Plugin Author\n1.2.3\nFirst change\nSecond change\n',
        );

        expect(detail.author, 'Plugin Author');
        expect(detail.version, '1.2.3');
        expect(detail.parsedVersion, PluginVersion(1, 2, 3));
        expect(detail.updateLog, 'First change\nSecond change');
        expect(detail.isEmpty, isFalse);
      },
    );

    test('ignores invalid detail versions but retains other metadata', () {
      final detail = parsePluginIndexDetail('Author\nv1.2.3\nInitial release');

      expect(detail.author, 'Author');
      expect(detail.version, isNull);
      expect(detail.updateLog, 'Initial release');
    });
  });

  group('plugin index merge', () {
    const first = PluginIndexSource(url: 'https://first.example/index.txt');
    const second = PluginIndexSource(url: 'https://second.example/index.txt');

    PluginIndexDocument document(
      PluginIndexSource source,
      int order,
      String contents,
    ) => parsePluginIndex(source, contents, sourceOrder: order);

    test(
      'selects the highest version while retaining first-source order on ties',
      () {
        final merged = mergePluginIndexDocuments([
          document(
            first,
            0,
            'com.example.shared@1.9.0[First]first version\n'
            'com.example.tie@2.0.0[Tie from first]first source',
          ),
          document(
            second,
            1,
            'com.example.shared@1.10.0[Second]newer version\n'
            'com.example.tie@2.0.0[Tie from second]second source\n'
            'com.example.third@1.0.0[Third]third plugin',
          ),
        ]);

        expect(merged.map((entry) => entry.uuid), [
          'com.example.shared',
          'com.example.tie',
          'com.example.third',
        ]);
        expect(merged[0].version, '1.10.0');
        expect(merged[0].source.url, second.url);
        expect(merged[1].name, 'Tie from first');
        expect(merged[1].source.url, first.url);
      },
    );

    test('prefers a versioned row over a legacy row', () {
      final merged = mergePluginIndexDocuments([
        document(first, 0, '(com.example.shared)[Legacy]legacy'),
        document(second, 1, 'com.example.shared@0.0.1[Versioned]versioned'),
      ]);

      expect(merged.single.version, '0.0.1');
      expect(merged.single.source.url, second.url);
    });

    test('uses detail version to choose between legacy rows', () {
      final older =
          document(
            first,
            0,
            '(com.example.shared)[Older]legacy index',
          ).entries.single.copyWith(
            detail: parsePluginIndexDetail('Author A\n1.2.9\nOlder release'),
          );
      final newer =
          document(
            second,
            1,
            '(com.example.shared)[Newer]legacy index',
          ).entries.single.copyWith(
            detail: parsePluginIndexDetail('Author B\n1.10.0\nNewer release'),
          );

      final merged = mergePluginIndexDocuments([
        PluginIndexDocument(source: first, sourceOrder: 0, entries: [older]),
        PluginIndexDocument(source: second, sourceOrder: 1, entries: [newer]),
      ]);

      expect(merged.single.displayVersion, '1.10.0');
      expect(merged.single.source.url, second.url);
    });

    test('keeps first source when legacy detail versions tie', () {
      final firstEntry =
          document(
            first,
            0,
            '(com.example.shared)[First]legacy index',
          ).entries.single.copyWith(
            detail: parsePluginIndexDetail('Author A\n1.2.3\nFirst source'),
          );
      final secondEntry =
          document(
            second,
            1,
            '(com.example.shared)[Second]legacy index',
          ).entries.single.copyWith(
            detail: parsePluginIndexDetail('Author B\n1.2.3\nSecond source'),
          );

      final merged = mergePluginIndexDocuments([
        PluginIndexDocument(
          source: first,
          sourceOrder: 0,
          entries: [firstEntry],
        ),
        PluginIndexDocument(
          source: second,
          sourceOrder: 1,
          entries: [secondEntry],
        ),
      ]);

      expect(merged.single.source.url, first.url);
    });

    test(
      'uses sourceOrder for ties even when documents are supplied reversed',
      () {
        final firstEntry = document(
          first,
          0,
          'com.example.shared@1.2.3[First]first source',
        ).entries.single;
        final secondEntry = document(
          second,
          1,
          'com.example.shared@1.2.3[Second]second source',
        ).entries.single;

        final merged = mergePluginIndexDocuments([
          PluginIndexDocument(
            source: second,
            sourceOrder: 1,
            entries: [secondEntry],
          ),
          PluginIndexDocument(
            source: first,
            sourceOrder: 0,
            entries: [firstEntry],
          ),
        ]);

        expect(merged.single.source.url, first.url);
      },
    );

    test('treats UUID casing as equivalent across sources', () {
      final merged = mergePluginIndexDocuments([
        document(first, 0, 'ABCDEF@1.0.0[First]first'),
        document(second, 1, 'abcdef@2.0.0[Second]second'),
      ]);

      expect(merged, hasLength(1));
      expect(merged.single.version, '2.0.0');
    });
  });

  test('derives artifact URLs and drops index query and fragment', () {
    expect(
      deriveDownloadUrl(
        'https://git.example/group/index.txt?raw=1#catalog',
        'com.example.demo',
      ),
      'https://git.example/group/com.example.demo/com.example.demo.zytbplugin',
    );
  });

  test('parses the optional three-line detail file', () {
    final detail = parsePluginIndexDetail(
      'Alice\n1.2.3\nFirst release\n- Added the profile page',
    );

    expect(detail.author, 'Alice');
    expect(detail.version, '1.2.3');
    expect(detail.parsedVersion, PluginVersion(1, 2, 3));
    expect(detail.updateLog, 'First release\n- Added the profile page');
  });

  test('parses the official one-column Markdown detail table', () {
    final detail = parsePluginIndexDetail(
      '| `Loshop Wu` |\n'
      '| ------------ |\n'
      '| `0.0.1`     |\n'
      '| `无`          |',
    );

    expect(detail.author, 'Loshop Wu');
    expect(detail.version, '0.0.1');
    expect(detail.updateLog, '无');
  });

  test('parses Markdown cells whose inline code is split across lines', () {
    final detail = parsePluginIndexDetail(
      '| `Loshop Wu\n'
      '` |\n'
      '| ------------ |\n'
      '| `0.0.1\n'
      '`     |\n'
      '| `无\n'
      '`          |',
    );

    expect(detail.author, 'Loshop Wu');
    expect(detail.version, '0.0.1');
    expect(detail.updateLog, '无');
  });

  test('tolerates missing or malformed detail metadata', () {
    expect(parsePluginIndexDetail('').isEmpty, isTrue);

    final malformed = parsePluginIndexDetail(
      '  Bob  \nnot-a-version\n  Notes  ',
    );
    expect(malformed.author, 'Bob');
    expect(malformed.version, isNull);
    expect(malformed.parsedVersion, isNull);
    expect(malformed.updateLog, 'Notes');
  });

  test('derives detail URLs and fills versions for legacy index rows', () {
    const source = PluginIndexSource(
      url: 'https://git.example/group/index.txt?raw=1#catalog',
    );
    final entry = parsePluginIndex(
      source,
      '(com.example.legacy)[Legacy]old row',
    ).entries.single;
    final withDetail = entry.copyWith(
      detail: const PluginIndexDetail(
        author: 'Alice',
        version: '3.0.1',
        updateLog: 'Metadata version',
      ),
    );

    expect(entry.version, isNull);
    expect(withDetail.displayVersion, '3.0.1');
    expect(withDetail.effectiveParsedVersion, PluginVersion(3, 0, 1));
    expect(
      withDetail.detailUrl,
      'https://git.example/group/com.example.legacy/detail.txt',
    );
  });
}
