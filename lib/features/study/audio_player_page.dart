import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../../core/network/api_exception.dart';
import '../../shared/widgets/common.dart';
import 'attachment_opener.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key, required this.url, this.name = ''});

  final String url;
  final String name;

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late final Player _player;
  bool _saving = false;
  bool _started = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _start();
  }

  Future<void> _start() async {
    try {
      await _player.open(Media(widget.url), play: false);
      if (mounted) setState(() => _started = true);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final path = await downloadAttachment(widget.url, widget.name);
      if (mounted) showToast(context, path == null ? '已取消保存' : '已保存：$path');
    } catch (e) {
      if (mounted) showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _time(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:${(minutes % 60).toString().padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.isEmpty ? '音频' : widget.name,
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: '下载',
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _error != null
                ? ErrorView(message: _error!, onRetry: () {
                    setState(() => _error = null);
                    _start();
                  })
                : StreamBuilder<Duration>(
                    stream: _player.stream.duration,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: _player.stream.position,
                        builder: (context, positionSnapshot) {
                          final position = positionSnapshot.data ?? Duration.zero;
                          final max = duration.inMilliseconds.toDouble();
                          final value = position.inMilliseconds
                              .clamp(0, duration.inMilliseconds)
                              .toDouble();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 156,
                                height: 156,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.graphic_eq,
                                    size: 76,
                                    color: theme.colorScheme.onSecondaryContainer),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                widget.name.isEmpty ? '正在播放音频' : widget.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 20),
                              Slider(
                                min: 0,
                                max: max > 0 ? max : 1,
                                value: max > 0 ? value : 0,
                                onChanged: max <= 0
                                    ? null
                                    : (next) => _player.seek(
                                          Duration(milliseconds: next.round()),
                                        ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_time(position),
                                      style: theme.textTheme.bodySmall),
                                  Text(_time(duration),
                                      style: theme.textTheme.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: '后退 15 秒',
                                    icon: const Icon(Icons.replay_10),
                                    iconSize: 32,
                                    onPressed: () => _player.seek(Duration(
                                      milliseconds: (position.inMilliseconds - 15000)
                                          .clamp(0, duration.inMilliseconds),
                                    )),
                                  ),
                                  const SizedBox(width: 20),
                                  StreamBuilder<bool>(
                                    stream: _player.stream.playing,
                                    builder: (context, snapshot) {
                                      final playing = snapshot.data ?? false;
                                      return IconButton.filled(
                                        tooltip: playing ? '暂停' : '播放',
                                        icon: Icon(playing
                                            ? Icons.pause
                                            : Icons.play_arrow),
                                        iconSize: 38,
                                        onPressed: _started
                                            ? () => _player.playOrPause()
                                            : null,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  IconButton(
                                    tooltip: '前进 15 秒',
                                    icon: const Icon(Icons.forward_10),
                                    iconSize: 32,
                                    onPressed: () => _player.seek(Duration(
                                      milliseconds: (position.inMilliseconds + 15000)
                                          .clamp(0, duration.inMilliseconds),
                                    )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              StreamBuilder<double>(
                                stream: _player.stream.volume,
                                builder: (context, snapshot) => Row(
                                  children: [
                                    const Icon(Icons.volume_down_outlined),
                                    Expanded(
                                      child: Slider(
                                        min: 0,
                                        max: 100,
                                        value: (snapshot.data ?? 100)
                                            .clamp(0, 100),
                                        onChanged: (volume) =>
                                            _player.setVolume(volume),
                                      ),
                                    ),
                                    const Icon(Icons.volume_up_outlined),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
