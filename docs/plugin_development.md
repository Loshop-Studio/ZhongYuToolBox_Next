# 中育 Toolbox Flutter 插件开发指南

[TOC]

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


## 从零开发教程：获取用户名

本节带你从模板做出一个完整插件：它在主页功能区注册按钮，打开 Flutter 页面后由宿主发起 HTTP 请求，并显示当前用户名。

### 第 1 步：复制模板并改包名

复制 plugin/template 为一个新目录，例如 plugin/my_username。修改 pubspec.yaml：

    name: my_username
    description: Get current username for ZhongYu Toolbox
    version: 1.0.0
    publish_to: none

library URI 中的 my_username 必须与这里的 name 一致。

### 第 2 步：注册页面和按钮

在 manifest.json 中声明页面入口和 Homepage:Menu action：

    {
      "id": "com.example.username",
      "name": "获取用户名",
      "version": "1.0.0",
      "author": "你的名字",
      "description": "从当前账号资料接口读取用户名。",
      "bytecode": "plugin.evc",
      "pages": [
        {
          "id": "home",
          "title": "获取用户名",
          "library": "package:my_username/main.dart",
          "function": "buildHome"
        }
      ],
      "actions": [
        {
          "id": "get-username",
          "posId": "Homepage:Menu",
          "label": "获取用户名",
          "icon": "person",
          "pageId": "home",
          "order": 10
        }
      ]
    }

manifest 的 id 要全局唯一；page id 和 action id 要在插件内唯一。action.pageId 必须指向已声明的 page。

### 第 3 步：写页面和请求

buildHome 是同步入口。页面首次进入时先读取已有请求状态，按钮点击后提交新请求：

    import 'package:flutter/material.dart';
    
    Widget buildHome(
      Map<String, dynamic> pageContext,
      Map<String, dynamic> host,
      Map<String, dynamic> Function() getLatestHost,
      void Function(String, Map<String, dynamic>) openPage,
    ) {
      final latest = getLatestHost();
      final getResult =
          latest['getHttpResult'] as Map<String, dynamic> Function(String);
      final state = getResult('username');
      Widget status;
    
      if (state['pending'] == true) {
        status = const Text('正在获取……');
      } else if ((state['error'] ?? '').toString().isNotEmpty) {
        status = Text(state['error'].toString());
      } else if (state['started'] != true) {
        status = const Text('点击按钮获取用户名');
      } else {
        final response = state['response'];
        final json = response is Map ? response['json'] : null;
        final result = json is Map ? json['result'] : null;
        final username = result is Map ? result['userName'] : null;
        status = Text((username ?? '接口未返回用户名').toString());
      }
    
      return Scaffold(
        appBar: AppBar(title: const Text('获取用户名')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              status,
              ElevatedButton(
                onPressed: () => _loadUsername(getLatestHost),
                child: const Text('获取用户名'),
              ),
            ],
          ),
        ),
      );
    }
    
    void _loadUsername(
      Map<String, dynamic> Function() getLatestHost,
    ) {
      final current = getLatestHost();
      final apiHost =
          current['apiHost'].toString().replaceFirst(RegExp(r'/+$'), '');
      if (apiHost.isEmpty) return;
    
      final request = current['httpRequest']
          as void Function(String, String, Map<String, dynamic>);
      request(
        'GET',
        apiHost + '/api/services/app/User/GetInfoAsync',
        {
          'requestId': 'username',
          'headers': {
            'Authorization':
                'Bearer ' + current['token'].toString(),
            'Content-Type': 'application/json',
          },
          'timeoutSeconds': 20,
        },
      );
    }

宿主 HTTP 是异步执行的：点击按钮调用 httpRequest 后，插件不要 await；宿主完成时会更新 getHttpResult 并触发页面刷新。

### 第 4 步：编译并在本地安装

Windows PowerShell：

    cd plugin/my_username
    .\build.ps1

macOS/Linux：

    cd plugin/my_username
    chmod +x build.sh
    ./build.sh

在 dist 目录找到生成的 .zytbplugin，然后在客户端打开“设置 → 插件 → 导入”。检查主页功能区是否出现“获取用户名”，进入后点击按钮，确认加载、错误和用户名状态均正常。

## 适配所有位置的开发提示

按钮文字、图标、排序由 manifest action 控制；每个 action 指向一个 page。使用原页面信息时从 pageContext 读取，不要再重复请求宿主已经传入的 ID 或 URL。

