import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voxa/blocs/buttonAnm_bloc/button_bloc.dart';
import 'package:voxa/blocs/checkBoxBoc/check_bloc.dart';
import 'package:voxa/cubit/premuim_button_cubit/premium_button_cubit.dart';
// import 'package:voxa/feature/task/global_serch/cubit/search_toggle_cubit.dart';
// import 'package:voxa/feature/task/local_search/cubit/search_togle_cubit.dart';
// import 'package:voxa/feature/task/top_toggle_system/bloc/bloc.dart';

import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/firebase_options.dart';
// import 'package:voxa/screens/screen_home.dart';
import 'package:voxa/screens/screen_login.dart';

// import 'package:voxa/screens/test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ButtonBloc>(create: (_) => ButtonBloc()),
        BlocProvider(create: (_) => TermsBloc()),
        BlocProvider(create: (_) => PremiumButtonCubit()),
        BlocProvider(create: (_) => TopBarCubit()),
      ],
      child: MaterialApp(
        theme: ThemeData(textTheme: GoogleFonts.montserratTextTheme()),
        debugShowCheckedModeBanner: false,
        home: AnimatedLoginScreen(),
      ),
    );
  }
}
