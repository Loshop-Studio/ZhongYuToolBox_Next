import 'dart:convert';
import 'dart:typed_data';

import 'cloud_note_snapshot.dart';

/// Protobuf source payloads referenced by a 中育云笔记 GraphSnapshot.
///
/// `sourceFileName` identifies one of these payload types and `sourceId`
/// selects an entry in its repeated info list. The payloads are separate from
/// PageSnapshot and are commonly stored in the page ObjectBox database.
abstract class CloudNoteSource {
  const CloudNoteSource();

  static CloudNoteSource parse(String fileName, Uint8List bytes) {
    if (fileName.endsWith('_touch.bin')) {
      return CloudNoteTouchSource.parse(bytes);
    }
    if (fileName.endsWith('_matrix.bin')) {
      return CloudNoteMatrixSource.parse(bytes);
    }
    if (fileName.endsWith('_text.bin')) {
      return CloudNoteTextSource.parse(bytes);
    }
    if (fileName.endsWith('_geometry.bin')) {
      return CloudNoteGeometrySource.parse(bytes);
    }
    if (fileName.endsWith('_file.bin')) {
      return CloudNoteFileSource.parse(bytes);
    }
    if (fileName.endsWith('_audio.bin')) {
      return CloudNoteAudioSource.parse(bytes);
    }
    throw FormatException('Unknown 中育云笔记 source type: $fileName');
  }
}

class CloudNoteTouchSource extends CloudNoteSource {
  const CloudNoteTouchSource(this.touchInfo);

  final List<CloudNoteTouchInfo> touchInfo;

  factory CloudNoteTouchSource.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    final touchInfo = <CloudNoteTouchInfo>[];
    while (!reader.done) {
      final tag = reader.readTag();
      if (tag.number == 1) {
        _expectWire(tag, 2);
        touchInfo.add(CloudNoteTouchInfo.parse(reader.readBytes()));
      } else {
        reader.skip(tag.wireType);
      }
    }
    return CloudNoteTouchSource(List.unmodifiable(touchInfo));
  }
}

class CloudNoteTouchInfo {
  const CloudNoteTouchInfo({
    this.events = const <CloudNoteTouchEvent>[],
    this.paint,
  });

  final List<CloudNoteTouchEvent> events;
  final CloudNotePaint? paint;

  factory CloudNoteTouchInfo.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    final events = <CloudNoteTouchEvent>[];
    CloudNotePaint? paint;
    while (!reader.done) {
      final tag = reader.readTag();
      switch (tag.number) {
        case 1:
          _expectWire(tag, 2);
          events.add(CloudNoteTouchEvent.parse(reader.readBytes()));
        case 2:
          _expectWire(tag, 2);
          paint = CloudNotePaint.parse(reader.readBytes());
        default:
          reader.skip(tag.wireType);
      }
    }
    return CloudNoteTouchInfo(events: List.unmodifiable(events), paint: paint);
  }
}

class CloudNoteTouchEvent {
  const CloudNoteTouchEvent({
    this.eventTime = 0,
    this.action = 0,
    this.x = 0,
    this.y = 0,
    this.pointerCount = 0,
    this.pointerProperties = const <CloudNotePointerProperties>[],
    this.pointerCoords = const <CloudNotePointerCoords>[],
  });

  final int eventTime;
  final int action;
  final double x;
  final double y;
  final int pointerCount;
  final List<CloudNotePointerProperties> pointerProperties;
  final List<CloudNotePointerCoords> pointerCoords;

