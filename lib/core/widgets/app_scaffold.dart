import 'package:flutter/material.dart';

import 'app_loading_indicator.dart';

/// Consistent scaffold wrapper for feature screens.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
    this.leading,
    this.showAppBar = true,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.isLoading = false,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
  });

  final String? title;
  final String? subtitle;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showAppBar;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final bool isLoading;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    )
                  : null,
              actions: actions,
              leading: leading,
              centerTitle: centerTitle,
              automaticallyImplyLeading: automaticallyImplyLeading,
              surfaceTintColor: Colors.transparent,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
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
