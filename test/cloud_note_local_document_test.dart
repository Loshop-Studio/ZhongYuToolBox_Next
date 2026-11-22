import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/features/resources/cloud_note_local_document.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cloud_note_fixture_');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('discovers timestamp versions and UUID page directories', () async {
    final oldPage = Directory(
      '${root.path}${Platform.pathSeparator}100${Platform.pathSeparator}page-b',
    );
    final newPage = Directory(
      '${root.path}${Platform.pathSeparator}200${Platform.pathSeparator}page-a',
    );
    await oldPage.create(recursive: true);
    await newPage.create(recursive: true);
    await File(
      '${oldPage.path}${Platform.pathSeparator}snapshot.bin',
    ).writeAsBytes(const [0x0a, 0x00]);
    await File(
      '${newPage.path}${Platform.pathSeparator}screenshot.png',
    ).writeAsBytes(const [1, 2, 3]);

    final document = await CloudNoteLocalDocument.open(root.path);

    expect(document.pages, hasLength(2));
    expect(document.pages[0].versionId, '100');
    expect(document.pages[0].pageId, 'page-b');
    expect(document.pages[0].hasSnapshot, isTrue);
    expect(document.pages[0].hasScreenshot, isFalse);
    expect(await document.pages[0].readParsedSnapshot(), isNotNull);
    expect(document.pages[1].versionId, '200');
    expect(await document.pages[1].readScreenshot(), [1, 2, 3]);
  });

  test('lists shared images and rejects path traversal', () async {
    final page = Directory(
      '${root.path}${Platform.pathSeparator}100${Platform.pathSeparator}page',
    );
    final imageDirectory = Directory(
      '${root.path}${Platform.pathSeparator}100${Platform.pathSeparator}res${Platform.pathSeparator}image',
    );
    await page.create(recursive: true);
    await imageDirectory.create(recursive: true);
    await File(
      '${page.path}${Platform.pathSeparator}screenshot.png',
    ).writeAsBytes(const [0]);
    await File(
      '${imageDirectory.path}${Platform.pathSeparator}b.webp',
    ).writeAsBytes(const [2]);
    await File(
      '${imageDirectory.path}${Platform.pathSeparator}a.jpg',
    ).writeAsBytes(const [1]);

    final document = await CloudNoteLocalDocument.open(root.path);
    final localPage = document.pages.single;
    expect(
      (await localPage.listImageFiles()).map(
        (file) => file.uri.pathSegments.last,
      ),
      ['a.jpg', 'b.webp'],
    );
    expect(localPage.resolveImage('a.jpg')?.path, endsWith('a.jpg'));
    expect(
      localPage.resolveImage('res/image/a.jpg')?.path,
      localPage.resolveImage('a.jpg')?.path,
    );
    expect(
      localPage.resolveImage('image/a.jpg')?.path,
      localPage.resolveImage('a.jpg')?.path,
    );
    expect(localPage.resolveImage(r'..\secret.txt'), isNull);
    expect(localPage.resolveImage('/tmp/secret.txt'), isNull);
  });

  test('accepts a direct page directory', () async {
    final page = Directory('${root.path}${Platform.pathSeparator}page-id');
    await page.create(recursive: true);
    await File(
      '${page.path}${Platform.pathSeparator}snapshot.bin',
    ).writeAsBytes(const [0x0a, 0x00]);

    final document = await CloudNoteLocalDocument.open(page.path);

    expect(document.pages, hasLength(1));
    expect(document.pages.single.pageId, 'page-id');
    expect(document.pages.single.versionDirectory.path, page.path);
  });

  test('throws for a missing directory', () async {
    final missing = '${root.path}${Platform.pathSeparator}missing';
    expect(
      () => CloudNoteLocalDocument.open(missing),
      throwsA(isA<FileSystemException>()),
    );
  });
}
