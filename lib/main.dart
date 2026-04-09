import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voxa/feature/auth/presentation/blocs/buttonAnm_bloc/button_bloc.dart';
import 'package:voxa/feature/auth/presentation/blocs/checkBoxBoc/check_bloc.dart';
import 'package:voxa/core/presence/app_life_cicle_handler.dart';
import 'package:voxa/core/presence/online_status_cubit.dart';

import 'package:voxa/feature/auth/presentation/cubits/premuim_button_cubit/premium_button_cubit.dart';
import 'package:voxa/feature/chat/Repositories/chat_repository/chat_repository.dart';
import 'package:voxa/feature/chat/chat_cubit/chat_cubit.dart';
import 'package:voxa/feature/profile/screens/cubit/edit_cubit.dart';
import 'package:voxa/feature/search_from_firebase/bloc/searchCubit.dart';

import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/profile_cubit/profile_cubit.dart';

import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/feature/user/bloc/UserCubit.dart';
import 'package:voxa/feature/user/service/UserRepository.dart';
import 'package:voxa/firebase_options.dart';

import 'package:voxa/feature/auth/presentation/screens/screen_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: 'https://jdzcmcyydsxfbycxxqgp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpkemNtY3l5ZHN4ZmJ5Y3h4cWdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5OTc3ODksImV4cCI6MjA4ODU3Mzc4OX0.0YRdi-zPbhoYiQXnJIGSU9WMa4JmPiJewReRFIQ_Evw',
  );
  OneSignal.initialize("887ea13a-f0ef-41f5-96bd-6cb3eb1a3988");
  OneSignal.Notifications.requestPermission(true);

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
        BlocProvider(create: (_) => EditCubit()),
        BlocProvider(
          create: (_) => UserCubit(
            UserRepository(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
            ),
          )..listenUsers(),
        ),
        BlocProvider(create: (_) => SheetCubit()),
        BlocProvider(create: (_) => ProfileCubit()..loadProfile()),
        BlocProvider(create: (_) => ChatsheetmanageCubit()),
        BlocProvider(create: (_) => OnlineStatusCubit()),
        BlocProvider(
          create: (context) {
            final firestoreInstance = FirebaseFirestore.instance;
            return ChatCubitt(
              // Ensure the repository gets the instance too
              repository: ChatRepository(firestore: firestoreInstance),
              firestore:
                  firestoreInstance, // Fixed the typo 'Firestor' -> 'Firestore'
            );
          },
        ),
        BlocProvider(create: (_) => SearchCubit()),
      ],
      child: MaterialApp(
        theme: ThemeData(textTheme: GoogleFonts.montserratTextTheme()),
        debugShowCheckedModeBanner: false,
        home: AppLifecycleHandler(child: AnimatedLoginScreen()),
      ),
    );
  }
}
