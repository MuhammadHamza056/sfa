import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';

/// Prompts for a new wishlist name.
///
/// Returns the trimmed name, or null when the user cancels or submits an
/// empty field. Shared by the wishlists tab's "Add Wishlist" button and the
/// "Create new wishlist" row inside [SaveToWishlistSheet] so both spell the
/// dialog the same way.
Future<String?> promptWishlistName(BuildContext context) async {
  final loc = AppLocalizations.of(context);
  final controller = TextEditingController();
  try {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('addWishlist')),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => context.pop(value.trim()),
          decoration: InputDecoration(
            hintText: loc.translate('wishlistNameHint'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () => context.pop(controller.text.trim()),
            child: Text(loc.translate('addWishlist')),
          ),
        ],
      ),
    );
    return (title == null || title.isEmpty) ? null : title;
  } finally {
    controller.dispose();
  }
}
