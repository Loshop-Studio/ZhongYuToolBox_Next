# 中育 Toolbox 插件开发

插件是一个扩展名为 `.zytbplugin` 的 ZIP 文件，根目录至少包含：

```text
manifest.json
plugin.evc
```

`plugin.evc` 使用 `flutter_eval 0.8.2 / dart_eval 0.8.5` 编译。插件由自定义字节码虚拟机运行，不是系统原生动态库。

> 当前版本应让页面入口函数直接返回完整 Widget 树，不要再返回插件自定义的
> `StatelessWidget` / `StatefulWidget`。Windows 真实宿主中的延迟 `build` 桥接可能造成
> `List<dynamic> is not a subtype of $Value`，Debug 卡住、Release 灰屏。
> 插件侧也不要使用 `async` / `await`；HTTP 使用宿主 `httpRequest/getHttpResult`，
> 文件操作使用同步的 `File.*Sync` API。
> 对宿主 Map 中取出的动态值不要调用 `toString/trim/isEmpty/isNotEmpty`，
> 直接用 `value == ''` 判断；也不要把动态值插值后直接传给 Widget。
> HTTP JSON 响应请读取 `response['json']`；不要在插件侧调用 `jsonDecode`，
> 宿主会解析并递归包装 JSON，避免原生值泄漏到 eval Widget。

## 权限

已启用插件会获得：

- 完整本地文件系统读写权限（仍受 Android/iOS 等操作系统应用沙箱限制）
- 任意 HTTP/HTTPS 网络访问权限
- 当前有效 token、API Host、Web Host、用户名、头像、用户 ID 和学校信息

插件不自动获得进程执行权限或 Flutter MethodChannel 权限。

## 安装位置

- Windows：优先复制到主程序可执行文件同级的 `plugins/` 目录；若安装目录不可写，则回退到应用数据目录。
- Android：复制到应用专属数据目录下的 `plugins/`。APK 安装目录由系统保护，不能直接写入。
- iOS：复制到应用沙箱的 Application Support 目录下的 `plugins/`。

Windows 旧版本安装在 `%APPDATA%` 中的插件会在启动时复制到新的程序目录，旧副本会保留以便恢复。

## manifest.json

```json
{
  "id": "com.example.demo",
  "name": "示例插件",
  "version": "1.0.0",
  "author": "Example",
  "description": "一个最小示例",
  "bytecode": "plugin.evc",
  "pages": [
    {
      "id": "home",
      "title": "示例页面",
      "library": "package:demo/main.dart",
      "function": "buildHome"
    },
    {
      "id": "detail",
      "title": "第二个页面",
      "library": "package:demo/main.dart",
      "function": "buildDetail"
    }
  ],
  "actions": [
    {
      "id": "homepage-entry",
      "posId": "Homepage:Menu",
      "label": "示例插件",
      "icon": "extension",
      "pageId": "home",
      "order": 100
    }
  ]
}
```

一个插件可注册任意多个 `pages` 和 `actions`。同一页面也可以被多个位置复用。

## 页面 ABI

manifest 中 `function` 指向的顶层函数必须接收四个参数并返回 `Widget`：

```dart
Widget buildHome(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String pageId, Map<String, dynamic> context) openPage,
) {
  return Scaffold(
    appBar: AppBar(title: const Text('示例插件')),
    body: Center(
      child: Text('你好，${host['displayName']}'),
    ),
  );
}
```

- `pageContext`：用户点击入口时所在宿主页面的完整可序列化上下文。
- `host`：页面创建时的账号信息快照。
- `getLatestHost()`：同步读取当前最新账号信息；token 自动刷新后会返回新值。
- `openPage(pageId, context)`：打开当前插件在 manifest 中注册的另一个页面。

`host` 字段：

```text
token, apiHost, webHost, username, displayName, avatar, avatarRaw,
userId, schoolCode, schoolName, pluginId, pluginPath, httpRequest,
getHttpResult
```

`pluginPath` 是插件解压目录，可用于保存插件自己的文件；由于插件拥有完整文件系统权限，也可以访问其它绝对路径。

`httpRequest` 由宿主执行任意 HTTP/HTTPS 请求，避免 `dart_eval` 内置 `HttpClient` 桥接缺少请求头和状态码等成员：

