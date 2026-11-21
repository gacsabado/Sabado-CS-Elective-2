import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Supabase credentials from .env
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    throw StateError('Missing Supabase URL or publishable key in .env file.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(
    ProviderScope(
      // Show errors right away instead of silently retrying in the background.
      retry: (retryCount, error) => null,
      child: const PopMartApp(),
    ),
  );
}

class PopMartApp extends ConsumerWidget {
  const PopMartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'POP MART Hirono Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
