# 中育工具箱 Flutter 迁移计划

把 `D:/Git Repos/ZhongYuToolBox_Rev`（Vue3 + Vite + Element Plus + Pinia，多端：Web / Electron / H5+ / Android / iOS）
迁移为 Flutter 跨平台应用，目标平台 **Windows + Android + iOS**。

---

## 1. 范围

### 本期要做（5 个 tab 全部真实接接口）

| tab | 对应旧模块 | 内容 |
| --- | --- | --- |
| 资源 | `/note`、`/picture` | 顶部「笔记 / 图库」切换；笔记列表、笔记详情、图库网格 + 大图 |
| 测评 | `/exam` | 测评任务列表、题目、概览、题目分析（HTML）；右上角入口进错题本 |
| 主页 | `LoginView`、`AppDownloadsView`、`linspirer`、`DevelopView`、`AboutView` | 账号卡片、切换用户、未完成测评统计、各功能入口 |
| 学习 | `/column`、`/lesson` | 在线专栏（学科→专栏→文章→详情 HTML）；顶部按钮进优客畅学（课程→目录→章节 HTML） |
| 问答 | `/quora` | 领域、会话列表、会话详情、发消息 |

### 登录模型（本期重点改造）

- 账号列表式登录：卡片显示「学校 / 用户名 / 上次登录时间」，点卡片即切换登录。
- 添加账号两步：① 选学校（预设 `sxz` / `sxzbh` / `bjsbsz` / `sxzxx` / `sxzsyxx`，或输入其它学校 id 走 discover）② 输入用户名密码。
- 凭据本地保存（学校 id + 用户名 + 密码），启动应用 / 切换用户 / token 失效时自动重新登录。

### 本期不做

- 笔记矢量画板渲染（`snapshot.bin` + ObjectBox `mdb` + `ezy-board-viewer`），仅保留抽象接口。
- 「导入 PDF 文档」完整链路（模板 bin + 逐页转图 + OSS 上传），菜单项保留并提示后续支持。
- 「一键订正」自动流程（`examAutoReview`），先展示可订正数量。
- Electron / H5+ / uniapp 壳、浏览器代理（`127.0.0.1:5005`）。

---

## 2. 技术选型

| 用途 | 依赖 | 说明 |
| --- | --- | --- |
| 状态管理 | `flutter_riverpod` | Controller + AsyncValue |
| 路由 | `go_router` | `StatefulShellRoute` 承载 5 tab，详情页叠加 |
| 网络 | `dio` | 拦截器：Bearer 注入、401 恢复、错误归一化 |
| 加密 | `pointycastle` + `encrypt` | 中育 AES-ECB/PKCS7 + Base64 |
| 本地存储 | `path_provider` + JSON 文件 | 账号凭据、token、偏好落在应用数据目录；不用 `shared_preferences` / `flutter_secure_storage`（后者 Windows 插件依赖 C++ ATL） |
| 偏好 | `settings.json`（应用数据目录） | 上次账号、UI 偏好 |
| 图片 | `cached_network_image` | 笔记截图、图库、头像 |
| HTML | `flutter_inappwebview` | 专栏文章 / 章节内容 / 题目 HTML（三端含 Windows） |
| 文件 | `file_picker`、`path_provider` | 后续 PDF 导入、下载 |

图标一律使用 Material Icons，禁止 emoji。界面语言中文。

---

## 3. 工程结构