  factory CloudNoteTouchEvent.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    var eventTime = 0;
    var action = 0;
    var x = 0.0;
    var y = 0.0;
    var pointerCount = 0;
    final pointerProperties = <CloudNotePointerProperties>[];
    final pointerCoords = <CloudNotePointerCoords>[];
    while (!reader.done) {
      final tag = reader.readTag();
      switch (tag.number) {
        case 1:
          _expectWire(tag, 0);
          eventTime = reader.readInt64();
        case 2:
          _expectWire(tag, 0);
          action = reader.readInt32();
        case 3:
          _expectWire(tag, 5);
          x = reader.readFloat();
        case 4:
          _expectWire(tag, 5);
          y = reader.readFloat();
        case 5:
          _expectWire(tag, 0);
          pointerCount = reader.readInt32();
        case 6:
          _expectWire(tag, 2);
          pointerProperties.add(
            CloudNotePointerProperties.parse(reader.readBytes()),
          );
        case 7:
          _expectWire(tag, 2);
          pointerCoords.add(CloudNotePointerCoords.parse(reader.readBytes()));
        default:
          reader.skip(tag.wireType);
      }
    }
    return CloudNoteTouchEvent(
      eventTime: eventTime,
      action: action,
      x: x,
      y: y,
      pointerCount: pointerCount,
      pointerProperties: List.unmodifiable(pointerProperties),
      pointerCoords: List.unmodifiable(pointerCoords),
    );
  }
}

class CloudNotePointerProperties {
  const CloudNotePointerProperties({this.id = 0, this.toolType = 0});

  final int id;
  final int toolType;

  factory CloudNotePointerProperties.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    var id = 0;
    var toolType = 0;
    while (!reader.done) {
      final tag = reader.readTag();
      switch (tag.number) {
        case 1:
          _expectWire(tag, 0);
          id = reader.readInt32();
        case 2:
          _expectWire(tag, 0);
          toolType = reader.readInt32();
        default:
          reader.skip(tag.wireType);
      }
    }
    return CloudNotePointerProperties(id: id, toolType: toolType);
  }
}

class CloudNotePointerCoords {
  const CloudNotePointerCoords({this.x = 0, this.y = 0});

  final double x;
  final double y;

  factory CloudNotePointerCoords.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    var x = 0.0;
    var y = 0.0;
    while (!reader.done) {
      final tag = reader.readTag();
      switch (tag.number) {
        case 1:
          _expectWire(tag, 5);
          x = reader.readFloat();
        case 2:
          _expectWire(tag, 5);
          y = reader.readFloat();
        default:
          reader.skip(tag.wireType);
      }
    }
    return CloudNotePointerCoords(x: x, y: y);
  }
}

class CloudNoteMatrixSource extends CloudNoteSource {
  const CloudNoteMatrixSource(this.matrixInfo);

  final List<CloudNoteMatrixInfo> matrixInfo;

  factory CloudNoteMatrixSource.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    final matrixInfo = <CloudNoteMatrixInfo>[];
    while (!reader.done) {
      final tag = reader.readTag();
      if (tag.number == 1) {
        _expectWire(tag, 2);
        matrixInfo.add(CloudNoteMatrixInfo.parse(reader.readBytes()));
      } else {
        reader.skip(tag.wireType);
      }
    }
    return CloudNoteMatrixSource(List.unmodifiable(matrixInfo));
  }
}

class CloudNoteMatrixInfo {
  const CloudNoteMatrixInfo(this.matrices);

  final List<CloudNoteMatrix> matrices;

  factory CloudNoteMatrixInfo.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    final matrices = <CloudNoteMatrix>[];
    while (!reader.done) {
      final tag = reader.readTag();
      if (tag.number == 1) {
        _expectWire(tag, 2);
        matrices.add(CloudNoteMatrix.parse(reader.readBytes()));
      } else {
        reader.skip(tag.wireType);
      }
    }
    return CloudNoteMatrixInfo(List.unmodifiable(matrices));
  }
}

class CloudNoteFileSource extends CloudNoteSource {
  const CloudNoteFileSource(this.fileInfo);

  final List<CloudNoteFileInfo> fileInfo;

  factory CloudNoteFileSource.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    final fileInfo = <CloudNoteFileInfo>[];
    while (!reader.done) {
      final tag = reader.readTag();
      if (tag.number == 1) {
        _expectWire(tag, 2);
        fileInfo.add(CloudNoteFileInfo.parse(reader.readBytes()));
      } else {
        reader.skip(tag.wireType);
      }
    }
    return CloudNoteFileSource(List.unmodifiable(fileInfo));
  }
}

