# 中育 Toolbox 插件模板

这是一个可独立复制为新仓库的插件工程。示例包含：

- 在 `Homepage:Menu` 和 `Note:Detail` 注册入口
- 注册并跳转两个插件页面
- 获取最新 token、API Host、用户名和头像
- 使用 `dart:io HttpClient` 发起带 token 的 HTTP 请求
- 使用 `dart:io File` 读写本地文件

## 1. 修改插件信息

修改 `pubspec.yaml` 中的 package name，并同步修改 `manifest.json` 中页面的 `library`：

```json
"library": "package:你的_package_name/main.dart"
```

然后修改 `manifest.json` 的 `id`、`name`、`version`、页面和入口。

## 2. 编写页面

每个 manifest 页面函数都必须采用固定四参数 ABI：

```dart
Widget buildPage(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String pageId, Map<String, dynamic> context) openPage,
)
```

完整字段和 posId 见 [插件开发规范](../../docs/plugin_development.md)。

## 3. 编译打包

Windows：

```powershell
.\build.ps1
```

macOS / Linux：

```bash
chmod +x build.sh
./build.sh
```

脚本会自动：

1. 执行 `flutter pub get`
2. 下载与宿主匹配的 `flutter_eval.json`
3. 使用 `dart_eval 0.8.5` 编译 `plugin.evc`
4. 生成 `dist/zytb_plugin_template.zytbplugin`

`flutter_eval` 仅支持 Flutter/Dart API 的子集。若编译器提示某个 Widget 或方法未绑定，请换用已支持的 API，而不是依赖宿主内部类。

页面入口请直接返回完整 Widget 树，不要返回插件自定义的 `StatelessWidget` / `StatefulWidget`。
插件侧不要使用 `async` / `await`：HTTP 使用 `httpRequest/getHttpResult`，本地文件使用同步的 `File.*Sync` API。
宿主 Map 的动态值请直接用 `value == ''` 判断空值，不要调用 `toString/trim/isEmpty/isNotEmpty`，也不要把动态值插值后直接传给 Widget。
