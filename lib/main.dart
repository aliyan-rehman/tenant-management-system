import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_mgmt_sys/providers/auth_provider.dart';
import 'package:tenant_mgmt_sys/providers/bills_provider.dart';
import 'package:tenant_mgmt_sys/providers/tenant_provider.dart';
import 'package:tenant_mgmt_sys/screens/auth/login_screen.dart';
import 'package:tenant_mgmt_sys/screens/tenants/all_tenants.dart';
import 'core/theme/app_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //for firebase integeration
  await Firebase.initializeApp(); //for firebase integeration
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(),),
      ChangeNotifierProvider(create: (_) => BillProvider(),),
      ChangeNotifierProvider(create: (_) => TenantProvider(),),
    ],
    child: MyApp(),)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tenant Management System',
      theme: AppTheme.lightTheme,
      // theme: ThemeData(
      //   fontFamily: "Inter"
      // ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void dispose() {
    super.dispose();

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask((){
      context.read<AuthProvider>().initialize();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking login state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If logged in, show main screen
        if (authProvider.isLoggedIn) {
          return const AllTenants();
        }

        // If not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}
