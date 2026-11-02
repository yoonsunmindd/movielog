import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// TMDB 포스터 이미지. posterPath가 없거나 로드에 실패하면 placeholder를 보여준다.
class TmdbPosterImage extends StatelessWidget {
  static const String _baseUrl = 'https://image.tmdb.org/t/p/w500';

  final String? posterPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const TmdbPosterImage({
    super.key,
    required this.posterPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final path = posterPath;
    if (path == null || path.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      '$_baseUrl$path',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, color: AppColors.textTertiary),
    );
  }
}
