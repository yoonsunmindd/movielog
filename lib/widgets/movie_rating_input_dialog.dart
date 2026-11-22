import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme/app_colors.dart';

/// 평점 입력용 다이얼로그. 확인 시 선택한 별점(double)을 반환한다.
class MovieRatingInputDialog extends StatefulWidget {
  final double initialRating;

  const MovieRatingInputDialog({super.key, this.initialRating = 0});

  @override
  State<MovieRatingInputDialog> createState() =>
      _MovieRatingInputDialogState();
}

class _MovieRatingInputDialogState extends State<MovieRatingInputDialog> {
  late double _rating = widget.initialRating;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('평점을 남겨주세요'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: _rating,
            minRating: 0,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 36,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: AppColors.primary),
            onRatingUpdate: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 12),
          Text(
            _rating > 0 ? '${_rating.toStringAsFixed(1)}점' : '별을 선택해주세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _rating > 0
              ? () => Navigator.of(context).pop(_rating)
              : null,
          child: const Text('등록'),
        ),
      ],
    );
  }
}
