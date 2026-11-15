# 获取用户名示例插件

这是一个最小、可直接编译的中育 Toolbox 插件：

- 在 `Homepage:Menu` 注册“获取用户名”按钮
- 打开页面后读取宿主提供的最新 `token` 和 `apiHost`
- 请求 `/api/services/app/User/GetInfoAsync`
- 从响应的 `result.userName` 展示当前用户名
- 请求失败时在页面显示 HTTP 状态或异常，可点击“重新获取”重试

核心代码位于 `lib/main.dart`，manifest 位于 `manifest.json`。

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

生成文件：

```text
dist/zytb_username_example.zytbplugin
```

在中育 Toolbox 中打开“设置 → 插件 → 导入”，选择该文件即可安装。

完整 ABI、权限、上下文字段和所有 `posId` 请参阅 [插件开发规范](../../docs/plugin_development.md)。
