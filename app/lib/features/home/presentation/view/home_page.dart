import 'dart:async';

import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/view/home_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The home screen's entry point: gets a `HomeCubit` from [createCubit],
/// asks whether there is a saved game to continue, and hands the cubit to
/// [HomeView].
class HomePage extends StatelessWidget {
  const HomePage({required this.createCubit, super.key});

  /// Builds the screen's cubit. The composition root wires it to the
  /// device's storage; tests wire it to memory.
  final HomeCubit Function() createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = createCubit();
        unawaited(cubit.refresh());
        return cubit;
      },
      child: const HomeView(),
    );
  }
}
