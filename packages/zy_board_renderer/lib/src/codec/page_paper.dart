part of 'board_file.dart';

enum PaperRuling { plain, horizontal, grid }

extension BlackboardPaperEditing on BlackboardPage {
  PaperRuling get ruling => paperLines.lineColor == 0
      ? PaperRuling.plain
      : paperLines.lineType == line.BackgroundLineTypeEnum.STAGGERED
      ? PaperRuling.grid
      : PaperRuling.horizontal;

  bool setPaper({
    required int color,
    required PaperRuling ruling,
    required int lineColor,
    required double spacing,
  }) {
    if (!supportsArtworkEditing) throw StateError('当前页面没有 V6 页头');
    if (ruling != PaperRuling.plain &&
        (!spacing.isFinite ||
            spacing <= 0 ||
            spacing > 3.4e38 ||
            lineColor.toSigned(32) == 0)) {
      throw const FormatException('线距须为正数，并且线色不能为 00000000');
    }
    final next = header.BackgroundLineConfig.fromBuffer(
      paperLines.writeToBuffer(),
    );
    if (ruling == PaperRuling.plain) {
      next.lineColor = 0;
    } else {
      next
        ..lineColor = lineColor.toSigned(32)
        ..lineType = ruling == PaperRuling.grid
            ? line.BackgroundLineTypeEnum.STAGGERED
            : line.BackgroundLineTypeEnum.HORIZONTAL
        ..lineSpace = spacing;
    }
    final argb = color.toSigned(32);
    if (background.toSigned(32) == argb &&
        this.ruling == ruling &&
        (ruling == PaperRuling.plain ||
            (next.lineColor == paperLines.lineColor &&
                next.lineSpace == paperLines.lineSpace)))
      return false;
    final meta = _pageHeader();
    final routerPath = '${dir}router.bin';
    final refs = bundle.has(routerPath)
        ? router.RouterRecord.fromBuffer(bundle.read(routerPath))
        : router.RouterRecord();
    // PageControl.setBackgroundColorWithLineConfig writes the chosen color in
    // both color fields and keeps the actual previous line configuration.
    final config = cmd.CommandSource_CommandInfo_Config(
      originBackground: argb,
      lastBackground: argb,
      originBackgroundLineConfig: paperLines,
      lastBackgroundLineConfig: next,
    );
    _writeRecord(
      _nextName('command'),
      cmd.CommandSource(
        commandInfo: [
          cmd.CommandSource_CommandInfo(
            commandEnum: ce.CommandEnum.ACTION_CONFIG,
            isPlay: false,
            data: config.writeToBuffer(),
          ),
        ],
      ),
      refs.commandRecord,
    );
    // SourceSave persists color, spacing and type in the header; the command
    // above also includes the width. Only the current page gets a full header.
    meta
      ..lastBackgroundColor = argb
      ..lastBackgroundLineConfig = (header.BackgroundLineConfig.fromBuffer(
        next.writeToBuffer(),
      )..clearLineWidth());
    bundle.changed[routerPath] = refs.writeToBuffer();
    bundle.changed['${dir}header.bin'] = meta.writeToBuffer();
    bundle.pendingPreviews.add(name);
    refresh();
    return true;
  }
}
