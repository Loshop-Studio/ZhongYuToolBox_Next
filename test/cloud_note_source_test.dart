import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/features/resources/cloud_note_source.dart';

void main() {
  test('dispatches and decodes text source with paint', () {
    final paint = _message(<int>[..._floatField(1, 3.5), ..._varintField(2, 0xff336699)]);
    final textInfo = _message(<int>[..._bytesField(1, 'hello'.codeUnits), ..._messageField(2, paint)]);
    final source = CloudNoteSource.parse(
      'sample_text.bin',
      Uint8List.fromList(_messageField(1, textInfo)),
    ) as CloudNoteTextSource;

    expect(source.textInfo.single.content, 'hello');
    expect(source.textInfo.single.paint?.width, 3.5);
    expect(source.textInfo.single.paint?.colorArgb, 0xff336699);
  });

  test('decodes touch, pointer and geometry source lists', () {
    final pointerProperties = _message(<int>[..._varintField(1, 2), ..._varintField(2, 1)]);
    final pointerCoords = _message(<int>[..._floatField(1, 12), ..._floatField(2, 24)]);
    final event = _message(<int>[
      ..._varintField(1, 1234),
      ..._varintField(2, 2),
      ..._floatField(3, 12),
      ..._floatField(4, 24),
      ..._varintField(5, 1),
      ..._messageField(6, pointerProperties),
      ..._messageField(7, pointerCoords),
    ]);
    final touchInfo = _message(<int>[..._messageField(1, event)]);
    final touch = CloudNoteSource.parse(
      'sample_touch.bin',
      Uint8List.fromList(_messageField(1, touchInfo)),
    ) as CloudNoteTouchSource;

    expect(touch.touchInfo.single.events.single.eventTime, 1234);
    expect(touch.touchInfo.single.events.single.action, 2);
    expect(touch.touchInfo.single.events.single.pointerProperties.single.id, 2);
    expect(touch.touchInfo.single.events.single.pointerCoords.single.y, 24);

    final point = _message(<int>[..._floatField(1, 1.5), ..._floatField(2, 2.5)]);
    final geometryInfo = _message(<int>[
      ..._varintField(1, 4),
      ..._messageField(2, point),
    ]);
    final geometry = CloudNoteSource.parse(
      'sample_geometry.bin',
      Uint8List.fromList(_messageField(1, geometryInfo)),
    ) as CloudNoteGeometrySource;

    expect(geometry.geometryInfo.single.geometryType, 4);
    expect(geometry.geometryInfo.single.points.single.x, 1.5);
  });

  test('decodes file source metadata and rejects unknown source types', () {
    final info = _message(<int>[
      ..._bytesField(1, 'asset.png'.codeUnits),
      ..._varintField(2, 640),
      ..._varintField(3, 480),
      ..._bytesField(4, 'checksum'.codeUnits),
    ]);
    final source = CloudNoteSource.parse(
      'sample_file.bin',
      Uint8List.fromList(_messageField(1, info)),
    ) as CloudNoteFileSource;

    expect(source.fileInfo.single.name, 'asset.png');
    expect(source.fileInfo.single.width, 640);
    expect(source.fileInfo.single.height, 480);
    expect(source.fileInfo.single.validate, 'checksum');
    expect(
      () => CloudNoteSource.parse('sample_other.bin', Uint8List(0)),
      throwsFormatException,
    );
  });
}

List<int> _message(List<int> fields) => fields;

List<int> _messageField(int field, List<int> value) => <int>[
      ..._varint(field << 3 | 2),
      ..._varint(value.length),
      ...value,
    ];

List<int> _bytesField(int field, List<int> value) => _messageField(field, value);

List<int> _varintField(int field, int value) => <int>[
      ..._varint(field << 3),
      ..._varint(value),
    ];

List<int> _floatField(int field, double value) {
  final bytes = ByteData(4)..setFloat32(0, value, Endian.little);
  return <int>[..._varint(field << 3 | 5), ...bytes.buffer.asUint8List()];
}

List<int> _varint(int value) {
  final bytes = <int>[];
  var remaining = value;
  do {
    var byte = remaining & 0x7f;
    remaining >>= 7;
    if (remaining != 0) byte |= 0x80;
    bytes.add(byte);
  } while (remaining != 0);
  return bytes;
}
