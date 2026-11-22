part of 'board_file.dart';

class BlackboardAudioTrack extends RecordingTrack {
  int _duration = 0;
  int _commandEnd = 0;
  String? issue;
  final _reachableAt = <int>[];
  final _latestEndBefore = <int>[];

  @override
  int get durationMs => _duration;

  // Android processes commands in order. A later eligible audio start replaces
  // the current player when a negative delay makes clips overlap.
  @override
  RecordingClip? clipAt(int ms) {
    var lo = 0, hi = clips.length;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (_reachableAt[mid] <= ms) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    for (int i = lo - 1; i >= 0; i--) {
      if (ms < clips[i].endMs) return clips[i];
      if (i == 0 || _latestEndBefore[i] <= ms) break;
    }
    return null;
  }
}

extension BlackboardAudio on BlackboardPage {
  BlackboardAudioTrack get pageAudio => _audioTrack ??= _readAudio();
  String get _audioDir => '${_dir(_noteHeader)}res/audio/';
  Uint8List? audioBytes(String name) {
    final path = _audioDir + name;
    return name.isNotEmpty && bundle.has(path) ? bundle.read(path) : null;
  }

  header.Header _pageHeader() {
    final path = '${dir}header.bin';
    final data = bundle.has(path) ? bundle.read(path) : Uint8List(0);
    final root = bundle.has(_noteHeader)
        ? header.Header.fromBuffer(bundle.read(_noteHeader))
        : header.Header(version: 6);
    final shortDuration = BoardArchive._shortHeaderDuration(data, root.version);
    if (shortDuration == null) return header.Header.fromBuffer(data);
    root.duration = shortDuration;
    return root;
  }

  BlackboardAudioTrack _readAudio() {
    final result = BlackboardAudioTrack();
    try {
      final pageHeader = _pageHeader();
      result._duration = math.max(0, pageHeader.duration.toInt());
      final path = '${dir}router.bin';
      if (!bundle.has(path)) return result;
      final refs = router.RouterRecord.fromBuffer(bundle.read(path));
      int nextReachable = 0, latestEnd = 0;
      for (final ref in refs.audioRecord) {
        final shard = cmd.CommandSource.fromBuffer(
          bundle.read(dir + ref.fileName),
        );
        for (final entry in shard.commandInfo) {
          final start = result._commandEnd + entry.delayTime.toInt();
          // A seek stops at the first command whose delay has not elapsed.
          nextReachable = math.max(nextReachable, start);
          final duration = entry.duration.toInt();
          result._commandEnd = start + duration;
          if (entry.commandEnum == ce.CommandEnum.ACTION_AUDIO_START &&
              duration > 0) {
            final audio = cmd.CommandSource_CommandInfo_AudioStart.fromBuffer(
              entry.data,
            );
            result._reachableAt.add(nextReachable);
            result._latestEndBefore.add(latestEnd);
            latestEnd = math.max(latestEnd, result._commandEnd);
            result.clips.add(
              RecordingClip(audio.fileName, start)..endMs = start + duration,
            );
          }
        }
      }
      if (!bundle.has('${dir}header.bin')) {
        result._duration = math.max(0, result._commandEnd);
      }
    } on Exception catch (e) {
      result.issue = '录音索引读取失败 · $e';
    }
    return result;
  }

  String appendAudio(
    String name,
    Uint8List bytes,
    int durationMs, {
    int gapMs = 0,
  }) {
    final track = pageAudio;
    if (!supportsArtworkEditing ||
        track.issue != null ||
        bytes.isEmpty ||
        durationMs <= 0 ||
        gapMs < 0) {
      throw const FormatException('录音内容、时长或页面索引无效');
    }
    final media = bundle._uniqueResourceName(_audioDir, name);
    final path = '${dir}router.bin';
    final refs = bundle.has(path)
        ? router.RouterRecord.fromBuffer(bundle.read(path))
        : router.RouterRecord();
    final tail = refs.audioRecord.lastOrNull;
    var commands = tail == null
        ? cmd.CommandSource()
        : cmd.CommandSource.fromBuffer(bundle.read(dir + tail.fileName));
    var shard = tail?.fileName;
    // The original recorder fills one audio shard before opening the next.
    if (shard == null || commands.commandInfo.length >= 100) {
      commands = cmd.CommandSource();
      shard = _nextName('audio');
    }
    final start = math.max(track.durationMs, track._commandEnd) + gapMs;
    final duration = Int64(durationMs);
    final meta = _pageHeader()..duration = Int64(start + durationMs);
    commands.commandInfo.add(
      cmd.CommandSource_CommandInfo(
        delayTime: Int64(start - track._commandEnd),
        duration: duration,
        isPlay: true,
        commandEnum: ce.CommandEnum.ACTION_AUDIO_START,
        data: cmd.CommandSource_CommandInfo_AudioStart(
          fileName: media,
          duration: duration,
        ).writeToBuffer(),
      ),
    );
    _writeRecord(shard, commands, refs.audioRecord);
    bundle.changed[path] = refs.writeToBuffer();
    bundle.changed['${dir}header.bin'] = meta.writeToBuffer();
    bundle.changed[_audioDir + media] = bytes;
    _audioTrack = null;
    _replay = null;
    return media;
  }
}
