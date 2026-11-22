import 'package:flutter/material.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../theme/app_colors.dart';

/// 영화 목록 화면 상단의 장르 단일 선택 Chip 행. "전체" + Genre API 이름들.
/// enabled가 false면(로딩 중) Chip을 눌러도 선택이 안 바뀐다.
class MovieGenreChipRow extends StatelessWidget {
  final List<TmdbGenreDto> genres;
  final int? selectedGenreId;
  final bool enabled;
  final ValueChanged<int?> onSelected;

  const MovieGenreChipRow({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip(
              label: '전체',
              selected: selectedGenreId == null,
              onTap: () => onSelected(null),
            );
          }
          final genre = genres[index - 1];
          return _buildChip(
            label: genre.name,
            selected: selectedGenreId == genre.id,
            onTap: () => onSelected(genre.id),
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onTap() : null,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      shape: const StadiumBorder(),
    );
  }
}
