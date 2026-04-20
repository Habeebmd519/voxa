import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/core/presence/online_status_cubit.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    context.read<OnlineStatusCubit>().setOnline(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<OnlineStatusCubit>().setOnline(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<OnlineStatusCubit>().setOnline(true);
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<OnlineStatusCubit>().setOnline(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
