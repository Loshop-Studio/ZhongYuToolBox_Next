import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart';

import '../../core/network/api_exception.dart';
import '../../shared/widgets/common.dart';
import 'attachment_opener.dart';

/// 原生视频播放（media_kit / libmpv，覆盖 Windows、Android、macOS、Linux）
///
/// 以前是往 WebView 里塞 `<video>` 标签，桌面端格式支持差也没有下载，
/// 这里换成原生播放器，并统一带上「下载」入口。
class NativeVideoView extends StatefulWidget {
  const NativeVideoView({super.key, required this.url, this.title = ''});

  final String url;
  final String title;

  @override
  State<NativeVideoView> createState() => _NativeVideoViewState();
}

class _NativeVideoViewState extends State<NativeVideoView> {
  late final Player _player;
  late final VideoController _videoController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _open();
  }

  Future<void> _open() async {
    try {
      await _player.open(Media(widget.url), play: true);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = errorText(e);
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _open();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _retry);
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Video(
            controller: _videoController,
            // 桌面端带完整进度条 / 音量 / 倍速 / 全屏
            controls: MaterialDesktopVideoControls,
            fit: BoxFit.contain,
          ),
        ),
        if (_loading)
          const DecoratedBox(
            decoration: BoxDecoration(color: Colors.black),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

/// 独立的视频播放页（附件 / 优客畅学 video_play 共用）
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.url, this.name = ''});

  final String url;
  final String name;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final path = await downloadAttachment(widget.url, widget.name);
      if (!mounted) return;
      showToast(context, path == null ? '已取消保存' : '已保存：$path');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          widget.name.isEmpty ? '视频' : widget.name,
          overflow: TextOverflow.ellipsis,
        ),
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
      backgroundColor: Colors.black,
      body: NativeVideoView(url: widget.url, title: widget.name),
    );
  }
}
