import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final themeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system; // follow system by default
});

void toggleTheme(WidgetRef ref) {
  final current = ref.read(themeProvider);
  ref.read(themeProvider.notifier).state =
      current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}
