# 中育 Toolbox Flutter 插件开发指南

中育 Toolbox 插件是扩展名为 `.zytbplugin` 的 ZIP 包，运行时使用 `flutter_eval` / `dart_eval` 执行预先编译的 Dart 字节码，并把入口函数返回的 Flutter `Widget` 放入宿主的原生导航栈。

这套机制不是 WebView，也不是原生动态库。Windows、Android 和 iOS 发布包都采用 AOT，安装后不能把新的 Dart 源码编译进宿主；因此可安装插件必须先编译为 EVC，再由解释器执行。

## 包结构

```text
manifest.json
plugin.evc
```

ZIP 根目录必须直接包含 `manifest.json` 和 `plugin.evc`，不能再套工程目录。插件安装后会解压到软件目录的 `plugins/<id>/`；Windows 如果软件目录不可写则回退到应用数据目录，Android/iOS 使用应用专属数据目录。

## 工程与编译

从 [plugin/template](../plugin/template/) 复制工程，保持普通 Flutter package 结构：

```text
manifest.json
pubspec.yaml
analysis_options.yaml
lib/main.dart
build.ps1
build.sh
```

构建脚本会执行 `flutter pub get`、使用 `dart_eval 0.8.5` 生成 EVC，并打包成 `.zytbplugin`。编译时必须使用与宿主兼容的 `flutter_eval.json` bindings。模板和示例已经包含下载 bindings 的脚本逻辑。

```powershell
.\build.ps1
```

## manifest.json

```json
{
  "id": "com.example.demo",
  "name": "示例插件",
  "version": "1.0.0",
  "author": "Example",
  "description": "一个 Flutter 插件",
  "bytecode": "plugin.evc",
  "pages": [
    {
      "id": "home",
      "title": "示例页面",
      "library": "package:demo/main.dart",
      "function": "buildHome"
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

一个插件可以注册多个 page 和多个 action；同一个 page 可以被多个位置复用。没有注册 action 的位置不会显示插件控件。原本是单一功能按钮的位置，在存在插件 action 时会显示原功能与插件功能的操作列表。

## 插件索引源

宿主可以从插件索引源读取可安装插件。内置官方源为：

```text
https://git.loshop.com.cn/LoshopStudio/ZytbAddonIndex/raw/branch/main/index.txt
```

用户可以添加多个自定义索引源。官方源始终存在，不能删除；每个源可以单独启用或关闭自动更新。索引源 URL 应指向 `index.txt`，插件包默认放在该文件同级目录下的 `<uuid>/<uuid>.zytbplugin`，例如：

```text
https://example.invalid/addons/index.txt
https://example.invalid/addons/01234567-89ab-cdef-0123-456789abcdef/01234567-89ab-cdef-0123-456789abcdef.zytbplugin
```

推荐的索引行格式是：

```text
(UUID@主版本.次版本.修订版本)[插件名称]插件介绍
```

例如：

```text
(01234567-89ab-cdef-0123-456789abcdef@1.2.0)[示例插件]用于演示索引源安装
```

当前官方源还存在不带版本号的兼容格式：

```text
(UUID)[插件名称]插件介绍
```

对于这种旧格式，宿主会优先读取同目录的 `detail.txt` 版本；没有有效详情版本时，安装/更新再以包内 `manifest.json` 的 `version` 为准。空行和无法解析的行会被忽略；UUID、名称和介绍中的括号分隔符应按上述格式使用。

索引源还可以在每个插件目录下提供可选的 `detail.txt`：

```text
作者
1.2.0
更新日志，可继续使用后续多行
```

文件位置为 `<index.txt 同级目录>/<uuid>/detail.txt`。第一行是作者，第二行是三段式版本号，第三行开始是更新日志。缺少该文件、文件为空或版本行不是 `x.y.z` 时，插件仍可以正常显示和安装；宿主只会忽略无法解析的字段。对于不带 `@版本` 的旧索引行，`detail.txt` 的版本会用于目录展示、跨源版本比较和自动更新判断；如果索引行和 `detail.txt` 都没有有效版本，跨源选择按源顺序进行，安装/更新时则以下载包内的 `manifest.json.version` 为准。带 `@版本` 的索引行优先使用索引行版本。

官方源也兼容用一列表格表达同样的三行内容，例如：

```text
| `Loshop Wu` |
| ------------ |
| `0.0.1` |
| `无` |
```

表格分隔线、反引号和多余空白会被宿主忽略；因此上述内容仍会解析为作者、版本、更新日志三项。第三方源推荐使用普通三行文本，便于跨平台生成。

同一个 UUID 出现在多个源时，宿主按三段式版本号的数值比较选择最大版本（`1.10.0` 大于 `1.9.0`）。如果版本相同，按源列表顺序选择，排在前面的源优先。插件包安装前仍会校验包内 manifest 的 UUID 和版本，索引内容与下载包不一致时不会安装。

索引源用于发现、安装和更新插件。启用自动更新后，宿主可以在检查索引时为该源上的已安装插件检查更高版本；首次安装插件仍应经过用户的信任确认。索引源本身不应返回或要求账号 Token，插件包的高权限行为以安装确认页面为准。

## 页面 ABI

`function` 指向的顶层函数必须接收四个参数并返回 `Widget`：

```dart
Widget buildHome(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String pageId, Map<String, dynamic> context) openPage,
) {
  final latest = getLatestHost();
  return Scaffold(
    appBar: AppBar(title: const Text('示例插件')),
    body: Text('${latest['displayName']}'),
  );
}
```

`pageContext` 是入口所在宿主页面的完整可序列化上下文；宿主会在不同位置传入不同字段。`host` 是进入页面时的会话快照。`getLatestHost()` 每次同步读取最新会话，token 刷新后也会返回新值。`openPage` 只能打开当前插件 manifest 中注册的 page。

插件入口在首次显示及宿主数据（例如 HTTP 请求状态）变化时会被重新调用，返回的 Widget 树由 Flutter 正常协调更新；入口必须快速、可重复调用且无副作用。不要在入口中发请求或写文件，也不要在 `build` 中执行副作用。当前模板仅使用同步入口和同步回调；HTTP 通过宿主提交请求、保存结果、触发页面重建，不要在插件回调中使用 `async` / `await`。不要执行长时间 CPU 工作。

## 宿主信息与 HTTP

`host` 包含：

```text
token, apiHost, webHost, username, displayName, avatar, avatarRaw,
userId, schoolCode, schoolName, pluginId, pluginPath,
httpRequest, getHttpResult
```

`pluginPath` 是插件目录，可用于插件自己的数据文件。插件被授予完整文件系统权限，但仍受 Windows、Android、iOS 操作系统权限和沙箱限制；不要把文件路径写死为某个平台格式。

提交 HTTP 请求：

```dart
final latest = getLatestHost();
final void Function(String, String, Map<String, dynamic>) request =
    latest['httpRequest'];
