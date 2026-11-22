import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme/app_colors.dart';

/// 별점 입력 위젯. 서버는 정수 1~5만 받으므로 반 점은 항상 비활성화한다.
class MovieRatingInput extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingUpdate;
  final bool enabled;

  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onRatingUpdate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 36,
          itemPadding: const EdgeInsets.symmetric(horizontal: 2),
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: AppColors.primary),
          onRatingUpdate: onRatingUpdate,
        ),
      ),
    );
  }
}