class CloudNoteFileInfo {
  const CloudNoteFileInfo({
    this.name = '',
    this.width = 0,
    this.height = 0,
    this.validate = '',
  });

  final String name;
  final int width;
  final int height;
  final String validate;

  factory CloudNoteFileInfo.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    var name = '';
    var width = 0;
    var height = 0;
    var validate = '';
    while (!reader.done) {
      final tag = reader.readTag();
      switch (tag.number) {
        case 1:
          _expectWire(tag, 2);
          name = reader.readString();
        case 2:
          _expectWire(tag, 0);
          width = reader.readInt32();
        case 3:
          _expectWire(tag, 0);
          height = reader.readInt32();
        case 4:
          _expectWire(tag, 2);
          validate = reader.readString();
        default:
          reader.skip(tag.wireType);
      }
    }
    return CloudNoteFileInfo(
      name: name,
      width: width,
      height: height,
      validate: validate,
    );
  }
}

class CloudNoteAudioSource extends CloudNoteSource {
  const CloudNoteAudioSource(this.audioInfo);

  final List<CloudNoteAudioInfo> audioInfo;

  factory CloudNoteAudioSource.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    final audioInfo = <CloudNoteAudioInfo>[];
    while (!reader.done) {
      final tag = reader.readTag();
      if (tag.number == 1) {
        _expectWire(tag, 2);
        audioInfo.add(CloudNoteAudioInfo.parse(reader.readBytes()));
      } else {
        reader.skip(tag.wireType);
      }
    }
    return CloudNoteAudioSource(List.unmodifiable(audioInfo));
  }
}

class CloudNoteAudioInfo {
  const CloudNoteAudioInfo({this.name = '', this.duration = 0, this.validate = ''});

  final String name;
  final int duration;
  final String validate;

  factory CloudNoteAudioInfo.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    var name = '';
    var duration = 0;
    var validate = '';
    while (!reader.done) {
      final tag = reader.readTag();
      switch (tag.number) {
        case 1:
          _expectWire(tag, 2);
          name = reader.readString();
        case 2:
          _expectWire(tag, 0);
          duration = reader.readInt64();
        case 3:
          _expectWire(tag, 2);
          validate = reader.readString();
        default:
          reader.skip(tag.wireType);
      }
    }
    return CloudNoteAudioInfo(name: name, duration: duration, validate: validate);
  }
}

class CloudNoteTextSource extends CloudNoteSource {
  const CloudNoteTextSource(this.textInfo);

  final List<CloudNoteTextInfo> textInfo;

  factory CloudNoteTextSource.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    final textInfo = <CloudNoteTextInfo>[];
    while (!reader.done) {
      final tag = reader.readTag();
      if (tag.number == 1) {
        _expectWire(tag, 2);
        textInfo.add(CloudNoteTextInfo.parse(reader.readBytes()));
      } else {
        reader.skip(tag.wireType);
      }
    }
    return CloudNoteTextSource(List.unmodifiable(textInfo));
  }
}

class CloudNoteTextInfo {
  const CloudNoteTextInfo({this.content = '', this.paint});

  final String content;
  final CloudNotePaint? paint;

  factory CloudNoteTextInfo.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    var content = '';
    CloudNotePaint? paint;
    while (!reader.done) {
      final tag = reader.readTag();
      switch (tag.number) {
        case 1:
          _expectWire(tag, 2);
          content = reader.readString();
        case 2:
          _expectWire(tag, 2);
          paint = CloudNotePaint.parse(reader.readBytes());
        default:
          reader.skip(tag.wireType);
      }
    }
    return CloudNoteTextInfo(content: content, paint: paint);
  }
}

class CloudNoteGeometrySource extends CloudNoteSource {
  const CloudNoteGeometrySource(this.geometryInfo);

  final List<CloudNoteGeometryInfo> geometryInfo;

