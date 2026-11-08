import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'screen_capture.dart';

enum ScreenshotAssistantStatus { stopped, starting, running, error }

class ScreenshotAssistantService extends ChangeNotifier {
  ScreenshotAssistantService({ScreenCapture capture = const ScreenCapture()})
    : _capture = capture;

  static const int mqttPort = 61136;
  static const int ftpPort = 21;
  static const int discoveryPort = 33338;
  static const int passivePortStart = 30000;
  static const int passivePortEnd = 30100;

  final ScreenCapture _capture;
  final Random _random = Random.secure();
  final List<File> _screenshots = <File>[];
  final Set<_MqttPeer> _peers = <_MqttPeer>{};
  final Set<_FtpSession> _ftpSessions = <_FtpSession>{};
  bool _captureInProgress = false;

  ScreenshotAssistantStatus status = ScreenshotAssistantStatus.stopped;
  String? errorMessage;
  String? connectionCode;
  String? localAddress;
  String? _mainTopic;
  String? _screenshotDirectory;
  ServerSocket? _mqttServer;
  ServerSocket? _ftpServer;
  RawDatagramSocket? _udpSocket;
  Timer? _broadcastTimer;
  bool _disposed = false;
  bool _stopping = false;

  List<File> get screenshots => List<File>.unmodifiable(_screenshots);
  String? get screenshotDirectory => _screenshotDirectory;

