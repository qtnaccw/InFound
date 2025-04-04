import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infound/firebase_options.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/repos/notification_service.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((value) {
    Get.put(NetworkManager(), permanent: true);
    Get.put(DatabaseRepository(), permanent: true);
    Get.put(AuthenticationRepository(), permanent: true);
  });
  setPathUrlStrategy();
  runApp(
    ChangeNotifierProvider(
      create: (context) => NotificationService()..listenForNotifications(),
      child: InFound(),
    ),
  );
}

class InFound extends StatelessWidget {
  const InFound({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'InFound',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppStyles.primaryTeal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      getPages: AppRoutes.pages,
      initialRoute: AppRoutes.home,
      unknownRoute: AppRoutes.unknownPage,
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration(milliseconds: 300),
    );
  }
}
