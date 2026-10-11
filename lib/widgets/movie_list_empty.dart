import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MovieListEmpty extends StatelessWidget {
  final String message;

  const MovieListEmpty({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}