  static Future<List<String>> availableAddresses() async {
    final result = <String>[];
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final networkInterface in interfaces) {
      for (final address in networkInterface.addresses) {
        if (!address.isLoopback && !address.address.startsWith('169.254.')) {
          result.add(address.address);
        }
      }
    }
    return result;
  }

  Future<void> start({String? preferredAddress}) async {
    if (status == ScreenshotAssistantStatus.running ||
        status == ScreenshotAssistantStatus.starting) {
      return;
    }
    status = ScreenshotAssistantStatus.starting;
    errorMessage = null;
    if (!_disposed) notifyListeners();
    try {
      if (!Platform.isWindows) {
        throw UnsupportedError('OpenFlier 桌面截图服务目前仅支持 Windows。');
      }
      final ip = await _findLocalAddress(preferredAddress);
      if (ip == null) throw StateError('未找到可用的局域网 IPv4 地址。');
      final docs = await getApplicationDocumentsDirectory();
      final root = Directory(
        '${docs.path}${Platform.pathSeparator}OpenFlierScreenshots',
      );
      await root.create(recursive: true);

      _mainTopic = _randomHex(32);
      connectionCode = _random.nextInt(10000).toString().padLeft(4, '0');
      localAddress = ip;
      _screenshotDirectory = root.path;
      _screenshots
        ..clear()
        ..addAll(
          await root
              .list()
              .where((e) => e is File && _isImage(e.path))
              .cast<File>()
              .toList(),
        );
      _screenshots.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      _mqttServer = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        mqttPort,
        shared: false,
      );
      _ftpServer = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        ftpPort,
        shared: false,
      );
      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
      );
      _mqttServer!.listen(
        _onMqttConnection,
        onError: _onServerError,
        onDone: _onServerClosed,
      );
      _ftpServer!.listen(
        _onFtpConnection,
        onError: _onServerError,
        onDone: _onServerClosed,
      );
      _broadcastTimer = Timer.periodic(
        const Duration(milliseconds: 800),
        (_) => _broadcastCode(),
      );
      _broadcastCode();
      status = ScreenshotAssistantStatus.running;
    } catch (error) {
      await _closeServers();
      status = ScreenshotAssistantStatus.error;
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> stop() async {
    if (_stopping) return;
    _stopping = true;
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    for (final peer in _peers.toList()) {
      await peer.close();
    }
    for (final session in _ftpSessions.toList()) {
      await session.close();
    }
    await _closeServers();
    status = ScreenshotAssistantStatus.stopped;
    _stopping = false;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(stop());
    super.dispose();
  }

  Future<void> _closeServers() async {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _udpSocket?.close();
    _udpSocket = null;
    await _mqttServer?.close();
    _mqttServer = null;
    await _ftpServer?.close();
    _ftpServer = null;
  }

  Future<void> _onServerError(Object error) async {
    errorMessage = error.toString();
    status = ScreenshotAssistantStatus.error;
    if (!_disposed) notifyListeners();
    await stop();
  }

  void _onServerClosed() {
    if (status == ScreenshotAssistantStatus.running) {
      errorMessage = '服务监听意外关闭';
      status = ScreenshotAssistantStatus.error;
      if (!_disposed) notifyListeners();
    }
  }

  Future<String?> _findLocalAddress(String? preferredAddress) async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    final addresses = <String>[];
    for (final networkInterface in interfaces) {
      for (final address in networkInterface.addresses) {
        if (!address.isLoopback && !address.address.startsWith('169.254.')) {
          addresses.add(address.address);
        }
      }
    }
    if (preferredAddress != null && addresses.contains(preferredAddress)) {
      return preferredAddress;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  void _broadcastCode() {
    final socket = _udpSocket;
    final code = connectionCode;
    final ip = localAddress;
    if (socket == null || code == null || ip == null) return;
    socket.broadcastEnabled = true;
    final bytes = utf8.encode('$ip::$code');
    socket.send(bytes, InternetAddress('255.255.255.255'), discoveryPort);
    final octets = ip.split('.');
    if (octets.length == 4) {
      octets[3] = '255';
      socket.send(bytes, InternetAddress(octets.join('.')), discoveryPort);
    }
  }

  void _onMqttConnection(Socket socket) {
    final peer = _MqttPeer(this, socket);
    _peers.add(peer);
    socket.listen(
      peer.addData,
      onError: (_) => peer.close(),
      onDone: () => peer.close(),
    );
  }

  Future<void> _handleMqttPublish(
    _MqttPeer peer,
    String topic,
    List<int> payload,
  ) async {
    Map<String, dynamic> message;
    try {
      final decoded = jsonDecode(utf8.decode(payload));
      if (decoded is! Map<String, dynamic>) return;
      message = decoded;
    } catch (_) {
      return;
    }
    final type = message['type'];
    if (type == 10003) {
      peer.publish(peer.clientId, <String, dynamic>{
        'type': 20000,
        'data': <String, dynamic>{'topic': _mainTopic},
      });
      return;
    }
    if (type == 10006) {
      peer.publish(peer.clientId, <String, dynamic>{
        'type': 20007,
        'data': <String, dynamic>{'topic': 'Ec1xkK+uFtV/QO/8rduJ2A=='},
      });
      return;
    }
    if (type != 10005) return;
    if (_captureInProgress) return;
    _captureInProgress = true;

    try {
      final directory = _screenshotDirectory;
      if (directory == null) return;
      late String filename;
      try {
        final file = await _capture.capture(directory);
        filename = file.uri.pathSegments.last;
        _screenshots.insert(0, file);
        if (!_disposed) notifyListeners();
      } catch (error) {
        filename = await _saveCaptureError(directory, error);
      }
      peer.publish('${peer.clientId}/REQUEST_SCREEN_CAPTURE', <String, dynamic>{
        'type': 20005,
        'data': <String, dynamic>{
          'name': filename,
          'deviceCode': 'PYTHON-DEMO',
          'versionCode': '2.1.1',
        },
      });
    } finally {
      _captureInProgress = false;
    }
  }

  Future<String> _saveCaptureError(String directory, Object error) async {
    final image = img.Image(width: 1200, height: 160);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    img.drawString(
      image,
      'Screenshot capture failed',
      font: img.arial14,
      color: img.ColorRgb8(190, 35, 35),
    );
    img.drawString(
      image,
      error.toString().replaceAll(RegExp(r'\s+'), ' '),
      font: img.arial14,
      x: 0,
      y: 40,
      color: img.ColorRgb8(50, 50, 50),
    );
    final file = File(
      '$directory${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(img.encodeJpg(image), flush: true);
    _screenshots.insert(0, file);
    if (!_disposed) notifyListeners();
    return file.uri.pathSegments.last;
  }

  void _onFtpConnection(Socket socket) {
    final session = _FtpSession(
      this,
      socket,
      _screenshotDirectory ?? Directory.systemTemp.path,
    );
    _ftpSessions.add(session);
    session.start();
  }

  String _randomHex(int length) => List<String>.generate(
    length,
    (_) => _random.nextInt(16).toRadixString(16),
  ).join();

  static bool _isImage(String path) =>
      path.toLowerCase().endsWith('.jpg') ||
      path.toLowerCase().endsWith('.jpeg') ||
      path.toLowerCase().endsWith('.png');
}

class _MqttPeer {
  _MqttPeer(this.service, this.socket);
  final ScreenshotAssistantService service;
  final Socket socket;
  final List<int> _buffer = <int>[];
  final Map<String, int> _subscriptions = <String, int>{};
  final Map<int, int> _outgoingPublications = <int, int>{};
  final Map<int, (String, List<int>)> _incomingQos2 =
      <int, (String, List<int>)>{};
  String clientId = '';
  bool _closed = false;
  int _nextPacketId = 1;

  void addData(List<int> data) {
    _buffer.addAll(data);
    while (true) {
      final packet = _takePacket();
      if (packet == null) break;
      _handlePacket(packet.$1, packet.$2);
    }
  }

  (int, List<int>)? _takePacket() {
    if (_buffer.length < 2) return null;
    var remaining = 0;
    var multiplier = 1;
    var offset = 1;
    int digit;
    do {
      if (offset >= _buffer.length) return null;
      digit = _buffer[offset++];
      remaining += (digit & 127) * multiplier;
      multiplier *= 128;
    } while ((digit & 128) != 0 && offset < 6);
    if (_buffer.length < offset + remaining) return null;
    final header = _buffer[0];
    final body = _buffer.sublist(offset, offset + remaining);
    _buffer.removeRange(0, offset + remaining);
    return (header, body);
  }

  void _handlePacket(int header, List<int> body) {
    switch (header >> 4) {
      case 1:
        if (body.length < 12) {
          unawaited(close());
          return;
        }
        final protocolLength = (body[0] << 8) | body[1];
        if (body.length < 2 + protocolLength + 4) {
          unawaited(close());
          return;
        }
        var cursor = 2 + protocolLength + 4;
        final parsed = _readString(body, cursor);
        if (parsed == null) {
          unawaited(close());
          return;
        }
        clientId = parsed.$1;
        socket.add(<int>[0x20, 0x02, 0x00, 0x00]);
      case 8:
        if (body.length < 3) return;
        final packetId = (body[0] << 8) | body[1];
        final granted = <int>[];
        var cursor = 2;
        while (cursor < body.length) {
          final parsed = _readString(body, cursor);
          if (parsed == null || parsed.$1.isEmpty) return;
          cursor = parsed.$2;
          if (cursor >= body.length) return;
          final qos = body[cursor++] & 3;
          _subscriptions[parsed.$1] = qos;
          granted.add(qos > 2 ? 0x80 : qos);
        }
        _writePacket(0x90, <int>[packetId >> 8, packetId & 255, ...granted]);
      case 3:
        if (body.length < 2) return;
        final parsed = _readString(body, 0);
        if (parsed == null) return;
        final qos = (header >> 1) & 3;
        if (qos == 3) {
          unawaited(close());
          return;
        }
        var cursor = parsed.$2;
        var packetId = 0;
        if (qos > 0) {
          if (cursor + 1 >= body.length) return;
          packetId = (body[cursor] << 8) | body[cursor + 1];
          cursor += 2;
        }
        final payload = body.sublist(cursor);
        if (qos == 0) {
          unawaited(service._handleMqttPublish(this, parsed.$1, payload));
        } else if (qos == 1) {
          unawaited(service._handleMqttPublish(this, parsed.$1, payload));
          _writePacket(0x40, <int>[packetId >> 8, packetId & 255]);
        } else {
          _incomingQos2.putIfAbsent(packetId, () => (parsed.$1, payload));
          _writePacket(0x50, <int>[packetId >> 8, packetId & 255]);
        }
      case 4:
        if (body.length >= 2) {
          final packetId = (body[0] << 8) | body[1];
          _outgoingPublications.remove(packetId);
        }
      case 5:
        if (body.length >= 2) {
          final packetId = (body[0] << 8) | body[1];
          if (_outgoingPublications[packetId] == 2) {
            _writePacket(0x62, <int>[packetId >> 8, packetId & 255]);
          }
        }
      case 6:
        if (body.length >= 2) {
          final packetId = (body[0] << 8) | body[1];
          final publication = _incomingQos2.remove(packetId);
          if (publication != null) {
            unawaited(
              service._handleMqttPublish(this, publication.$1, publication.$2),
            );
          }
          _writePacket(0x70, <int>[body[0], body[1]]);
        }
      case 7:
        if (body.length >= 2) {
          final packetId = (body[0] << 8) | body[1];
          _outgoingPublications.remove(packetId);
        }
      case 12:
        _writePacket(0xD0, const <int>[]);
      case 14:
        unawaited(close());
    }
  }

  void publish(String topic, Map<String, dynamic> payload) {
    final data = utf8.encode(jsonEncode(payload));
    final topicBytes = utf8.encode(topic);
    final qos = _matchingSubscriptionQos(topic);
    if (qos == null) return;
    final body = <int>[
      topicBytes.length >> 8,
      topicBytes.length & 255,
      ...topicBytes,
    ];
    if (qos > 0) {
      final packetId = _allocatePacketId();
      _outgoingPublications[packetId] = qos;
      body
        ..add(packetId >> 8)
        ..add(packetId & 255);
    }
    body.addAll(data);
    socket.add(<int>[
      0x30 | (qos << 1),
      ..._encodeLength(body.length),
      ...body,
    ]);
  }

  int? _matchingSubscriptionQos(String topic) {
    int? result;
    for (final entry in _subscriptions.entries) {
      if (_matches(entry.key, topic) &&
          (result == null || entry.value > result)) {
        result = entry.value;
      }
    }
    return result;
  }

  int _allocatePacketId() {
    for (var attempt = 0; attempt < 65535; attempt++) {
      final packetId = _nextPacketId;
      _nextPacketId = _nextPacketId == 65535 ? 1 : _nextPacketId + 1;
      if (!_outgoingPublications.containsKey(packetId)) return packetId;
    }
    throw StateError('No MQTT packet identifiers are available.');
  }

  bool _matches(String filter, String topic) {
    if (filter == '#') return true;
    final f = filter.split('/');
    final t = topic.split('/');
    for (var i = 0; i < f.length; i++) {
      if (f[i] == '#') return true;
      if (i >= t.length || (f[i] != '+' && f[i] != t[i])) return false;
    }
    return f.length == t.length;
  }

  void _writePacket(int header, List<int> body) =>
      socket.add(<int>[header, ..._encodeLength(body.length), ...body]);

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    service._peers.remove(this);
    socket.destroy();
  }
}

(String, int)? _readString(List<int> data, int offset) {
  if (offset + 1 >= data.length) return null;
  final length = (data[offset] << 8) | data[offset + 1];
  if (offset + 2 + length > data.length) return null;
  return (
    utf8.decode(
      data.sublist(offset + 2, offset + 2 + length),
      allowMalformed: true,
    ),
    offset + 2 + length,
  );
}

List<int> _encodeLength(int value) {
  final result = <int>[];
  do {
    var digit = value % 128;
    value ~/= 128;
    if (value > 0) digit |= 128;
    result.add(digit);
  } while (value > 0);
  return result;
}

class _FtpSession {
  _FtpSession(this.service, this.socket, this.root);
  final ScreenshotAssistantService service;
  final Socket socket;
  final String root;
  final StringBuffer _lineBuffer = StringBuffer();
  ServerSocket? _passive;
  bool _closed = false;
  final String _cwd = '/';

  void start() {
    _reply(220, 'OpenFlier screenshot FTP service ready');
    socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .listen(
          (chunk) {
            _lineBuffer.write(chunk);
            var value = _lineBuffer.toString();
            var newline = value.indexOf('\n');
            while (newline >= 0) {
              final line = value.substring(0, newline).trimRight();
              value = value.substring(newline + 1);
              unawaited(_handleLine(line));
              newline = value.indexOf('\n');
            }
            _lineBuffer
              ..clear()
              ..write(value);
          },
          onError: (_) => unawaited(close()),
          onDone: () => unawaited(close()),
        );
  }

  Future<void> _handleLine(String line) async {
    if (line.isEmpty) return;
    final split = line.split(RegExp(r'\s+'));
    final command = split.first.toUpperCase();
    final argument = line.length > split.first.length
        ? line.substring(split.first.length).trim()
        : '';
    switch (command) {
      case 'USER':
        _reply(230, 'Anonymous access granted');
      case 'PASS':
        _reply(230, 'Login successful');
      case 'SYST':
        _reply(215, 'UNIX Type: L8');
      case 'FEAT':
        socket.write(
          '211-Features\r\n UTF8\r\n EPSV\r\n PASV\r\n SIZE\r\n211 End\r\n',
        );
      case 'OPTS':
        _reply(200, 'UTF8 enabled');
      case 'TYPE':
        _reply(200, 'Type set');
      case 'PWD':
        socket.write('257 "$_cwd" is current directory\r\n');
      case 'CWD':
        _reply(250, 'Directory changed');
      case 'NOOP':
        _reply(200, 'OK');
      case 'QUIT':
        _reply(221, 'Goodbye');
        await close();
      case 'PASV':
        await _openPassive(false);
      case 'EPSV':
        await _openPassive(true);
      case 'SIZE':
        final file = _resolve(argument);
        if (file != null && await file.exists()) {
          _reply(213, '${await file.length()}');
        } else {
          _reply(550, 'File unavailable');
        }
      case 'RETR':
        await _sendFile(argument);
      case 'LIST':
      case 'NLST':
        await _sendListing();
      default:
        _reply(502, 'Command not supported');
    }
  }

  Future<void> _openPassive(bool extended) async {
    await _passive?.close();
    _passive = null;
    for (
      var port = ScreenshotAssistantService.passivePortStart;
      port <= ScreenshotAssistantService.passivePortEnd;
      port++
    ) {
      try {
        _passive = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        break;
      } on SocketException {
        continue;
      }
    }
    final server = _passive;
    if (server == null) return _reply(425, 'No passive ports available');
    if (extended) {
      _reply(229, 'Entering Extended Passive Mode (|||${server.port}|)');
    } else {
      final ip = service.localAddress!.split('.').map(int.parse).toList();
      _reply(
        227,
        'Entering Passive Mode (${[...ip, server.port >> 8, server.port & 255].join(',')})',
      );
    }
  }

  Future<Socket?> _acceptData() async {
    final server = _passive;
    _passive = null;
    if (server == null) return null;
    try {
      return await server.first.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      return null;
    } finally {
      await server.close();
    }
  }

  Future<void> _sendFile(String name) async {
    final file = _resolve(name);
    if (file == null || !await file.exists()) {
      return _reply(550, 'File unavailable');
    }
    _reply(150, 'Opening binary data connection');
    final data = await _acceptData();
    if (data == null) return _reply(425, 'Data connection failed');
    try {
      await data.addStream(file.openRead());
      await data.flush();
      await data.close();
      _reply(226, 'Transfer complete');
    } catch (_) {
      await data.close();
      _reply(426, 'Transfer aborted');
    }
  }

  Future<void> _sendListing() async {
    _reply(150, 'Opening data connection');
    final data = await _acceptData();
    if (data == null) return _reply(425, 'Data connection failed');
    final files = Directory(root).listSync().whereType<File>().where(
      (f) => ScreenshotAssistantService._isImage(f.path),
    );
    for (final file in files) {
      final stat = file.statSync();
      data.write(
        '-rw-r--r-- 1 ftp ftp ${stat.size} Jan 01 00:00 ${file.uri.pathSegments.last}\r\n',
      );
    }
    await data.flush();
    await data.close();
    _reply(226, 'Transfer complete');
  }

  File? _resolve(String name) {
    final basename = name.replaceAll('\\', '/').split('/').last;
    if (basename.isEmpty || basename == '.' || basename == '..') return null;
    return File('$root${Platform.pathSeparator}$basename');
  }

  void _reply(int code, String message) => socket.write('$code $message\r\n');

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    service._ftpSessions.remove(this);
    await _passive?.close();
    socket.destroy();
  }
}
