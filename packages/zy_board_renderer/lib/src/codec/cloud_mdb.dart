// Read the main B-tree of the little-endian LMDB images produced by Cloud Note.
// ObjectBox catalog and object keys follow the same layout as tools/objectbox_store.py.
import 'dart:convert';
import 'dart:typed_data';

/// A closed ObjectBox snapshot. Rows and relations refer to the same selected
/// transaction. Edits are made only in a private copy of its scalar payloads.
class CloudMdbStore {
  CloudMdbStore._(this.bytes);
  final Uint8List bytes;
  final counts = <String, int>{};
  final rows = <String, Map<int, MdbRow>>{};
  final _relations = <(String, String), int>{};
  final _targets = <(int, int), List<int>>{};

  final _targetCounts = <(int, int), int>{};
  bool shared(String owner, MdbRow row) =>
      (_targetCounts[(_relations[(owner, row.type)], row.id)] ?? 0) > 1;

  List<MdbRow> children(MdbRow row, String type) {
    final relation = _relations[(row.type, type)];
    final ids = _targets[(relation, row.id)] ?? const <int>[];
    return [
      for (final id in ids)
        rows[type]?[id] ?? (throw FormatException('MDB 关系引用缺失的 $type 对象 $id')),
    ];
  }

  static CloudMdbStore read(Uint8List input) {
    final store = CloudMdbStore._(Uint8List.fromList(input));
    final types = <int, ({String name, Map<String, int> slots})>{};
    final relations = <(int, int, int)>[];
    try {
      for (final (high, low, target, value) in _Lmdb(store.bytes).entries()) {
        if (target != null) {
          final to = ((high & 0x03ffffff) >>> 2, target);
          store._targetCounts[to] = (store._targetCounts[to] ?? 0) + 1;
          store._targets
              .putIfAbsent(((high & 0x03ffffff) >>> 2, low), () => [])
              .add(target);
        } else if (high == 0 && low != 0) {
          final table = _Table(value);
          final name = table.string(3);
          if (name == null || table.number(1) != low)
            throw const FormatException('无法识别 ObjectBox 实体目录');
          final slots = <String, int>{
            for (final prop in table.tables(4))
              prop.string(6)!: prop.number(1) - 1,
          };
          for (final rel in table.tables(10)) {
            relations.add((low, rel.number(3), rel.number(0)));
          }
          types[low] = (name: name, slots: slots);
          store.counts[name] = 0;
          store.rows[name] = {};
        } else if ((high >>> 26) == 6) {
          final entity = types[(high & 0x03ffffff) >>> 2];
          if (entity == null) throw const FormatException('缺少 ObjectBox 实体定义');
          final id = (high & 3) * 0x100000000 + low;
          store.counts[entity.name] = store.counts[entity.name]! + 1;
          store.rows[entity.name]![id] = MdbRow._(
            entity.name,
            id,
            _Table(value),
            entity.slots,
          );
        }
      }
      for (final (owner, target, id) in relations) {
        store._relations[(types[owner]!.name, types[target]!.name)] = id;
      }
      if (!store.rows.containsKey('PageEntity') ||
          !store.rows.containsKey('BlackBoardEntity')) {
        throw const FormatException('库中没有云笔记画板的实体目录');
      }
      return store;
    } on RangeError {
      throw const FormatException('MDB 中的页或记录越过了文件边界');
    }
  }
}

class MdbRow {
  MdbRow._(this.type, this.id, this._table, this._slots);
  final String type;
  final int id;
  final _Table _table;
  final Map<String, int> _slots;
  int? _field(String name) {
    final slot = _slots[name];
    return slot == null ? null : _table.field(slot);
  }

  String? string(String name) =>
      _slots.containsKey(name) ? _table.string(_slots[name]!) : null;
  int int32(String name) {
    final pos = _field(name);
    return pos == null ? 0 : _table.bytes.getInt32(pos, Endian.little);
  }

  int long(String name) {
    final pos = _field(name);
    return pos == null
        ? 0
        : _table.bytes.getInt32(pos + 4, Endian.little) * 0x100000000 +
              _table.bytes.getUint32(pos, Endian.little);
  }

  double real(String name) {
    final pos = _field(name);
    return pos == null ? 0 : _table.bytes.getFloat32(pos, Endian.little);
  }

  bool flag(String name) {
    final pos = _field(name);
    return pos != null && _table.bytes.getUint8(pos) != 0;
  }

  Uint8List blob(String name) {
    final pos = _field(name);
    if (pos == null) return Uint8List(0);
    final p = _table.pointer(pos);
    return Uint8List.sublistView(
      _table.bytes,
      p + 4,
      p + 4 + _table.bytes.getUint32(p, Endian.little),
    );
  }

  // The editor only changes unindexed paint and coordinate fields. No object
  // IDs, index keys, vector sizes, page boundaries or relation keys move.
  int scalarOffset(String name) {
    final pos = _field(name);
    if (pos == null) throw FormatException('$type.$name 在此记录中没有可写字段');
    return _table.bytes.offsetInBytes + pos;
  }
}

// FlatBuffers tables use offsets relative to the field for strings and vectors.
class _Table {
  _Table(ByteData bytes) : this.at(bytes, bytes.getUint32(0, Endian.little));
  _Table.at(this.bytes, this.table);
  final ByteData bytes;
  final int table;

