import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/features/resources/cloud_note_snapshot.dart';

void main() {
  test('decodes page, graph, matrix, paint and repeated points', () {
    final point = _message(<int>[
      ..._floatField(1, 12.5),
      ..._floatField(2, -3.25),
    ]);
    final paint = _message(<int>[
      ..._floatField(1, 4),
      ..._varintField(2, 0xff112233),
      ..._floatField(6, 18),
    ]);
    final child = _message(<int>[
      ..._bytesField(1, <int>[0x63, 0x68, 0x69, 0x6c, 0x64]),
      ..._varintField(2, 5),
      ..._bytesField(10, <int>[0x68, 0x69]),
    ]);
    final graph = _message(<int>[
      ..._bytesField(1, <int>[0x72, 0x6f, 0x6f, 0x74]),
      ..._varintField(2, 3),
      ..._messageField(5, child),
      ..._messageField(9, paint),
      ..._messageField(11, point),
      ..._bytesField(10, <int>[0xc3, 0xa9]),
      // Unknown fixed32 field must not disturb the following content.
      0x9d, 0x06, 0x00, 0x00, 0x80, 0x3f,
    ]);
    final camera = _message(<int>[
      ..._floatField(2, 0.5),
      ..._floatField(6, 0.5),
    ]);
    final snapshot = CloudNoteSnapshot.parse(
      Uint8List.fromList(<int>[
        ..._messageField(1, camera),
        ..._messageField(2, graph),
      ]),
    );

    expect(snapshot.cameraMatrix?.scaleX, 0.5);
    expect(snapshot.cameraMatrix?.scaleY, 0.5);
    expect(snapshot.graphSnapshot?.id, 'root');
    expect(snapshot.graphSnapshot?.graphEnum, 3);
    expect(snapshot.graphSnapshot?.content, 'é');
    expect(snapshot.graphSnapshot?.paint?.width, 4);
    expect(snapshot.graphSnapshot?.paint?.colorArgb, 0xff112233);
    expect(snapshot.graphSnapshot?.pointList.single.x, 12.5);
    expect(snapshot.graphSnapshot?.childGraph.single.graphEnum, 5);
    expect(snapshot.graphSnapshot?.childGraph.single.content, 'hi');
  });

  test('retains malformed text bytes and skips unknown fields', () {
    final graph = _message(<int>[
      ..._bytesField(10, <int>[0xff, 0xfe]),
      ..._varintField(99, 123),
    ]);
    final decoded = CloudNoteSnapshot.parse(
      Uint8List.fromList(_messageField(2, graph)),
    ).graphSnapshot!;

    expect(decoded.content, isNull);
    expect(decoded.contentBytes, <int>[0xff, 0xfe]);
  });
}

List<int> _message(List<int> fields) => fields;

List<int> _messageField(int field, List<int> value) => <int>[
  ..._varint(field << 3 | 2),
  ..._varint(value.length),
  ...value,
];

List<int> _bytesField(int field, List<int> value) =>
    _messageField(field, value);

List<int> _varintField(int field, int value) => <int>[
  ..._varint(field << 3),
  ..._varint(value),
];

List<int> _floatField(int field, double value) {
  final data = ByteData(4)..setFloat32(0, value, Endian.little);
  return <int>[..._varint(field << 3 | 5), ...data.buffer.asUint8List()];
}

List<int> _varint(int value) {
  final result = <int>[];
  var remaining = value;
  do {
    var byte = remaining & 0x7f;
    remaining >>= 7;
    if (remaining != 0) byte |= 0x80;
    result.add(byte);
  } while (remaining != 0);
  return result;
}
