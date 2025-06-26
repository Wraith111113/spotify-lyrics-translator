# Spotify 가사 번역기 (Flutter)

Spotify에서 현재 재생 중인 곡의 가사를 실시간으로 검색하고 한국어로 번역하여 표시하는 Flutter 앱입니다.

## 🚀 주요 기능

- **실시간 곡 감지**: Spotify에서 현재 재생 중인 곡을 자동으로 감지
- **가사 검색**: Genius API를 통한 정확한 가사 검색
- **실시간 번역**: Google Translate API를 통한 한국어 번역
- **오버레이 표시**: 다른 앱 위에 가사를 표시하는 오버레이 기능
- **효율적인 API 사용**: 곡 변경 시에만 가사 검색 및 번역 수행
- **강화된 오류 처리**: 다양한 예외 상황에 대한 안정적인 처리

## 🛠️ 기술 스택

- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **BLoC Pattern**: 상태 관리
- **Spotify Web API**: 현재 재생 중인 곡 정보 가져오기
- **Google Translate API**: 안정적인 번역 서비스
- **Genius API**: 가사 검색 (선택사항)

## 📋 설치 및 설정

### 1. 프로젝트 클론
```bash
git clone https://github.com/your-username/spotify-lyrics-translator.git
cd spotify-lyrics-translator
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가하세요:

```env
# Spotify API 설정
SPOTIFY_CLIENT_ID=your_spotify_client_id_here
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret_here

# Google Translate API 설정
GOOGLE_TRANSLATE_API_KEY=your_google_translate_api_key_here

# Genius API 설정 (선택사항)
GENIUS_ACCESS_TOKEN=your_genius_access_token_here
```

### 4. API 키 설정

#### Spotify API
1. [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)에 접속
2. 새 앱 생성
3. Client ID와 Client Secret 복사
4. Redirect URI 설정: `http://localhost:8888/callback`

#### Google Translate API
1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. Translation API 활성화
4. API 키 생성
5. API 키 제한 설정 (Translation API만 허용 권장)

#### Genius API (선택사항)
1. [Genius API Clients](https://genius.com/api-clients)에 접속
2. 새 앱 생성
3. 액세스 토큰 복사

### 5. 앱 실행
```bash
flutter run
```

## 🎯 주요 개선사항

### 1. 안정적인 번역 서비스
- **기존 문제**: `googletrans` 라이브러리의 불안정성
- **개선사항**: Google Translate API 사용으로 안정성 향상
- **효과**: 번역 실패율 대폭 감소

### 2. 효율적인 API 사용
- **기존 문제**: 같은 곡에 대해 반복적인 API 호출
- **개선사항**: 곡 ID 기반 중복 요청 방지
- **효과**: API 사용량 절약 및 응답 속도 향상

### 3. 강화된 오류 처리
- **기존 문제**: 예외 상황에서 앱 크래시
- **개선사항**: 다양한 예외 상황에 대한 처리
- **효과**: 안정적인 앱 동작

### 4. 사용자 경험 개선
- **현재 곡 정보 표시**: 앨범 아트, 제목, 아티스트 정보
- **재생 상태 표시**: 재생/일시정지 상태 표시
- **로딩 상태 개선**: 명확한 로딩 메시지
- **오류 복구**: 재시도 버튼 제공

## 📱 사용법

1. Spotify 앱에서 음악 재생
2. Flutter 앱 실행
3. 앱이 자동으로 현재 재생 중인 곡을 감지
4. 가사 검색 및 번역 수행
5. 원본 가사와 한국어 번역을 함께 표시

## 🔧 개발 환경

- Flutter SDK: >=3.2.6
- Dart SDK: >=3.2.6
- Android: API 21+
- iOS: 11.0+

## 📁 프로젝트 구조

```
lib/
├── data/
│   ├── repositories/     # 데이터 레이어
│   └── services/        # API 서비스
├── domain/
│   ├── entities/        # 도메인 엔티티
│   ├── repositories/    # 리포지토리 인터페이스
│   └── usecases/       # 비즈니스 로직
└── presentation/
    ├── bloc/           # 상태 관리
    ├── screens/        # 화면
    └── widgets/        # 재사용 가능한 위젯
```

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## ⚠️ 주의사항

- Spotify API 사용량 제한이 있을 수 있습니다
- Google Translate API는 유료 서비스입니다 (월 500,000자 무료)
- Genius API는 선택사항이며, 가사가 없는 곡도 있을 수 있습니다

## 🐛 알려진 문제

- Android에서 오버레이 권한이 필요할 수 있습니다
- iOS에서는 백그라운드 실행 제한이 있을 수 있습니다

## 📞 지원

문제가 발생하거나 질문이 있으시면 [Issues](https://github.com/your-username/spotify-lyrics-translator/issues)를 통해 문의해주세요.
