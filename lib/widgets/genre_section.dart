import 'package:flutter/material.dart';

class GenreSection extends StatelessWidget {
  const GenreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = ['드라마', 'SF', '애니메이션'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선호하는 장르',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: genres
              .asMap()
              .entries
              .map(
                (entry) {
                  int index = entry.key;
                  String genre = entry.value;
                  return Row(
                    children: [
                      Chip(
                        label: Text(genre),
                        backgroundColor: const Color(0xFFE8DEF8),
                      ),
                      if (index < genres.length - 1) const SizedBox(width: 8),
                    ],
                  );
                },
              )
              .toList(),
        ),
      ],
    );
  }
}