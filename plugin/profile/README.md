# 个人信息插件

这是可选安装的 Flutter/EVC 个人信息插件。安装后，点击主页用户卡可打开插件页面；未安装时不会显示原生个人信息页面，可从插件源安装或导入 `.zytbplugin` 文件。

资料查询、更新、头像选择和 OSS 上传由宿主回调完成，插件不保存签名密钥或 OSS 凭据。

## 构建

Windows：

```powershell
.\build.ps1
```

macOS / Linux：

```bash
chmod +x build.sh
./build.sh
```

脚本会生成 `dist/com.zhongyu.toolbox.profile/com.zhongyu.toolbox.profile.zytbplugin`（用于本地导入）和 `dist/index.txt`（插件索引）。将 `dist/` 发布到一个可通过 HTTP/HTTPS 访问的位置后，可把 `dist/index.txt` 的 URL 添加为插件源；索引会按 UUID 约定查找包文件。也可在应用“插件”页直接导入 `.zytbplugin` 文件。

插件 ABI 使用宿主提供的受控资料接口：宿主完成资料查询/保存、头像选择与上传，并同步已登录账号信息。不要在插件中复制签名密钥或 OSS 凭据。
