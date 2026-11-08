import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;

/// Captures the primary Windows desktop and stores it as a JPEG image.
class ScreenCapture {
  const ScreenCapture();

  Future<File> capture(String directory) async {
    if (!Platform.isWindows) {
      throw UnsupportedError(
        'Desktop screen capture is currently supported on Windows only.',
      );
    }
    return Isolate.run(() => _captureWindows(directory));
  }

  static Future<File> _captureWindows(String directory) async {
    final api = _WindowsCaptureApi();
    final width = api.getSystemMetrics(0);
    final height = api.getSystemMetrics(1);
    if (width <= 0 || height <= 0) {
      throw StateError('Could not determine the primary screen size.');
    }

    final screenDc = api.getDc(nullptr);
    if (screenDc == nullptr) {
      throw StateError('Could not open the desktop display.');
    }
    final memoryDc = api.createCompatibleDc(screenDc);
    final bitmap = api.createCompatibleBitmap(screenDc, width, height);
    if (memoryDc == nullptr || bitmap == nullptr) {
      if (bitmap != nullptr) {
        api.deleteObject(bitmap);
      }
      if (memoryDc != nullptr) {
        api.deleteDc(memoryDc);
      }
      api.releaseDc(nullptr, screenDc);
      throw StateError('Could not allocate a screen capture bitmap.');
    }

    final previous = api.selectObject(memoryDc, bitmap);
    final captured = api.bitBlt(
      memoryDc,
      0,
      0,
      width,
      height,
      screenDc,
      0,
      0,
      0x00CC0020,
    );
    final info = api.allocate(40);
    final pixels = api.allocate(width * height * 4);
    try {
      if (captured == 0) {
        throw StateError('Windows could not copy the desktop image.');
      }
      final header = info.cast<Int32>();
      header[0] = 40;
      header[1] = width;
      header[2] = -height;
      header[3] = 1 | (32 << 16);
      header[4] = 0;
      header[5] = width * height * 4;
      api.selectObject(memoryDc, previous);
      final rows = api.getDibits(memoryDc, bitmap, 0, height, pixels, info, 0);
      if (rows == 0) {
        throw StateError('Could not read pixels from the desktop bitmap.');
      }

      final rgba = pixels.cast<Uint8>().asTypedList(width * height * 4);
      final image = img.Image(width: width, height: height);
      for (var i = 0; i < width * height; i++) {
        final p = i * 4;
        image.setPixelRgba(
          i % width,
          i ~/ width,
          rgba[p + 2],
          rgba[p + 1],
          rgba[p],
          255,
        );
      }
      final outputDir = Directory(directory);
      await outputDir.create(recursive: true);
      final file = File(
        '${outputDir.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(img.encodeJpg(image, quality: 90), flush: true);
      return file;
    } finally {
      api.free(info);
      api.free(pixels);
      api.selectObject(memoryDc, previous);
      api.deleteObject(bitmap);
      api.deleteDc(memoryDc);
      api.releaseDc(nullptr, screenDc);
    }
  }
}

typedef _GetDcNative = Pointer<Void> Function(Pointer<Void>);
typedef _GetDcDart = Pointer<Void> Function(Pointer<Void>);
typedef _ReleaseDcNative = Int32 Function(Pointer<Void>, Pointer<Void>);
typedef _ReleaseDcDart = int Function(Pointer<Void>, Pointer<Void>);
typedef _GetSystemMetricsNative = Int32 Function(Int32);
typedef _GetSystemMetricsDart = int Function(int);
typedef _CreateCompatibleDcNative = Pointer<Void> Function(Pointer<Void>);
typedef _CreateCompatibleDcDart = Pointer<Void> Function(Pointer<Void>);
typedef _CreateCompatibleBitmapNative =
    Pointer<Void> Function(Pointer<Void>, Int32, Int32);
typedef _CreateCompatibleBitmapDart =
    Pointer<Void> Function(Pointer<Void>, int, int);
typedef _SelectObjectNative =
    Pointer<Void> Function(Pointer<Void>, Pointer<Void>);
typedef _SelectObjectDart =
    Pointer<Void> Function(Pointer<Void>, Pointer<Void>);
typedef _BitBltNative =
    Int32 Function(
      Pointer<Void>,
      Int32,
      Int32,
      Int32,
      Int32,
      Pointer<Void>,
      Int32,
      Int32,
      Uint32,
    );
typedef _BitBltDart =
    int Function(
      Pointer<Void>,
      int,
      int,
      int,
      int,
      Pointer<Void>,
      int,
      int,
      int,
    );
typedef _GetDibitsNative =
    Int32 Function(
      Pointer<Void>,
      Pointer<Void>,
      Uint32,
      Uint32,
      Pointer<Void>,
      Pointer<Void>,
      Uint32,
    );
typedef _GetDibitsDart =
    int Function(
      Pointer<Void>,
      Pointer<Void>,
      int,
      int,
      Pointer<Void>,
      Pointer<Void>,
      int,
    );
typedef _DeleteNative = Int32 Function(Pointer<Void>);
typedef _DeleteDart = int Function(Pointer<Void>);

class _WindowsCaptureApi {
  factory _WindowsCaptureApi() {
    final user = DynamicLibrary.open('user32.dll');
    final gdi = DynamicLibrary.open('gdi32.dll');
    final kernel = DynamicLibrary.open('kernel32.dll');
    return _WindowsCaptureApi._(
      user.lookupFunction<_GetDcNative, _GetDcDart>('GetDC'),
      user.lookupFunction<_ReleaseDcNative, _ReleaseDcDart>('ReleaseDC'),
      user.lookupFunction<_GetSystemMetricsNative, _GetSystemMetricsDart>(
        'GetSystemMetrics',
      ),
      gdi.lookupFunction<_CreateCompatibleDcNative, _CreateCompatibleDcDart>(
        'CreateCompatibleDC',
      ),
      gdi.lookupFunction<
        _CreateCompatibleBitmapNative,
        _CreateCompatibleBitmapDart
      >('CreateCompatibleBitmap'),
      gdi.lookupFunction<_SelectObjectNative, _SelectObjectDart>(
        'SelectObject',
      ),
      gdi.lookupFunction<_BitBltNative, _BitBltDart>('BitBlt'),
      gdi.lookupFunction<_GetDibitsNative, _GetDibitsDart>('GetDIBits'),
      gdi.lookupFunction<_DeleteNative, _DeleteDart>('DeleteObject'),
      gdi.lookupFunction<_DeleteNative, _DeleteDart>('DeleteDC'),
      kernel.lookupFunction<_GetProcessHeapNative, _GetProcessHeapDart>(
        'GetProcessHeap',
      ),
      kernel.lookupFunction<_HeapAllocNative, _HeapAllocDart>('HeapAlloc'),
      kernel.lookupFunction<_HeapFreeNative, _HeapFreeDart>('HeapFree'),
    );
  }

