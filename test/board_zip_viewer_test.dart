import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zy_board_renderer/board_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders a board ZIP without editor or page controls', (
    tester,
  ) async {
    final asset = await rootBundle.load('assets/blackbroad.zip');
    final bytes = Uint8List.sublistView(asset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 460,
            child: BoardZipViewer(
              url: 'https://example.test/answer.zip',
              loadBytes: (_) async => bytes,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('画板加载失败'), findsNothing);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(
      tester
          .widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .scaleEnabled,
      isTrue,
    );
    expect(find.textContaining('第'), findsNothing);
    expect(find.textContaining('导出'), findsNothing);
  });

  testWidgets('opens and closes the board in fullscreen', (tester) async {
    final asset = await rootBundle.load('assets/blackbroad.zip');
    final bytes = Uint8List.sublistView(asset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 460,
            child: BoardZipViewer(
              url: 'https://example.test/answer.zip',
              loadBytes: (_) async => bytes,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('全屏'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('退出全屏'), findsOneWidget);

    await tester.tap(find.byTooltip('退出全屏'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('全屏'), findsOneWidget);
  });

  testWidgets(
    'retry restarts ZIP loading without returning a Future to setState',
    (tester) async {
      final asset = await rootBundle.load('assets/blackbroad.zip');
      final bytes = Uint8List.sublistView(asset);
      var attempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 460,
              child: BoardZipViewer(
                url: 'https://example.test/answer.zip',
                loadBytes: (_) async {
                  attempts++;
                  return attempts == 1 ? Uint8List.fromList([1, 2, 3]) : bytes;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('画板加载失败'), findsOneWidget);
      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('画板加载失败'), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    },
  );
}
