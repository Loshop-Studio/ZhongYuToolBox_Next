import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../data/api/exam_api.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/content_html_view.dart';

/// 单题 HTML（含解析）
class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key, required this.qstId, required this.index});

  final int qstId;
  final int index;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  bool _loading = true;
  String? _error;
  String _html = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final html = await ExamApi.getQuestionHtml(widget.qstId);
      if (!mounted) return;
      setState(() {
        _html = html;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text('第 ${widget.index} 题'),
      ),
      body: _loading
          ? const LoadingView(text: '正在加载题目…')
          : (_error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : ContentHtmlView(html: _html)),
    );
  }
}