  factory CloudNoteGeometrySource.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    final geometryInfo = <CloudNoteGeometryInfo>[];
    while (!reader.done) {
      final tag = reader.readTag();
      if (tag.number == 1) {
        _expectWire(tag, 2);
        geometryInfo.add(CloudNoteGeometryInfo.parse(reader.readBytes()));
      } else {
        reader.skip(tag.wireType);
      }
    }
    return CloudNoteGeometrySource(List.unmodifiable(geometryInfo));
  }
}

class CloudNoteGeometryInfo {
  const CloudNoteGeometryInfo({
    this.geometryType = 0,
    this.points = const <CloudNotePoint>[],
    this.paint,
  });

  final int geometryType;
  final List<CloudNotePoint> points;
  final CloudNotePaint? paint;

  factory CloudNoteGeometryInfo.parse(Uint8List bytes) {
    final reader = _SourceReader(bytes);
    var geometryType = 0;
    final points = <CloudNotePoint>[];
    CloudNotePaint? paint;
    while (!reader.done) {
      final tag = reader.readTag();
      switch (tag.number) {
        case 1:
          _expectWire(tag, 0);
          geometryType = reader.readInt32();
        case 2:
          _expectWire(tag, 2);
          points.add(CloudNotePoint.parse(reader.readBytes()));
        case 3:
          _expectWire(tag, 2);
          paint = CloudNotePaint.parse(reader.readBytes());
        default:
          reader.skip(tag.wireType);
      }
    }
    return CloudNoteGeometryInfo(
      geometryType: geometryType,
      points: List.unmodifiable(points),
      paint: paint,
    );
  }
}

class _SourceTag {
  const _SourceTag(this.number, this.wireType);

  final int number;
  final int wireType;
}

class _SourceReader {
  _SourceReader(this._bytes);

  final Uint8List _bytes;
  var _offset = 0;

  bool get done => _offset >= _bytes.length;

  _SourceTag readTag() {
    final tag = _readVarint();
    if (tag == 0) throw const FormatException('Invalid protobuf tag 0');
    return _SourceTag(tag >>> 3, tag & 7);
  }

  Uint8List readBytes() {
    final length = _readVarint();
    _ensureRemaining(length);
    final end = _offset + length;
    final value = Uint8List.sublistView(_bytes, _offset, end);
    _offset = end;
    return value;
  }

  String readString() => const Utf8Decoder().convert(readBytes());

  int readInt32() => _readVarint().toSigned(32);

  int readInt64() => _readVarint().toSigned(64);

  double readFloat() {
    _ensureRemaining(4);
    final value = _bytes.buffer
        .asByteData(_bytes.offsetInBytes + _offset, 4)
        .getFloat32(0, Endian.little);
    _offset += 4;
    return value;
  }

  void skip(int wireType) {
    switch (wireType) {
      case 0:
        _readVarint();
      case 1:
        _ensureRemaining(8);
        _offset += 8;
      case 2:
        final length = _readVarint();
        _ensureRemaining(length);
        _offset += length;
      case 3:
        while (!done) {
          final tag = readTag();
          if (tag.wireType == 4) return;
          skip(tag.wireType);
        }
        throw const FormatException('Unterminated protobuf group');
      case 4:
        return;
      case 5:
        _ensureRemaining(4);
        _offset += 4;
      default:
        throw FormatException('Unsupported protobuf wire type $wireType');
    }
  }

  int _readVarint() {
    var value = 0;
    var shift = 0;
    while (shift < 64) {
      if (done) throw const FormatException('Truncated protobuf varint');
      final byte = _bytes[_offset++];
      value |= (byte & 0x7f) << shift;
      if ((byte & 0x80) == 0) return value;
      shift += 7;
    }
    throw const FormatException('Malformed protobuf varint');
  }

  void _ensureRemaining(int count) {
    if (count < 0 || count > _bytes.length - _offset) {
      throw const FormatException('Truncated protobuf field');
    }
  }
}

void _expectWire(_SourceTag tag, int wireType) {
  if (tag.wireType != wireType) {
    throw FormatException(
      'Unexpected protobuf wire type ${tag.wireType} for field ${tag.number}',
    );
  }
}
