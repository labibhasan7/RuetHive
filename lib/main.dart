import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruethive/firebase_options.dart';
import 'package:ruethive/screens/sign/log%20in/login_screen.dart';
import 'widgets/app_scaffold.dart';
import 'screens/cr/cr_scaffold.dart';
import 'screens/admin/admin_scaffold.dart';
import 'core/state/role_provider.dart';
import 'core/state/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() async{
  

WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);



  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RUETHive',
      theme: AppTheme.light(role ?? UserRole.student),
      darkTheme: AppTheme.dark(role ?? UserRole.student),
      themeMode: themeMode,
      home: role == null ? const LoginScreen() : _buildHome(role),
      
    );
  }

  Widget _buildHome(UserRole role) {
    switch (role) {
      case UserRole.cr:
        return const CRScaffold();
      case UserRole.admin:
        return const AdminScaffold();
      case UserRole.student:
        return const AppScaffold();
    }
  }
}