```
lib/
  main.dart
  app.dart                      # MaterialApp.router + 主题 + ProviderScope
  core/
    config/app_config.dart      # API base、学校预设、学科、OSS 前缀、版本号
    crypto/zy_aes.dart          # generateAesKey / aesEncrypt / aesDecrypt
    network/dio_client.dart     # Bearer、401 恢复
    network/api_exception.dart
    storage/app_file_store.dart # 应用数据目录文件读写（原子写 + 备份）
    storage/local_store.dart    # accounts/session/settings 三个 JSON 文件
    storage/session_store.dart  # token / userId / schoolCode / apiBaseUrl
    theme/app_theme.dart        # Material 3 浅色主题 + 语义色
    responsive/breakpoints.dart # 900 / 767 断点 + context 扩展
    util/*.dart
  data/
    models/*.dart               # NoteItem / PictureItem / ExamTask / QuoraSession ...
    api/auth_api.dart
    api/note_api.dart
    api/picture_api.dart
    api/exam_api.dart
    api/mistake_api.dart
    api/column_api.dart
    api/lesson_api.dart
    api/quora_api.dart
  features/
    auth/     login_page.dart, add_account_school_page.dart, add_account_credential_page.dart,
              auth_controller.dart
    shell/    app_shell.dart（移动 bottom nav / 桌面 rail）, tab 配置
    resources/ note_list_page.dart, note_detail_page.dart, gallery_page.dart,
               widgets/(note_row.dart, note_action_sheet.dart, new_item_menu.dart)
    assessment/ exam_list_page.dart, exam_questions_page.dart, exam_overview_page.dart,
                exam_analysis_page.dart, mistake_book_page.dart, mistake_detail_page.dart
    home/     home_page.dart, account_card.dart, entry_grid.dart
    study/    column_page.dart, column_detail_page.dart, lesson_course_page.dart,
              lesson_catalog_page.dart, lesson_chapter_page.dart
    qa/       quora_page.dart, quora_detail_page.dart
  shared/
    widgets/  app_bar.dart, empty_view.dart, error_view.dart, loading_view.dart,
              content_html_view.dart, confirm_sheet.dart
```

---

## 4. 核心机制

### 4.1 账号与会话

```
Account { id(origin|userId 或临时 uuid), schoolCode, schoolName, userName, password, apiBaseUrl,
          webServer, realName, photo, userId, lastLoginAt }
```

- 账号列表持久化到应用数据目录的 `accounts.json`（JSON 数组），会话存 `session.json`，偏好存 `settings.json`；写入采用临时文件 + 备份 + 原子替换。
- 当前会话（token/refreshToken/过期时间/apiBaseUrl/userId/schoolCode）单独存，启动时校验。
- 登录流程（复刻 `stores/auth.ts`）：
  1. `discover(code)` → `server`、`webServer`
  2. `TokenAuth/Login` → 四个 token 字段
  3. `User/GetInfoAsync` → realName/photo/userId
  4. 写会话 + 更新账号 `lastLoginAt`
  5. 启动 60s 定时器：`tokenExpire - now <= 10s && now < refreshExpire` → `RefreshToken`
- 401 处理：先 refresh，失败再 `autoRelogin()`，仍失败清会话跳登录页（`dio` 拦截器内单例锁，避免并发风暴）。
- `accountKey = origin(apiBaseUrl) | userId`，用于按账号隔离本地缓存。

### 4.2 中育 AES

- key：常量串 + `day/month/year` 规则生成 15 字符（复刻 `generateAesKey`），**每次请求即时生成**（跨天自动切换）。
- 算法：AES/ECB/PKCS7，输出 Base64。
- 云笔记 GET 参数：密文**直接拼在 `?` 之后**（无参数名），必须用原始 URL 字符串交给 dio，不能走 `queryParameters`（否则 `+` 会被编码成 `%2B` 或被服务端当空格，两种都可能改变行为，需实测确认后固定）。

### 4.3 请求层

- 默认 baseUrl = 当前会话 `apiBaseUrl`（不是配置常量），未登录时用 `http://sxz.api.zykj.org`。
- 自动注入 `Authorization: Bearer <token>`；`skipAuth` 用于登录 / 发现 / 刷新。
- 统一解析：ABP `{result,success,error}`；`success === false` 抛 `error.message`；非 2xx 抛 HTTP 消息。
- 云笔记单独封装（`{code,msg,data}` + 密文解密）。
- 优客畅学 `{data}`；领创 `{code,data}`。

### 4.4 响应式

- `>= 900`：桌面布局（NavigationRail + 内容区；笔记页左右分栏）。
- `< 900`：移动布局（底部 5 tab；笔记页列表/详情两页切换）。
- 组件内用 `LayoutBuilder` + `Breakpoints`，不依赖具体平台判断。

### 4.5 主题

- Material 3 浅色，主色沿用截图里的中性灰白 + 蓝色强调（登录按钮、tab 选中态）。
- 圆角 12/16，卡片 1px 浅描边 + 轻微阴影，列表行 56~64 高。
- 暗色为主题预留（`ThemeMode.system`，先只做浅色配色）。

---

## 5. 页面规格

### 5.1 登录 / 账号列表