request('GET', '${latest['apiHost']}/api/services/app/User/GetInfoAsync', {
  'requestId': 'user-info',
  'headers': {'Authorization': 'Bearer ${latest['token']}'},
  'timeoutSeconds': 40,
});
```

读取结果：

```dart
final Map<String, dynamic> Function(String) getResult =
    latest['getHttpResult'];
final state = getResult('user-info');
final response = state['response'];
final json = response is Map ? response['json'] : null;
```

结果字段为 `started`、`pending`、`error` 和 `response`。响应包含 `statusCode`、`reasonPhrase`、`headers`、UTF-8 `body`、`bodyBytes` 和解析后的 `json`。`requestId` 必填且必须在当前页面内唯一。支持任意 HTTP/HTTPS 方法、请求头、文本/JSON/二进制请求体，超时范围为 1-300 秒。

## 可注册位置

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

进入插件时会附带原页面上下文，例如笔记 `fileId`、图库资源 `url`、测评 `taskId`、学习页 tab、问答 `sessionId`、专栏 `columnId` / 文章页 id / 附件 URL 等。字段只会增加，插件应忽略未知字段。

常见字段如下：

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
| `Column:Detail` | `pageId`, `columnId`, `columnName`, `url` |
| `Column:AttachmentDetail` | `kind`, `url`, `displayUrl`, `name` |
| `Ask:PlusBtn` | `catalogId`, `topicId`, `keyword`, `watchMode` |
| `Ask:Detail` | `sessionId`, `askUserPhoto`, `selectedIndex`, `messages` |

## 稳定性约束

EVC 解释执行发生在 Flutter UI isolate。当前 `dart_eval` 执行器没有指令预算或取消接口，死循环或长时间同步计算无法被 `Future.timeout` 抢占，也无法在保留任意 Flutter Widget 返回能力的前提下简单移到后台 isolate。因此插件不得在入口或点击回调中做大规模同步计算、无限循环或同步网络访问。只安装可信插件：插件拥有完整本地文件系统访问、任意网络访问能力，并可读取当前会话凭据。宿主会捕获可捕获的插件异常并显示错误页；开发时应保留完整堆栈，不要用空白 `SizedBox` 吞掉异常。

`dart_eval` 桥接参数必须是运行时 `$Value`。宿主会递归包装入口参数、Map、List 和回调参数；插件侧不要把原生 `List` / `Map` 通过自定义桥接对象重新传回 Flutter 构造函数。

## 图标

内置名称包括 `add`、`article`、`book`、`build`、`camera`、`cloud`、`code`、`download`、`edit`、`fact_check`、`file`、`folder`、`forum`、`image`、`info`、`link`、`note`、`open_in_new`、`person`、`school`、`search`、`send`、`settings`、`share`、`star`、`upload`、`web`。未知名称回退为扩展图标。
