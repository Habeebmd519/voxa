import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voxa/blocs/buttonAnm_bloc/button_bloc.dart';
import 'package:voxa/blocs/checkBoxBoc/check_bloc.dart';
import 'package:voxa/core/presence/app_life_cicle_handler.dart';
import 'package:voxa/core/presence/online_status_cubit.dart';
import 'package:voxa/core/services/notification_service.dart';
import 'package:voxa/cubit/premuim_button_cubit/premium_button_cubit.dart';
import 'package:voxa/feature/chat/Repositories/chat_repository/chat_repository.dart';
import 'package:voxa/feature/chat/chat_cubit/chat_cubit.dart';

import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/profile_cubit/profile_cubit.dart';
// import 'package:voxa/feature/task/global_serch/cubit/search_toggle_cubit.dart';
// import 'package:voxa/feature/task/local_search/cubit/search_togle_cubit.dart';
// import 'package:voxa/feature/task/top_toggle_system/bloc/bloc.dart';

import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/feature/task/user/bloc/UserCubit.dart';
import 'package:voxa/feature/task/user/service/UserRepository.dart';
import 'package:voxa/firebase_options.dart';
// import 'package:voxa/screens/main_screen.dart';
// import 'package:voxa/screens/screen_home.dart';
import 'package:voxa/screens/screen_login.dart';

// import 'package:voxa/screens/test.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: 'https://jdzcmcyydsxfbycxxqgp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpkemNtY3l5ZHN4ZmJ5Y3h4cWdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5OTc3ODksImV4cCI6MjA4ODU3Mzc4OX0.0YRdi-zPbhoYiQXnJIGSU9WMa4JmPiJewReRFIQ_Evw',
  );
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ButtonBloc>(create: (_) => ButtonBloc()),
        BlocProvider(create: (_) => TermsBloc()),
        BlocProvider(create: (_) => PremiumButtonCubit()),
        BlocProvider(create: (_) => TopBarCubit()),
        BlocProvider(
          create: (_) => UserCubit(
            UserRepository(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
            ),
          )..loadUsers(),
        ),
        BlocProvider(create: (_) => SheetCubit()),
        BlocProvider(create: (_) => ProfileCubit()..loadProfile()),
        BlocProvider(create: (_) => ChatsheetmanageCubit()),
        BlocProvider(create: (_) => OnlineStatusCubit()),
        BlocProvider(
          create: (_) =>
              ChatCubitt(ChatRepository(firestore: FirebaseFirestore.instance)),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(textTheme: GoogleFonts.montserratTextTheme()),
        debugShowCheckedModeBanner: false,
        home: AppLifecycleHandler(child: AnimatedLoginScreen()),
      ),
    );
  }
}


  // leading: CircleAvatar(
  //                               backgroundColor: const Color(0xFFAFDA6F),
  //                               child: Text(chat.name[0]),
  //                             ),