- 顶部标题「登录」+ 右上「添加账号」文本按钮。
- 账号卡片：左圆形头像（首字或 `photo`）、学校名 + 用户名、副标题「上次登录：yyyy-MM-dd HH:mm」、右侧切换箭头。
- 点击卡片：读凭据 → 加载态 → 成功进 5 tab 壳；失败弹错并停留在列表。
- 卡片长按 / 右键：编辑备注、删除账号。

### 5.2 添加账号

- Step1 学校：五行预设（`sxz` / `sxzbh` / `bjsbsz` / `sxzxx` / `sxzsyxx`）+「其它学校」输入框（输入 id 后即时调 discover 校验，成功显示学校名，失败提示「学校代码无效」）。
- Step2 凭据：用户名、密码（可切换明文）、「登录」按钮；登录成功后保存账号并回到列表，同时切换为当前账号。

### 5.3 壳（5 tab）

- 资源 / 测评 / 主页 / 学习 / 问答 顺序固定，主页默认首页。
- 桌面 rail 可展开收起；tab 切换保持各 tab 内部导航栈（`StatefulShellRoute.indexedStack`）。

### 5.4 资源 - 笔记

- 顶部 segment：「云笔记 / 图库」；右侧搜索、回收站图标。
- 笔记列表：文件夹行（图标 + 名称）与笔记行（图标 + 名称 + 时间）；面包屑导航；「全部」「搜索」「回收站」为次级入口。
- 长按 / 右键：重命名、移至回收站、移动。
- 右下 FAB：展开「新建笔记 / 新建文件夹 / 导入PDF文档」；前两项接 `Notes/Update|Add` 类接口（按旧实现改造），PDF 项提示后续支持。
- 桌面：列表宽度 320~380，右侧详情页空态「选择左侧笔记查看」。

### 5.5 笔记详情

- 数据：`Resources/GetByFileId` → 按 `pageIndex` 分组；`resourceType=2` 为主图，`0/其它` 为页内图片。
- UI：顶栏返回 + 标题；横向 `PageView` 翻页 + 页码指示；`InteractiveViewer` 缩放；页内图片横向缩略图条。
- 抽象：`NoteBoardRenderer`（`Widget build(NotePage page)`），当前只实现 `ScreenshotRenderer`。

### 5.6 图库

- `PictureLibrary/GetAllPicturesFromLibrary` 分页加载，网格 3 列（手机）/ 5~6 列（桌面）。
- 点击进大图查看（缩放 + 左右切换 + 删除/移入回收站）。

### 5.7 测评 / 错题本

- 列表：`Task/GetStudentTaskListAsync` 分页，卡片显示名称、状态、时间；已完成项可进概览/分析。
- 右上「错题本」按钮 → books 列表 → 题目列表（`SearchMistakeQstItemsAsync`）→ 题目详情（HTML）。
- 题目 HTML 用 `content_html_view`（WebView + 统一 CSS 注入）。

### 5.8 学习

- 在线专栏：学科 → 专栏 → 文章列表（分页 + 搜索）→ 文章详情（HTML，`HitAsync` 上报已读）。
- 顶部按钮「优客畅学」→ 课程列表（循环分页）→ 章节目录 → 章节内容（HTML）。

### 5.9 问答

- 领域 chips + 会话列表（下拉刷新、滚动加载）。
- 会话详情：消息气泡（文字 / 图片）、发送框；图片走 OSS 上传（后续或先只读）。

### 5.10 主页

- 账号卡片（头像、姓名、学校、切换用户按钮）。
- 未完成测评卡片：「未完成测评 N」「M 份可订正客观题」+「一键订正」按钮（本期禁用并提示）。
- 入口网格（可配置列表）：云笔记、图库、随身答、中育应用下载、领创、开发工具、关于与支持作者。
- 消息 / 设置入口（设置：主题、清除缓存、检查更新、退出登录）。

---

## 6. 接口映射（实现清单）