  const _WindowsCaptureApi._(
    this.getDc,
    this.releaseDc,
    this.getSystemMetrics,
    this.createCompatibleDc,
    this.createCompatibleBitmap,
    this.selectObject,
    this.bitBlt,
    this.getDibits,
    this.deleteObject,
    this.deleteDc,
    this._getProcessHeap,
    this._heapAlloc,
    this._heapFree,
  );

  final _GetDcDart getDc;
  final _ReleaseDcDart releaseDc;
  final _GetSystemMetricsDart getSystemMetrics;
  final _CreateCompatibleDcDart createCompatibleDc;
  final _CreateCompatibleBitmapDart createCompatibleBitmap;
  final _SelectObjectDart selectObject;
  final _BitBltDart bitBlt;
  final _GetDibitsDart getDibits;
  final _DeleteDart deleteObject;
  final _DeleteDart deleteDc;
  final _GetProcessHeapDart _getProcessHeap;
  final _HeapAllocDart _heapAlloc;
  final _HeapFreeDart _heapFree;

  Pointer<Void> allocate(int size) =>
      _heapAlloc(_getProcessHeap(), 0x00000008, size);
  void free(Pointer<Void> pointer) => _heapFree(_getProcessHeap(), 0, pointer);
}

typedef _GetProcessHeapNative = Pointer<Void> Function();
typedef _GetProcessHeapDart = Pointer<Void> Function();
typedef _HeapAllocNative =
    Pointer<Void> Function(Pointer<Void>, Uint32, IntPtr);
typedef _HeapAllocDart = Pointer<Void> Function(Pointer<Void>, int, int);
typedef _HeapFreeNative = Int32 Function(Pointer<Void>, Uint32, Pointer<Void>);
typedef _HeapFreeDart = int Function(Pointer<Void>, int, Pointer<Void>);
