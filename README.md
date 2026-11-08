# 中育工具箱 · Flutter 版

由 `D:\Git Repos\ZhongYuToolBox_Rev`（Vue3 + Element Plus）迁移而来的跨平台客户端，支持 **Windows / Android / iOS**。

## 信息架构

5 个底部 / 侧边 tab，窗口宽度 ≥ 900 时自动切换为桌面布局（左侧 NavigationRail）。

| tab | 内容 |
| --- | --- |
| 资源 | 顶部「云笔记 / 图库」切换；笔记目录、搜索、回收站、桌面端左右分栏；图库网格 + 大图 |
| 测评 | 新测评列表 → 题目（HTML）/ 概览 / 分析；右上角进入错题本 |
| 主页 | 账号卡片、切换用户、未完成测评统计、功能入口、设置 |
| 学习 | 在线专栏（学科 → 专栏 → 文章 HTML）、我的收藏，顶部按钮进入优客畅学 |
| 问答 | 随身答（领域筛选、会话列表、会话详情、回复） |

登录为账号列表式：首次「添加账号」（选学校 → 输入用户名密码），之后打开应用或切换用户都会用本地保存的凭据自动登录。

预设学校：`sxz`（江苏省锡中）、`sxzbh`（省锡中滨湖分校）、`bjsbsz`、`sxzxx`（江苏省锡山高级中学锡西分校）、`sxzsyxx`，也可输入其它学校代码走 discover。
> `bjsbsz` 当前在 discovery 网关返回 `{"name":"Unknown"}`（无 server），作为预设保留，登录时会提示「该校服务暂不可用」，待确认正确代码。

## 目录结构

```
lib/
  core/        config（常量 / 学校预设 / AES key）、crypto、network、storage、theme、responsive、util
  data/        api（auth/note/picture/exam/mistake/column/lesson/quora）、models
  features/    auth / shell / resources / assessment / home / study / qa / settings
  shared/      widgets
```

## 环境要求

1. Flutter 3.35+（当前使用 Dart 3.10）
2. **Windows 构建必须开启开发者模式**（插件需要符号链接支持）：
   `start ms-settings:developers` → 打开「开发人员模式」
3. **Windows 构建需要 `nuget.exe` 在 PATH 中**：`flutter_inappwebview_windows`
   在 CMake 阶段会用它拉取 WebView2 / WIL / nlohmann.json。若报
   `Nuget is not installed!`，下载 https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
   放到任意目录并加入 PATH 即可（本机已放到 `%LOCALAPPDATA%\Programs\NuGet`）。
4. 不需要 VS 的 C++ ATL 组件：已移除 `flutter_secure_storage`（其 Windows 插件依赖 `atlstr.h`）；
   账号数据改用 `path_provider` 写入应用数据目录，也不再使用 `shared_preferences`。
5. 国内镜像（已为本机用户配置，换机器时重新执行）：

```powershell
[Environment]::SetEnvironmentVariable('PUB_HOSTED_URL','https://pub.flutter-io.cn','User')
[Environment]::SetEnvironmentVariable('FLUTTER_STORAGE_BASE_URL','https://storage.flutter-io.cn','User')
```

## 运行与构建

```powershell
flutter pub get
flutter run -d windows      # 桌面端
flutter run -d <android-id> # 移动端
flutter build windows --release
flutter build apk --release
```

iOS 需在 macOS 上 `flutter build ios`。

## 接口与加密

接口、字段与加密协议完全沿用旧项目，未做任何服务端改动：

- 学校发现：`GET https://hagateway.zykj.org/api/discovery/{schoolCode}`
- 登录：`POST {server}/api/TokenAuth/Login`、`GET /api/services/app/User/GetInfoAsync`、`POST /api/TokenAuth/RefreshToken`
- 云笔记：`/CloudNotes/api/Notes/*`、`/CloudNotes/api/Resources/*`
  - 参数与响应体都是 **AES-ECB/PKCS7 + Base64**，key 由当天日期动态生成（`lib/core/config/app_config.dart` 的 `generateZyAesKey`，与旧实现一致）
  - GET 参数密文直接拼在 `?` 之后，不带参数名
- 其余：图库 `PictureLibrary/*`、测评 `Task/*` + `LearningSituations/*`、错题本 `MistakeBook/*`、专栏 `appWebSite/*`、优客畅学 `/SelfStudy/api/Learn/*`、随身答 `Quora/*`

401 时统一走「refreshToken → 本地凭据重登 → 重试一次」，失败清空会话回登录页。

## 本期已实现

- 多账号登录/切换/删除，凭据保存在应用数据目录的 JSON 文件（`accounts.json` / `session.json` / `settings.json`），设置页可查看数据目录路径
- 登录上报与封禁拦截（`tbapi.loshop.com.cn`），命中封禁全屏阻断
- 资源：文件夹导航、面包屑、全部笔记视图、搜索、回收站、重命名、移动、移入回收站、新建文件夹 / 新建笔记、笔记导出 PDF、笔记下载 zip
- 图库：网格分页、上传（OSS STS 直传 + `AddPictureAsync`）、大图详情（打开原图 / 下载 / 移入回收站）
- 测评：已完成/待处理/全部三个作业列表、题目（题干/答案/解析/知识点）、自动识别本人错题、加入官方错题本（WebView 截图上传缩略图）、导出客观题答案 xlsx、概览（总分/均分/最高最低 + 五项进度 + 学生成绩表）、题目分析（分组递归 + 错误学生姓名）
- 错题本：books → items → 详情（解析题干/答案/解析 + 笔记截图 + 图片笔记）
- 学习：在线专栏（学科/专栏/搜索 + 文章 HTML 附件卡片）、我的收藏、我的消息（含已读上报）、优客畅学（课程/目录/章节）
  - 附件处理：`<img>` 代理、`<video>`/`.pdf-wrapper` → 附件卡片、章节内 `<object>`/`<video>`/ppt/pdf/image-block/习题 改写，点击拦截到附件查看器，支持下载与「下载源文件 .rcf」
- 问答：领域筛选、学科/关键词/更新时间/参与时间/关注状态筛选、滚动懒加载与自动填充、消息卡片（快照图预览 + 画板入口 + 文字回复）
- 主页：账号卡片、未完成测评统计、功能入口（选课 / 应用下载 / 开发工具 / 关于与支持 / 设置）
- 其它：中育应用下载（`CheckUpdateAsync` + APK 完整性/包名校验 + SHA-256）、关于与检查更新、OSS 上传调试

## 后续计划（需要额外决策）

- 云笔记「导入 PDF 文档」：需要把 PDF 渲染成图片（pdfium / Android PDFRenderer），会引入原生库，需三端分别验证
- 笔记矢量画板渲染（`snapshot.bin` + `data.mdb`）：需移植 ezy-board-viewer 解析器，已留 `NoteBoardRenderer` 抽象
- 随身答画板回复/播放（fabric 画板 + board zip）
- 一键订正（`examAutoReview`）
- 领创（linspirer）与本地分享（ShareView）

详细方案见 [PLAN.md](PLAN.md)。
