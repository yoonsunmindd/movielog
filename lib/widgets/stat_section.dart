import 'package:flutter/material.dart';
import '../models/profile_stat.dart';
import 'stat_item.dart';

class StatSection extends StatelessWidget {
  const StatSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ProfileStat(label: '본 영화', value: '342'),
      ProfileStat(label: '평점', value: '4.2'),
      ProfileStat(label: '즐겨찾기', value: '58'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stats
            .asMap()
            .entries
            .map(
              (entry) {
                int index = entry.key;
                ProfileStat stat = entry.value;
                return Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: StatItem(
                        label: stat.label,
                        value: stat.value,
                      ),
                    ),
                    if (index < stats.length - 1) const SizedBox(width: 16),
                  ],
                );
              },
            )
            .toList(),
      ),
    );
  }
}