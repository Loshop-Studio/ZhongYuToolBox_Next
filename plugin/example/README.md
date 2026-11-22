# 获取用户名示例插件

这是一个最小的 Flutter/EVC 插件示例：

- 在 `Homepage:Menu` 注册“获取用户名”按钮
- 打开 Flutter 页面后读取最新宿主 token 和 API Host
- 调用 `/api/services/app/User/GetInfoAsync`
- 从响应的 `result.userName` 展示当前用户名

API 地址会自动去除首尾空白和多余的末尾 `/`，再拼接接口路径，避免生成 `hostapi` 或 `host}/api` 这样的错误地址。

页面入口位于 `lib/main.dart`，manifest 通过 `library` 和 `function` 指向 `buildUsernamePage`。插件不包含 HTML 或 WebView 页面。

## 编译

Windows：

```powershell
.\build.ps1
```

macOS / Linux：

```bash
chmod +x build.sh
./build.sh
```

生成 `dist/zytb_username_example.zytbplugin`，在中育 Toolbox 的“设置 → 插件 → 导入”中安装即可。

完整 API、上下文字段和所有 `posId` 请参阅 [插件开发规范](../../docs/plugin_development.md)。