| 模块 | 接口 | 方法 |
| --- | --- | --- |
| 发现 | `https://hagateway.zykj.org/api/discovery/{code}` | GET |
| 登录 | `/api/TokenAuth/Login` | POST |
| 用户信息 | `/api/services/app/User/GetInfoAsync` | GET |
| 刷新 | `/api/TokenAuth/RefreshToken` | POST (header `refreshtoken`) |
| 笔记列表 | `/CloudNotes/api/Notes/GetByParentId?{aes}` | GET |
| 笔记全量 | `/CloudNotes/api/Notes/GetAll` | GET |
| 笔记搜索 | `/CloudNotes/api/Notes/Search?{aes}` | GET |
| 笔记更新 | `/CloudNotes/api/Notes/Update` | POST (aes body) |
| 笔记回收站 | `/CloudNotes/api/Notes/MoveToRecycleBin` | POST (aes body) |
| 笔记资源 | `/CloudNotes/api/Resources/GetByFileId?{aes}` | GET |
| 图库列表 | `/api/services/app/PictureLibrary/GetAllPicturesFromLibrary` | GET |
| 图库回收站 | `PictureLibrary/MoveToRecycleBinAsync`、`DeletePicture` | POST/DELETE |
| 测评列表 | `/api/services/app/Task/GetStudentTaskListAsync` | POST |
| 测评详情 | `/api/services/app/Task/GetExamTaskAsync?id=` | GET |
| 测评概览 | `LearningSituations/GetExamOverviewAsync?examId=` | GET |
| 题目分析 | `LearningSituations/GetQuestionAnalysisAsync?examId=` | GET |
| 题目 HTML | `/Question/View/{qstId}?showAnalysis=true` | GET |
| 错题本 | `MistakeBook/GetMyMistakeBooksAsync`、`SearchMistakeQstItemsAsync`、`MultiRemoveMistakeItemsAsync`、`GetMistakeQstItemDetailInfoAsync` | GET/POST |
| 专栏 | `appWebSite/GetTopicSpecialAsync`、`SearchMyPagesByColIdAsync`、`GetPageAsync`、`HitAsync`、`GetSpecialCatalogAsync`、`GetMyCatalogPagesAsync`、`Message/GetMyMessageListAsync` | GET/POST |
| 优客畅学 | `/SelfStudy/api/Learn/LearningCourses`、`CourseDetail`、`readContent` | GET |
| 随身答 | `Quora/GetCatalogs`、`Quora/GetSessions`、会话消息接口 | GET/POST |

字段与请求体严格照抄旧实现（`src/api/*.ts`），不做字段重命名。

---

## 7. 实施阶段

| 阶段 | 内容 | 验收点 |
| --- | --- | --- |
| P0 骨架 | `flutter create`（android/ios/windows）、目录、主题、路由、自适应 5 tab 壳 + 占位页 | 三端能启动，窗口缩放可切移动/桌面壳 |
| P1 账号登录 | 本地文件存储、discover、登录/刷新/自动重登、账号列表页、添加账号两步、切换与删除 | 冷启动自动登录；切换账号数据互不串 |
| P2 数据层 | dio + AES + 8 个模块 api/model 封装 | 每个接口有可运行的调试入口 |
| P3 资源 | 笔记列表（目录/全部/搜索/回收站）、详情（截图渲染）、重命名/移动/删除、新建文件夹/笔记、图库 | 列表与详情在手机/桌面两套布局可用 |
| P4 测评 | 测评列表/概览/分析（HTML）、错题本 | 题目 HTML 正确渲染 |
| P5 学习 | 专栏全链路、优客畅学全链路 | HTML 文章与附件可读 |
| P6 问答 | 领域/会话/详情 | 列表分页与详情渲染 |
| P7 主页与收尾 | 主页卡片与入口、设置、构建配置、README | `flutter build windows/apk` 通过 |

> iOS 只生成工程与签名配置占位，实际编译需要 macOS。

---

## 8. 假设与开放项

1. 学校代码已由用户更正为 `sxz / sxzbh / bjsbsz / sxzxx / sxzsyxx`。discovery 实测：
   - `sxz` → 江苏省锡中，`http://sxz.api.zykj.org`
   - `sxzbh` → 省锡中滨湖分校，`https://sxzbh-api.zyai.cc`
   - `sxzxx` → 江苏省锡山高级中学锡西分校，`https://sxzxx-api.zyai.cc`
   - `sxzsyxx` → name 与代码相同（无中文名），`http://sxzsyxx.api.zykj.org`
   - `bjsbsz` → `{"name":"Unknown"}`，无 server；作为预设保留，登录时明确提示「该校服务暂不可用」，**待确认正确代码**
   - 名称等于代码时按无有效名处理，显示代码大写。
