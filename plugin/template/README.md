# 中育 Toolbox Flutter 插件模板

这是一个使用 `flutter_eval` / `dart_eval` 编译的 Flutter Widget 插件模板。插件不是 WebView 页面，也不是原生动态库；宿主在受控的 EVC 解释器中执行入口函数，并把返回的 Flutter `Widget` 放入原生导航栈。

模板展示：

- 在 `Homepage:Menu` 和 `Note:Detail` 注册入口
- 注册并跳转两个 Flutter 页面
- 读取最新 token、API Host、用户名和头像等宿主信息
- 通过宿主 HTTP API 请求接口
- 使用 Dart `File` 同步读写插件目录文件

## 工程结构

```text
manifest.json
pubspec.yaml
analysis_options.yaml
lib/main.dart
build.ps1
build.sh
```

入口函数必须返回完整的 Flutter Widget，并遵循四参数 ABI：

```dart
Widget buildHome(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String pageId, Map<String, dynamic> context) openPage,
) { ... }
```

模板中的页面只使用同步逻辑。HTTP 使用 `host['httpRequest']` 提交请求，再通过 `host['getHttpResult']` 读取宿主保存的结果；不要在插件页面中使用 `async` / `await`。

## 编译打包

Windows：

```powershell
.\build.ps1
```

macOS / Linux：

```bash
chmod +x build.sh
./build.sh
```

输出为 `dist/zytb_plugin_template.zytbplugin`，ZIP 根目录直接包含 `manifest.json` 与 `plugin.evc`。导入宿主后，插件会安装到软件目录的 `plugins/` 下；如果操作系统拒绝写入，则使用应用专属数据目录。

完整 ABI、权限、上下文和 `posId` 说明见 [插件开发规范](../../docs/plugin_development.md)。