  int? field(int slot) {
    final vt = table - bytes.getInt32(table, Endian.little);
    final offset = 4 + 2 * slot;
    if (offset >= bytes.getUint16(vt, Endian.little)) return null;
    final n = bytes.getUint16(vt + offset, Endian.little);
    return n == 0 ? null : table + n;
  }

  int pointer(int pos) => pos + bytes.getUint32(pos, Endian.little);
  int number(int slot) =>
      field(slot) == null ? 0 : bytes.getUint32(field(slot)!, Endian.little);
  int number16(int slot) =>
      field(slot) == null ? 0 : bytes.getUint16(field(slot)!, Endian.little);

  String? string(int slot) {
    final pos = field(slot);
    if (pos == null) return null;
    final start = pointer(pos);
    final length = bytes.getUint32(start, Endian.little);
    return utf8.decode(
      Uint8List.sublistView(bytes, start + 4, start + 4 + length),
    );
  }

  Iterable<_Table> tables(int slot) sync* {
    final pos = field(slot);
    if (pos == null) return;
    final start = pointer(pos);
    final count = bytes.getUint32(start, Endian.little);
    for (var i = 0; i < count; i++) {
      yield _Table.at(bytes, pointer(start + 4 + i * 4));
    }
  }
}

class _Lmdb {
  _Lmdb(Uint8List bytes) : data = ByteData.sublistView(bytes);
  final ByteData data;
  int u16(int i) => data.getUint16(i, Endian.little);
  int u32(int i) => data.getUint32(i, Endian.little);

  bool isMeta(int pos) =>
      u16(pos + 10) == 8 && u32(pos + 16) == 0xbeefc0de && u32(pos + 20) == 1;

  // Split eight-byte keys into two words to keep them exact in JavaScript.
  Iterable<(int, int, int?, ByteData)> entries() sync* {
    if (data.lengthInBytes < 152 || !isMeta(0)) {
      throw const FormatException('无法识别云笔记样本所用的 LMDB 文件头');
    }
    final size = u32(40);
    if (size < 512 ||
        size > 65536 ||
        (size & (size - 1)) != 0 ||
        data.lengthInBytes < size * 2 ||
        !isMeta(size) ||
        u32(size + 40) != size) {
      throw const FormatException('MDB 元数据页或页尺寸无效');
    }
    // Transaction IDs select the latest committed root. Compare high words first.
    final a = u32(148), b = u32(size + 148);
    final meta = b > a || (b == a && u32(size + 144) > u32(144)) ? size : 0;
    if (u16(meta + 94) == 0) return; // main DB depth
    final pending = [u32(meta + 128)];
    final seen = <int>{};
    final pageCount = data.lengthInBytes ~/ size;
    while (pending.isNotEmpty) {
      final page = pending.removeLast();
      if (page < 2 || page >= pageCount || !seen.add(page)) {
        throw const FormatException('MDB 页面索引无效');
      }
      final base = page * size;
      final flags = u16(base + 10);
      final lower = u16(base + 12), upper = u16(base + 14);
      if (u32(base) != page ||
          (flags != 1 && flags != 2) ||
          lower < 16 ||
          lower.isOdd ||
          lower > upper ||
          upper > size) {
        throw const FormatException('无法识别 MDB B 树页');
      }
      final children = <int>[];
      for (var cursor = 16; cursor < lower; cursor += 2) {
        final offset = u16(base + cursor);
        final node = base + offset;
        if (offset < upper || offset + 8 > size)
          throw const FormatException('MDB 节点越界');
        if (flags == 1) {
          children.add(u32(node));
          continue;
        }
        final keySize = u16(node + 6);
        if (keySize == 12 && u32(node) == 0 && u16(node + 4) == 0) {
          if (offset + 20 > size) throw const FormatException('MDB 关系键越界');
          final tag = data.getUint32(node + 8);
          if ((tag >>> 26) == 2 && (tag & 3) == 0) {
            yield (
              tag,
              data.getUint32(node + 12),
              data.getUint32(node + 16),
              ByteData.sublistView(data, node, node),
            );
          }
          continue;
        }
        if (keySize != 8) continue;
        final key = node + 8;
        if (key + 8 > base + size) throw const FormatException('MDB 键越界');
        final high = data.getUint32(key), low = data.getUint32(key + 4);
        if (!(high == 0 && low != 0) && (high >>> 26) != 6) continue;
        var start = key + 8;
        var limit = base + size;
        final length = u32(node);
        final nodeFlags = u16(node + 4);
        if (nodeFlags == 1) {
          if (start + 8 > limit) throw const FormatException('MDB 溢出页指针越界');
          final overflow = u32(start) * size;
          if (u16(overflow + 10) != 4) throw const FormatException('MDB 溢出页无效');
          limit = overflow + u32(overflow + 12) * size;
          start = overflow + 16;
        } else if (nodeFlags != 0) {
          throw const FormatException('无法识别 ObjectBox 记录的节点类型');
        }
        if (start + length > limit) throw const FormatException('MDB 记录越界');
        yield (
          high,
          low,
          null,
          ByteData.sublistView(data, start, start + length),
        );
      }
      pending.addAll(children.reversed);
    }
  }
}
