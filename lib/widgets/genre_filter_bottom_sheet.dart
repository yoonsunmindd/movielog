import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 장르 다중 선택 BottomSheet. 핸들을 드래그해 높이를 조절할 수 있고,
/// 체크박스 목록만 스크롤되며 "확인" 버튼은 하단에 고정된다.
/// 선택 결과는 "확인"을 눌렀을 때만 반환되고, 그 전까지는 시트 내부
/// 임시 상태로만 존재한다 (취소/드래그로 닫으면 null 반환, 반영 안 됨).
Future<Set<String>?> showGenreFilterBottomSheet(
  BuildContext context, {
  required List<String> genres,
  required Set<String> initialSelected,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _GenreFilterSheetContent(
      genres: genres,
      initialSelected: initialSelected,
    ),
  );
}

class _GenreFilterSheetContent extends StatefulWidget {
  final List<String> genres;
  final Set<String> initialSelected;

  const _GenreFilterSheetContent({
    required this.genres,
    required this.initialSelected,
  });

  @override
  State<_GenreFilterSheetContent> createState() =>
      _GenreFilterSheetContentState();
}

class _GenreFilterSheetContentState extends State<_GenreFilterSheetContent> {
  late final Set<String> _tempSelected = {...widget.initialSelected};
  double _heightFactor = 0.6;

  static const double _minHeightFactor = 0.35;
  static const double _maxHeightFactor = 0.9;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * _heightFactor,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              setState(() {
                _heightFactor -= details.delta.dy / screenHeight;
                _heightFactor = _heightFactor.clamp(
                  _minHeightFactor,
                  _maxHeightFactor,
                );
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: _DragHandle(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '장르 선택',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => setState(() => _tempSelected.clear()),
                  child: const Text('초기화'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final genre in widget.genres)
                  CheckboxListTile(
                    title: Text(genre),
                    value: _tempSelected.contains(genre),
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      setState(() {
                        if (checked ?? false) {
                          _tempSelected.add(genre);
                        } else {
                          _tempSelected.remove(genre);
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_tempSelected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _tempSelected.isEmpty
                      ? '전체보기'
                      : '확인 (${_tempSelected.length})',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
