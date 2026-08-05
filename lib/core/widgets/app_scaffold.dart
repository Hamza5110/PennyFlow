import 'package:flutter/material.dart';

import 'app_loading_indicator.dart';

/// Consistent scaffold wrapper for feature screens.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
    this.leading,
    this.showAppBar = true,
    this.isLoading = false,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
  });

  final String? title;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showAppBar;
  final bool isLoading;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              actions: actions,
              leading: leading,
            )
          : null,
      body: Stack(
        children: [
          if (body != null) Positioned.fill(child: body!),
          if (isLoading)
            const ColoredBox(
              color: Color(0x66000000),
              child: AppLoadingIndicator(),
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
    );
  }
}
