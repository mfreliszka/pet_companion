import 'package:flutter/material.dart';

/// Standard app scaffold wrapper with AppBar and optional drawer.
///
/// Used as the base layout for authenticated screens.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.drawer,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
  });

  final Widget body;
  final String title;
  final Widget? drawer;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? const BackButton()
            : drawer != null
            ? null // Drawer icon is automatically added
            : null,
        actions: actions,
      ),
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
