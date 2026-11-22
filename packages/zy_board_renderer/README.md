# Read-only board renderer

This package vendors the board codec from `Loshop-Studio/zhongyu-board-codec`
(`board_editor`, commit `99e54ca51069979650ed2a038eccec25d586afb0`). The Web
editor entry point and its edit controls are not included. The codec is retained
to decode the original ZIP formats; only `BoardZipViewer` is exposed to the app.

The archive dependency is kept on 3.x to remain compatible with this app's PDF
dependency. The codec's ZIP writing helpers are adapted to that API; viewing
does not write to the input archive.