2. 主页三个图标入口默认「云笔记 / 图库 / 随身答」，实现为可配置列表。
3. 「一键订正」本期只统计不执行。
4. 「导入 PDF 文档」本期只保留入口，完整链路（模板 bin + 逐页转图 + OSS + `Resources/AddOrUpdate` + `Notes/AddOrUpdate`）留到后续。
5. HTML 渲染统一用 `flutter_inappwebview`；若 Windows WebView2 运行时不满足，回退为 `flutter_html`（专栏/章节/题目均需验证一次）。
6. 旧版 `iframeBase` 下的 `navPage.html` / 选课 `index.html` 不再内嵌，专栏改原生接口；「选课」入口暂用系统浏览器打开带 token 的官方链接。

---

## 9. 风险

- **接口加密**：key 与当天日期绑定，跨天/时区差异会导致解密失败，需在错误提示里给出「请重试/检查系统时间」。
- **query 里放 Base64**：`+`、`/`、`=` 在 URL 中的处理必须与 Web 端一致，需用真实账号比对一次返回结果。
- **HTML 内容体量大**：专栏文章与题目含公式/图片/pdf 附件，WebView 需要统一注入 CSS 与图片代理，否则桌面端排版会散。
- **多账号隔离**：缓存、请求基地址、token 都要按 `accountKey` 隔离，避免切换后打到旧学校域名。

---

## 10. 实现进度

| 阶段 | 状态 | 交付物 |
| --- | --- | --- |
| P0 骨架 | 完成 | `flutter create`（android/ios/windows）、`core`（config/crypto/network/storage/theme/responsive）、自适应 5 tab 外壳 |
| P1 账号登录 | 完成 | 本地文件存储、discover、登录/刷新/自动重登、账号卡片列表、添加账号两步、切换与删除 |
| P2 数据层 | 完成 | note / picture / exam / mistake / column / lesson / quora 七个 api + 模型 |
| P3 资源 | 完成（PDF 导入除外） | 笔记目录/面包屑/**全部笔记视图**/搜索/回收站/重命名/移动/新建文件夹与笔记、桌面左右分栏、截图渲染详情、图库网格与大图 |
| P4 测评 | 完成 | 已完成/待处理/全部作业列表、题目（题干/答案/解析/知识点）、自动识别本人错题、加入官方错题本（WebView 截图 + OSS）、导出客观题 xlsx、概览（统计 + 五项进度 + 学生表）、分析（分组递归 + 错误学生）、错题本 books → items → 详情（解析 + 笔记截图 + 图片笔记） |
| P5 学习 | 完成 | 专栏（学科 → 专栏 → 搜索 → 文章 HTML + 附件卡片）、我的收藏、我的消息（含已读）、优客畅学（课程 → 目录 → 章节 + 附件改写 + 手动渲染 + 下载源文件 + 附件查看器） |
| P6 问答 | 完成 | 领域筛选、学科/关键词/更新时间/参与时间/关注状态、滚动懒加载与自动填充、消息卡片（快照图 + 画板入口 + 文字回复） |
| P7 主页与收尾 | 完成 | 账号卡片、未完成测评统计、入口网格（含选课外链）、设置页、README、Android/iOS 网络与明文流量配置 |

> 用户确认：导入 PDF、一键订正、矢量画板渲染、应用下载、领创、开发工具、消息中心 **按计划留到后续**，本期不实现。
>
> 后续用户追加要求「所有功能一个个核对，旧的功能全部迁移」，已完成：应用下载、开发工具、消息中心（专栏消息）、纠错本详情解析、图库上传、笔记导出 PDF / 下载 zip、登录上报与封禁、关于与检查更新。
> 仍待实现：PDF 导入（需 pdfium）、矢量画板、随身答画板、一键订正、领创、本地分享。

### 校验结果

- `flutter analyze`：0 error / 0 warning
- `flutter test`：3 项通过（AES key 长度、加解密往返、JSON 解密）
- 用旧项目的 CryptoJS 生成基准密文比对：key `E0wKU!Qg3}UkbW+:`、`parentid=0&isNoteNode=true` → `b68aCdJCMI0gqsOMagyohiWtKgbMAcgYWVNd4rr97iw=`，与 Dart 实现**逐字节一致**
- Windows 构建被系统「开发者模式」未开启阻塞（插件需要符号链接），需手动 `start ms-settings:developers` 开启后重试

