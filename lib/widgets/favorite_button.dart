import 'package:flutter/material.dart';
import '../data/favorites_store.dart';
import '../data/firestore_helpers.dart';

class FavoriteButton extends StatelessWidget {
  final String placeName;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  const FavoriteButton({
    super.key,
    required this.placeName,
    this.color,
    this.size,
    this.padding,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoritesStore.favorites,
      builder: (context, favorites, child) {
        final isFavorite = favorites.contains(placeIdFor(placeName));
        return IconButton(
          padding: padding,
          constraints: constraints,
          onPressed: () => FavoritesStore.toggle(placeName),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : color,
            size: size,
          ),
        );
      },
    );
  }
}
