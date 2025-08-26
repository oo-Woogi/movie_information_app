# Movie Information App

TMDB(The Movie Database) API를 사용해 영화 정보를 보여주는 Flutter 앱입니다. 
다크 테마 전용 UI, 홈/상세 화면, Hero 애니메이션, Riverpod 상태관리, Dio 네트워킹, `.env` 기반 시크릿 관리로 구성되어 있습니다.

## 주요 기능
- **HomePage**
  - 가장 인기있는(히어로) 포스터(가로 패딩 총 20)
  - 가로 리스트뷰 4개: `현재 상영중`, `인기순(랭킹 숫자 오버레이)`, `평점 높은순`, `개봉예정`
  - 각 섹션 20개 아이템, 카드 높이 180
  - 카드 탭 → **DetailPage**로 전환 (**Hero** 애니메이션)
- **DetailPage**
  - 상단 포스터 Hero 전환
  - 제목, 태그라인, 개봉일, 러닝타임, 평점 등 **흥행정보**
  - **제작사 로고** 가로 리스트(배경 흰색, 투명도 0.9)

## 아키텍처
**Clean Architecture + Riverpod**

```
lib/
├─ core/                     # 공통(상수/환경/클라이언트)
│  ├─ constants.dart
│  ├─ env/app_env.dart
│  └─ tmdb_client.dart
├─ data/                     # 외부 데이터 ↔ DTO ↔ Repository 구현
│  ├─ dto/
│  │  ├─ movie_response_dto.dart
│  │  └─ movie_detail_dto.dart
│  ├─ datasource/
│  │  ├─ movie_data_source.dart
│  │  └─ tmdb_movie_data_source.dart
│  └─ repositories/
│     └─ movie_repository_impl.dart
├─ domain/                   # 앱 내부에서 사용할 엔티티/추상 레포
│  ├─ entities/
│  │  ├─ movie.dart
│  │  └─ movie_detail.dart
│  └─ repositories/
│     └─ movie_repository.dart
├─ application/              # Provider(상태/의존성)
│  └─ providers/
│     ├─ app_providers.dart
│     └─ movie_providers.dart
├─ home_page.dart            # 홈 화면(UI)
└─ detail_page.dart          # 상세 화면(UI)
```

## 환경 변수(.env)
TMDB **v4 Read Access Token**을 사용합니다. (v3 `api_key` 아님)

1) 프로젝트 루트에 `.env` 생성
```env
TMDB_BEARER=YOUR_V4_READ_TOKEN
```
2) `pubspec.yaml`에 자산 등록
```yaml
flutter:
  assets:
    - .env
```
3) 앱 시작 시 로드
```dart
await dotenv.load(fileName: '.env');
```
4) 깃에 올리지 않기 (`.gitignore`)
```gitignore
.env
.env.*
!.env.example
```
원격 공유용으로는 `.env.example`만 커밋하세요.

## 네트워킹
- Base URL: `https://api.themoviedb.org/3`
- 공통 쿼리: `language=ko-KR`
- 사용 엔드포인트
  - `/movie/now_playing`
  - `/movie/popular`
  - `/movie/top_rated`
  - `/movie/upcoming`
  - `/movie/{id}` (상세)
- 이미지: `https://image.tmdb.org/t/p/w500{poster_path}`

## 핵심 의존성
- `flutter_riverpod` – DI/상태관리
- `dio` – HTTP 클라이언트
- `flutter_dotenv` – 환경 변수 로드

## 실행 방법
```bash
flutter pub get
flutter run
```

## Hero 태그 규칙
- 히어로 메인: `hero_main_<id>`
- 리스트 아이템: `poster_<section>_<id>` (예: `poster_popular_123`)
- **한 화면 내 태그는 유일**해야 하며, 상세에서도 **동일 태그**를 사용해야 애니메이션이 동작합니다.

## 트러블슈팅(요약)
- **401 Unauthorized**: v4 토큰 확인, `.env` 로드 및 `assets` 등록 여부 점검
- **Hero 무반응**: `Navigator.push` 사용 여부, 원본/대상 **동일 tag & 동일 모양(Clip/Radius)** 확인
- **Duplicate Hero tag**: 섹션 프리픽스 포함 등으로 태그 유일성 보장
- **import 오류**: 패키지 경로(`package:movie_information_app/...`)로 통일