例如专栏详情的 columnId 和文章 pageId：

    final columnId = (pageContext['columnId'] ?? '').toString();
    final articleId = (pageContext['pageId'] ?? '').toString();
    final articleUrl = (pageContext['url'] ?? '').toString();

附件预览位置传 kind、url、displayUrl、name；图库详情会传资源 id 和 url；笔记详情会传 fileId。字段都可能为空，需先做空值检查。

一条 action 只能指向一个 page，但可以在多个 posId 注册多个 action，也可以让多个 action 复用同一个 page。若多个插件注册同一位置，宿主会将其放入操作列表；action.order 数值小的排在前面。

## 完整 posId 上下文字段参考

| posId | 常见上下文 |
| --- | --- |
| Homepage:Menu | route、posId |
| Homepage:UserCard | route、username、displayName、userId |
| Note:PlusBtn | folderId、folderName、allMode |
| Note:Detail | fileId、fileName、pageCount、pageIndex |
| Gallery:Add | recycle、pictureCount |
| Gallery:Detail | id、picture、url、name、size、createTime、index、total、recycle |
| Exercise:Home | listType、tabIndex、tabName |
| Exercise:Detail | taskId、name、view、wrongCount、task、questionCount、questions |
| Study:Home | tabIndex、tabName |
| Column:Detail | pageId、columnId、columnName、url |
| Column:AttachmentDetail | kind、url、displayUrl、name |
| Ask:PlusBtn | catalogId、topicId、keyword、watchMode |
| Ask:Detail | sessionId、askUserPhoto、selectedIndex、messages |

上述字段是当前宿主提供的常见字段，不是永远固定的完整协议。未知字段必须忽略，缺少字段必须正常处理。

## 官方索引源和自动更新

客户端预置的官方索引源是：

    https://git.loshop.com.cn/LoshopStudio/ZytbAddonIndex/raw/branch/main/index.txt

用户可以添加多个索引源。官方源不能删除；各源可以单独启用“自动更新”。宿主请求索引时会在 URL 后追加当前毫秒时间戳参数 v，避免使用旧缓存，不要把这个动态值作为源地址保存。

推荐 index.txt 每个插件一行：

    (com.example.username@1.0.0)[获取用户名]读取当前账号用户名

包 URL 根据索引文件位置生成：

    index.txt 同级目录/插件ID/插件ID.zytbplugin

可选 detail.txt 三行内容：

    作者
    1.0.0
    更新说明

第一行作者，第二行版本，第三行起为更新日志。相同 ID 出现在多个源时，按三段版本号数值选择最高版本；版本相同按源列表顺序选择。

## 官方上架教程：zpi.loshop.com.cn

官方管理页地址：

    https://zpi.loshop.com.cn/

当前页面提供“创建插件”“更新插件”“删除插件”“当前索引”四个标签。索引行格式为：

    (插件ID@主版本.次版本.修订版本)[插件名称]插件介绍

### 上架前准备

1. 已完成本地开发并编译出 .zytbplugin；
2. 插件包在客户端成功导入并运行；
3. manifest 与网站上要提交的信息一致；
4. version 使用三段式，如 1.0.0；
5. ZIP 根目录直接包含 manifest.json 和 plugin.evc；
6. 插件包小于 50 MiB；
7. 已准备作者、简介和更新说明；
8. 准备一个安全位置保存网站生成的插件密钥。

### 首次创建

在“创建插件”标签填写：

| 网站字段 | 填写内容 | 页面限制 |
| --- | --- | --- |
| 插件 ID | manifest.id | 必填；字母或数字开头，可有字母、数字、点、下划线、短横线，最长 128 字符；宿主 id 上限为 80 字符 |
| 插件名称 | manifest.name | 必填，最长 100 字符 |
| 插件介绍 | manifest.description | 必填，最长 1000 字符 |
| 作者名称 | manifest.author | 必填，最长 100 字符 |
| 三段式版本号 | manifest.version | 必须为数字.数字.数字，例如 1.2.3 |
| 更新说明 | 本次发布的变更 | 必填，最长 3000 字符 |
| 插件文件 | build 脚本生成的 .zytbplugin | 必填，最大 50 MiB |

提交创建后，网站会返回插件密钥。立即保存在密码管理器或离线安全位置。后续更新和删除需要该密钥。不要将密钥放入源码、manifest、插件包、Git 或公开聊天。

