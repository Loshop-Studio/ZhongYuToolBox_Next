import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/storage/session_manager.dart';
import 'features/about/about_page.dart';
import 'features/assessment/assessment_page.dart';
import 'features/assessment/exam_detail_page.dart';
import 'features/assessment/mistake_pages.dart';
import 'features/assessment/question_page.dart';
import 'features/auth/add_account_page.dart';
import 'features/auth/login_page.dart';
import 'features/dev/develop_page.dart';
import 'features/download/app_downloads_page.dart';
import 'features/home/home_page.dart';
import 'features/home/announcement_detail_page.dart';
import 'features/home/message_center_page.dart';
import 'features/home/screenshot_assistant/screenshot_assistant_page.dart';
import 'features/linspirer/linspirer_page.dart';
import 'features/qa/qa_detail_page.dart';
import 'features/qa/qa_page.dart';
import 'features/resources/pdf_import_page.dart';
import 'features/resources/note_detail_page.dart';
import 'features/resources/resources_page.dart';
import 'features/settings/settings_page.dart';
import 'features/shell/app_shell.dart';
import 'features/study/article_page.dart';
import 'features/study/article_comments_page.dart';
import 'features/study/audio_player_page.dart';
import 'features/study/column_pages_page.dart';
import 'features/study/course_choosing_page.dart';
import 'features/study/favorite_pages_page.dart';
import 'features/study/lesson_pages.dart';
import 'features/study/lesson_viewer_page.dart';
import 'features/study/lesson_web_page.dart';
import 'features/study/video_player_page.dart';
import 'features/study/pdf_viewer_page.dart';
import 'features/study/study_page.dart';
import 'features/study/web_viewer_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

int _intParam(String? value) => int.tryParse(value ?? '') ?? 0;

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  refreshListenable: SessionManager.instance,
  redirect: (context, state) {
    final loggedIn = SessionManager.instance.isLoggedIn;
    final path = state.matchedLocation;
    // 登录页同时是「切换账号」入口，登录态下也要能进入
    final isAuthRoute = path == '/login' || path.startsWith('/add-account');
    if (!loggedIn && !isAuthRoute) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/', redirect: (_, __) => '/home'),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(
      path: '/add-account',
      builder: (_, __) => const AddAccountSchoolPage(),
    ),
    GoRoute(
      path: '/add-account/credential',
      builder: (_, state) => AddAccountCredentialPage(
        schoolCode: state.uri.queryParameters['code'] ?? '',
        schoolName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/resources',
              builder: (_, state) => ResourcesPage(
                initialTab: state.uri.queryParameters['tab'] == 'gallery'
                    ? 1
                    : 0,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/assessment',
              builder: (_, __) => const AssessmentPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/study', builder: (_, __) => const StudyPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/qa', builder: (_, __) => const QaPage())],
        ),
      ],
    ),
    GoRoute(
      path: '/note/:fileId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => NoteDetailPage(
        fileId: state.pathParameters['fileId'] ?? '',
        fileName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/pdf-import',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => PdfImportPage(
        parentId: state.uri.queryParameters['parentId'] ?? '0',
        parentName: state.uri.queryParameters['name'] ?? '根目录',
      ),
    ),
    GoRoute(
      path: '/note-search',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const NoteSearchPage(),
    ),
    GoRoute(
      path: '/note-recycle',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const NoteRecyclePage(),
    ),
    GoRoute(
      path: '/exam/:taskId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => ExamDetailPage(
        taskId: _intParam(state.pathParameters['taskId']),
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/question/:qstId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => QuestionPage(
        qstId: _intParam(state.pathParameters['qstId']),
        index: _intParam(state.uri.queryParameters['index']),
      ),
    ),
    GoRoute(
      path: '/mistake/item/:itemId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) =>
          MistakeDetailPage(itemId: state.pathParameters['itemId'] ?? ''),
    ),
    GoRoute(
      path: '/mistake',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const MistakeBooksPage(),
    ),
    GoRoute(
      path: '/mistake/:bookId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => MistakeItemsPage(
        bookId: state.pathParameters['bookId'] ?? '',
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/favorites/:catalogId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => FavoritePagesPage(
        catalogId: _intParam(state.pathParameters['catalogId']),
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/column/:colId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => ColumnPagesPage(
        colId: _intParam(state.pathParameters['colId']),
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/article/:pageId/comments',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => ArticleCommentsPage(
        pageId: _intParam(state.pathParameters['pageId']),
      ),
    ),
    GoRoute(
      path: '/article/:pageId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) =>
          ArticlePage(pageId: _intParam(state.pathParameters['pageId'])),
    ),
    GoRoute(
      path: '/messages',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const MessageCenterPage(),
    ),
    GoRoute(
      path: '/announcement',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => AnnouncementDetailPage(
        noticeId: _intParam(state.uri.queryParameters['noticeId']),
        messageId: state.uri.queryParameters['messageId'] ?? '',
        title: state.uri.queryParameters['title'] ?? '',
      ),
    ),
    GoRoute(
      path: '/lesson/viewer',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => LessonViewerPage(
        kind: state.uri.queryParameters['kind'] ?? 'file',
        url: state.uri.queryParameters['url'] ?? '',
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/course',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const CourseChoosingPage(),
    ),
    GoRoute(
      path: '/file/pdf',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => PdfViewerPage(
        url: state.uri.queryParameters['url'] ?? '',
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/file/web',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => WebViewerPage(
        url: state.uri.queryParameters['url'] ?? '',
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/linspirer',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const LinspirerPage(),
    ),
    GoRoute(
      path: '/lesson',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const LessonCoursesPage(),
    ),
    GoRoute(
      path: '/lesson/video',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => VideoPlayerPage(
        url: state.uri.queryParameters['url'] ?? '',
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/lesson/audio',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => AudioPlayerPage(
        url: state.uri.queryParameters['url'] ?? '',
        name: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/lesson/:courseId/:catalogId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => LessonWebPage(
        courseId: _intParam(state.pathParameters['courseId']),
        catalogId: state.pathParameters['catalogId'] ?? '',
        title: state.uri.queryParameters['title'] ?? '',
      ),
    ),
    GoRoute(
      path: '/lesson/:courseId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => LessonCatalogPage(
        courseId: _intParam(state.pathParameters['courseId']),
        title: state.uri.queryParameters['title'] ?? '',
      ),
    ),
    GoRoute(
      path: '/qa/:sessionId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => QaDetailPage(
        sessionId: state.pathParameters['sessionId'] ?? '',
        askUserPhoto: state.uri.queryParameters['askUserPhoto'] ?? '',
      ),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const SettingsPage(),
    ),
    GoRoute(
      path: '/downloads',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const AppDownloadsPage(),
    ),
    GoRoute(
      path: '/screenshot-assistant',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const ScreenshotAssistantPage(),
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const AboutPage(),
    ),
    GoRoute(
      path: '/dev',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, __) => const DevelopPage(),
    ),
  ],
);
