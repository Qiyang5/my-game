import 'package:flutter/material.dart';
import 'package:my_game/app/app_shell.dart';

class WorkstationSurvivalApp extends StatelessWidget {
  const WorkstationSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '工位求生',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BFF)),
        scaffoldBackgroundColor: const Color(0xFFF6F3FF),
      ),
      home: const AppShell(),
    );
  }
}