### 发布更新

1. 修改插件源码；
2. 同时递增 pubspec.yaml 和 manifest.json 的 version；
3. 运行 build.ps1 或 build.sh 生成新包；
4. 本地安装并确认新版本可运行；
5. 打开网站“更新插件”标签；
6. 输入插件 ID 和创建时保存的插件密钥；
7. 填入插件名称、介绍、作者、新版本和更新说明；
8. 选择新的 .zytbplugin 并提交；
9. 到“当前索引”确认 ID、版本和介绍。

更新表单允许不选择插件文件，这只适合单独修改介绍、作者或更新说明；代码变化必须上传重建的新包。

版本建议：

    1.0.0 -> 1.0.1  修复问题
    1.0.1 -> 1.1.0  增加向后兼容功能
    1.1.0 -> 2.0.0  不兼容变更

每次发布代码都增加版本号，不要用相同版本替换不同的 EVC 字节码，否则客户端可能认为无需更新。

### 删除插件

“删除插件”需要插件 ID 和插件密钥。删除会影响官方索引里的安装和更新，且可能不可逆。操作前确认目标 ID，备份源码、最终包和密钥，并评估是否应该先发布停更说明。

### 核对发布结果

在“当前索引”确认新条目已出现，检查 ID、版本号、名称和简介。之后在客户端手动刷新插件索引，再从官方源安装或更新。

官方索引源下载 URL 为：

    https://git.loshop.com.cn/LoshopStudio/ZytbAddonIndex/raw/branch/main/index.txt

平台为新插件生成的下载地址遵循：

    官方索引目录/插件ID/插件ID.zytbplugin

## 依赖选择和平台能力

插件可在 pubspec.yaml 中添加 Dart/Flutter 依赖，但 pub 包能下载并不保证 EVC 可编译、可运行。纯 Dart 包通常更容易兼容；依赖原生库、FFI、Platform Channel 或原生注册的 Flutter 插件，需要宿主应用提前集成对应部分。插件不能在安装时向现有客户端动态加入原生代码。

建议从简单、纯 Dart 依赖开始，并逐个验证编译、运行和 Windows/Android 表现。网络推荐使用宿主 httpRequest，以减少平台差异。

## 常见错误定位

### 找不到外部函数 / nonexistent external function

通常是当前 flutter_eval 未注册插件用到的 Flutter 构造函数或扩展。根据堆栈中的 Ex 编号定位调用，再检查该构造函数是否在当前 flutter_eval bridge 中注册。声明存在不代表构造函数已注册。可以换用已有桥接的组件，例如 GestureDetector，或把复杂组件放到宿主回调中创建。

### $null 不能转换为 $Instance

常见原因是缺少 Map 字段、宿主回调为空或可空参数被传入要求非空对象的 Flutter API。先读取动态值到局部变量，做 null 检查，再转换为明确类型。

### Debug 卡死、Release 灰屏

EVC 入口在 Flutter UI isolate 同步执行。死循环、大量同步计算、同步网络或重复发起请求会阻塞页面。入口只应读取当前状态并构造 Widget；请求和文件操作应放到明确的用户操作中。

### 更新后还是旧代码

确认插件 version 已递增，manifest.json 和 pubspec.yaml 一致，重新运行构建脚本，客户端更新/重新导入最新包并完全重启应用。旧版本的字节码不会因为源码变更自动刷新。

## 发布检查清单

- [ ] manifest 的 id、name、version 正确且唯一；
- [ ] pubspec.yaml 包名和 library URI 一致；
- [ ] page/action ID 唯一；
- [ ] action.pageId 存在，posId 有效；
- [ ] 入口函数四参数顺序正确且返回 Widget；
- [ ] 动态字段有空值处理；
- [ ] Token 在发请求前通过 getLatestHost 重新读取；
- [ ] requestId 在页面内唯一；
- [ ] 文件只写入 pluginPath 下的插件数据目录；
- [ ] 没有使用未经确认的 Flutter/EVC bridge API；
- [ ] 没有入口副作用、死循环或长时间同步任务；
- [ ] manifest.json 和 pubspec.yaml 版本一致；
- [ ] 构建成功，ZIP 根目录结构正确；
- [ ] 文件小于 50 MiB；
- [ ] 客户端本地安装运行成功；
- [ ] 上架后保管插件密钥并核对当前索引。
