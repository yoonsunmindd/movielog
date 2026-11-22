class Movie {
  final String id;
  final String title;
  final String genre;
  final List<String> tags;
  final int year;
  final int runtimeMinutes;
  final double rating;
  final int reviewCount;
  final String posterAsset;
  final String synopsis;
  final bool isFeatured;

  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.tags,
    required this.year,
    required this.runtimeMinutes,
    required this.rating,
    required this.reviewCount,
    required this.posterAsset,
    required this.synopsis,
    this.isFeatured = false,
  });
}

const List<Movie> mockMovies = [
  Movie(
    id: 'under-the-starlight',
    title: '별빛 아래 우리',
    genre: '드라마',
    tags: ['로맨스', '드라마', '감동적인'],
    year: 2024,
    runtimeMinutes: 124,
    rating: 4.5,
    reviewCount: 1245,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    isFeatured: true,
    synopsis:
        '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. '
        '매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.\n\n'
        '과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 '
        '남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 '
        '시험하게 되는데...\n\n'
        '별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 영상미와 감성적인 '
        'OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.\n\n'
        '잔잔한 감동과 함께 삶의 의미를 다시 한번 되돌아보게 만드는 수작입니다.',
  ),
  Movie(
    id: 'echoes-of-the-void',
    title: '우주의 끝에서',
    genre: 'SF',
    tags: ['SF', '모험', '우주'],
    year: 2024,
    runtimeMinutes: 138,
    rating: 4.2,
    reviewCount: 892,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    synopsis:
        '통신이 끊긴 심우주 탐사선에 홀로 남겨진 항해사가 미지의 신호를 쫓아 우주의 끝까지 나아가는 이야기입니다. '
        '광활한 우주를 배경으로 한 압도적인 영상미와 함께, 고립 속에서도 희망을 놓지 않는 인간의 의지를 그려냅니다.',
  ),
  Movie(
    id: 'memory-forest',
    title: '기억의 숲',
    genre: '애니메이션',
    tags: ['애니메이션', '판타지', '우정'],
    year: 2024,
    runtimeMinutes: 98,
    rating: 4.9,
    reviewCount: 2031,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    synopsis:
        '숲속에서 길을 잃은 소녀가 신비한 정령들을 만나며 잊고 있던 소중한 기억을 되찾아가는 따뜻한 판타지 애니메이션입니다. '
        '섬세한 그림체와 몽환적인 배경음악이 어우러져 남녀노소 모두에게 사랑받는 작품입니다.',
  ),
  Movie(
    id: 'night-shadows',
    title: '밤의 그림자',
    genre: '스릴러',
    tags: ['스릴러', '미스터리', '느와르'],
    year: 2024,
    runtimeMinutes: 112,
    rating: 3.8,
    reviewCount: 456,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    synopsis:
        '비 내리는 도심 뒷골목에서 벌어진 의문의 사건을 쫓는 형사의 이야기입니다. 진실에 다가갈수록 드러나는 '
        '도시의 어두운 이면과 반전을 거듭하는 전개가 긴장감을 늦추지 않습니다.',
  ),
  Movie(
    id: 'abyss-walker',
    title: '어비스 워커',
    genre: 'SF',
    tags: ['SF', '액션', '심해'],
    year: 2023,
    runtimeMinutes: 121,
    rating: 4.0,
    reviewCount: 673,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    synopsis:
        '심해 깊은 곳에서 발견된 미지의 구조물을 탐사하던 연구팀이 상상도 못한 존재와 마주하게 되는 SF 액션 영화입니다. '
        '압도적인 수중 비주얼과 숨 막히는 서바이벌 전개가 특징입니다.',
  ),
  Movie(
    id: 'fourth-afternoon',
    title: '네 번째 오후',
    genre: '드라마',
    tags: ['드라마', '가족', '성장'],
    year: 2023,
    runtimeMinutes: 105,
    rating: 4.3,
    reviewCount: 1024,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    synopsis:
        '같은 하루를 네 번째로 반복하게 된 한 가족의 이야기를 통해 서로에게 하지 못했던 말들을 전하는 성장 드라마입니다. '
        '평범한 일상 속 소중함을 다시 일깨워주는 잔잔한 울림을 전합니다.',
  ),
];

Movie? findMovieById(String id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}
