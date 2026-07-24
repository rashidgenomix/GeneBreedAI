import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'router.dart';
import 'state/game_provider.dart';
import 'state/notebook_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GeneBreedApp());
}

class GeneBreedApp extends StatefulWidget {
  const GeneBreedApp({super.key});

  @override
  State<GeneBreedApp> createState() => _GeneBreedAppState();
}

class _GeneBreedAppState extends State<GeneBreedApp> {
  late final GameProvider _gameProvider;
  late final NotebookProvider _notebookProvider;

  @override
  void initState() {
    super.initState();
    _gameProvider = GameProvider()..load();
    _notebookProvider = NotebookProvider()..load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _gameProvider),
        ChangeNotifierProvider.value(value: _notebookProvider),
      ],
      child: Consumer<GameProvider>(
        builder: (context, game, _) {
          return MaterialApp.router(
            title: 'GeneBreed AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: game.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