```dart
final latest = getLatestHost();
final void Function(
  String method,
  String url,
  Map<String, dynamic> options,
) httpRequest = latest['httpRequest'];
httpRequest(
  'POST',
  'https://example.com/api',
  {
    'requestId': 'save-data',
    'headers': {'Authorization': 'Bearer ${latest['token']}'},
    'body': {'hello': 'world'},
    'timeoutSeconds': 40,
  },
);
```

请求提交后宿主会自动重建插件页面。通过 `getHttpResult(requestId)` 获取状态：

```dart
final latest = getLatestHost();
final Map<String, dynamic> Function(String) getHttpResult =
    latest['getHttpResult'];
final state = getHttpResult('save-data');
final pending = state['pending'] == true;
final error = state['error'];
final response = state['response'];
```

`response` 包含 `statusCode`、`reasonPhrase`、`headers`、UTF-8 文本 `body` 和原始字节数组 `bodyBytes`。支持任意 HTTP 方法、请求头、文本/JSON/二进制请求体，超时范围为 1-300 秒。`requestId` 必填，并由插件自行保证页面内唯一。

HTTP 采用“提交请求 → 宿主保存结果 → 页面重建”的模型，不要在插件点击回调中使用 `await` 或异步回调闭包；当前 `dart_eval` 在这些场景下可能恢复错误的局部变量并卡死界面。

## posId

```text
Homepage:Menu
Homepage:UserCard
Note:PlusBtn
Note:Detail
Gallery:Add
Gallery:Detail
Exercise:Home
Exercise:Detail
Study:Home
Column:Detail
Column:AttachmentDetail
Ask:PlusBtn
Ask:Detail
```

没有插件入口的位置不会显示额外控件。原本是单一按钮的位置，在没有插件时继续直接执行原功能；注册插件后会显示“原功能 + 插件功能”的操作列表。

## pageContext 主要字段

| posId | 主要字段 |
| --- | --- |
| `Homepage:Menu` | `route`, `posId` |
| `Homepage:UserCard` | `username`, `displayName`, `userId` |
| `Note:PlusBtn` | `folderId`, `folderName`, `allMode` |
| `Note:Detail` | `fileId`, `fileName` |
| `Gallery:Add` | `recycle`, `pictureCount` |
| `Gallery:Detail` | `id`, `picture`, `url`, `name`, `size`, `createTime`, `index`, `total`, `recycle` |
| `Exercise:Home` | `listType`, `tabIndex`, `tabName` |
| `Exercise:Detail` | `taskId`, `name`, `view`, `wrongCount`, `task`, `questions` |
| `Study:Home` | `tabIndex`, `tabName` |
| `Column:Detail` | `pageId`（文章页）、`columnId`, `columnName`, `url` |
| `Column:AttachmentDetail` | `kind`, `url`, `displayUrl`, `name` |
| `Ask:PlusBtn` | `catalogId`, `topicId`, `keyword`, `watchMode` |
| `Ask:Detail` | `sessionId`, `askUserPhoto`, `selectedIndex`, `messages` 和当前消息字段 |

字段只会增加，不应依赖未记录字段一定不存在。

## 图标名

内置支持 `add`, `article`, `book`, `build`, `camera`, `cloud`, `code`, `download`, `edit`, `fact_check`, `file`, `folder`, `forum`, `image`, `info`, `link`, `note`, `open_in_new`, `person`, `photo`, `school`, `search`, `send`, `settings`, `share`, `star`, `upload`, `web`。未知名称回退为扩展图标。

## 编译与打包

插件工程使用普通 Dart/Flutter package 结构，并放入与宿主版本匹配的 `flutter_eval.json` bindings：

```text
.dart_eval/bindings/flutter_eval.json
lib/main.dart
pubspec.yaml
```

安装编译器并生成 EVC：

```shell
dart pub global activate dart_eval 0.8.5
dart_eval compile -o plugin.evc
```

最后将 `manifest.json`、`plugin.evc` 和插件需要的其它资源压缩为 ZIP，再把扩展名改成 `.zytbplugin`。不要在 ZIP 外再套一层目录，`manifest.json` 必须位于根目录。
