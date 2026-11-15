# 中育 Toolbox 插件 SDK

这里包含插件开发规范和一个可以直接复制的模板工程：

- [完整开发规范](../docs/plugin_development.md)
- [模板工程](template/README.md)
- [获取用户名示例插件](example/README.md)

最快开始方式：复制 `plugin/template` 到一个新的目录，修改 `pubspec.yaml`、`manifest.json` 和 `lib/main.dart`，然后运行：

```powershell
.\build.ps1
```

生成的 `.zytbplugin` 位于模板工程的 `dist/`。在中育 Toolbox 中打开“设置 → 插件 → 导入”即可安装。

宿主版本锁定：

```text
flutter_eval 0.8.2
dart_eval 0.8.5
```

插件拥有完整文件系统读写和任意 HTTP/HTTPS 网络访问权限，请勿加载不可信代码。
