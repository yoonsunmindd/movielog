import 'package:flutter/material.dart';
import '../data/models/rating_request.dart';
import '../theme/app_colors.dart';
import 'movie_rating_input.dart';
import 'movielog_button.dart';

/// 평점 등록/수정 Dialog. 성공하면 true, 취소하면 false를 반환한다.
/// 취소 시에는 onSubmit을 호출하지 않는다.
class RatingDialog extends StatefulWidget {
  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  const RatingDialog({
    super.key,
    this.initialScore = 0,
    this.initialComment,
    required this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _score = widget.initialScore.toDouble();
  late final TextEditingController _commentController = TextEditingController(
    text: widget.initialComment ?? '',
  );

  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_score <= 0 || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final score = validateServerScore(_score);
      final comment = _commentController.text.trim();
      await widget.onSubmit(score, comment.isEmpty ? null : comment);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = '평점을 저장하지 못했어요. 다시 시도해 주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text('평점을 남겨주세요', style: textTheme.titleMedium),
              ),
              const SizedBox(height: 20),
              Center(
                child: MovieRatingInput(
                  rating: _score,
                  enabled: !_isSubmitting,
                  onRatingUpdate: (value) => setState(() => _score = value),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '코멘트 (선택, 최대 500자)',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                enabled: !_isSubmitting,
                maxLength: 500,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '이 영화의 인상적인 장면은...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 4),
                Text(
                  _errorText!,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      isSecondary: true,
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MovieLogButton(
                      label: '확인',
                      isLoading: _isSubmitting,
                      onPressed: _score > 0 ? _handleConfirm : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
