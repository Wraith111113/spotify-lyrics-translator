# 가사 번역 앱 (Lyrics Translator)

Spotify 음악의 가사를 실시간으로 보여주고 번역하는 Flutter 애플리케이션입니다.

## 프로젝트 개요

이 앱은 현재 재생 중인 음악의 가사를 PAPAGO MINI와 유사한 UI로 표시하고, 가사를 타임라인 형식으로 보여줍니다. 각 가사 줄은 해당 번역과 함께 표시됩니다.

## 기능

- 현재 재생 중인 노래 표시
- 노래 가사를 타임라인 형식으로 표시
- 가사에 대한 번역 제공
- 간결하고 직관적인 PAPAGO MINI 스타일 UI
- 타임라인 기반 가사 자동 진행

## 코드 및 구조 분석

### 1. 프로젝트 구조

- **`lib/`**: 핵심 Dart 코드 위치
  - **`main.dart`**: 앱 시작점, 앱 설정 및 테마 정의
  - **`screens/`**: UI 화면 관련 위젯
    - **`home_screen.dart`**: 메인 화면 UI 및 상태 관리
  - **`services/`**: 백엔드 로직, 데이터 처리, API 연동
    - **`dummy_service.dart`**: 데모 모드용 하드코딩 트랙 및 가사 제공
    - **`spotify_service.dart`**: (미사용) Spotify API 연동
    - **`lyrics_service.dart`**: (미사용) Musixmatch API 연동
    - **`translate_service.dart`**: (미사용) Google Translate API 연동
- **`pubspec.yaml`**: 프로젝트 의존성 및 앱 메타데이터
- **`platform folders`** (`android/`, `ios/`, `web/`, 등): 각 플랫폼별 네이티브 코드
- **`.gitignore`**: Git 관리 제외 파일 목록
- **기타 설정 파일**: `.metadata`, `analysis_options.yaml` 등

### 2. 주요 파일 분석

- **`main.dart`**
  - `MaterialApp` 설정 및 `HomeScreen`을 홈 화면으로 지정
  - 디버그 배너 비활성화

- **`screens/home_screen.dart`**
  - `StatefulWidget`으로 로딩, 에러, 초기화, 가사 변경 상태 관리
  - `DummySpotifyService` 직접 인스턴스화하여 사용
  - `StreamBuilder` 2개로 현재 트랙 및 가사/번역 스트림 수신
  - `AnimatedSwitcher`, `FadeTransition`, `SlideTransition`을 활용해 가사 전환 애니메이션 적용
  - UI 스타일은 PAPAGO MINI 유사

- **`services/dummy_service.dart`**
  - BTS 'Dynamite', '봄날' 트랙 하드코딩
  - `LyricLine`(가사 타임라인) 관리
  - `StreamController`로 트랙 및 가사 스트림 전송
  - `Timer.periodic`으로 3초마다 가사 변경

- **기타 서비스 파일**
  - 실제 API 연동용 기본 로직 존재
  - 현재는 사용되지 않음
  - `flutter_dotenv`를 통한 안전한 API 키 관리 설계

### 3. 구조적 특징

- **UI/로직 분리**: `screens/`, `services/` 폴더 구분
- **상태 관리**: `StatefulWidget` + `StreamBuilder` 활용
- **데모 모드**: 실제 API 없이 UI 테스트 가능
- **API 키 관리**: `.env` 파일로 분리하여 보안 강화

## 백엔드 필요성 검토

### 1. 현재 구조에서는 백엔드 필요 없음
- `dummy_service.dart`처럼 **로컬에 데이터(가사, 번역, 트랙 정보)를 하드코딩**해 놓고,
- 앱 안에서 **스트림(Stream)** 으로 데이터만 흘려 보내는 구조이기 때문에,
- 별도로 서버가 데이터를 보내주거나 받을 필요가 없습니다.

> 즉, 현재는 완전한 **클라이언트 사이드 앱**입니다.

### 2. 그러나 실제 기능을 확장하면 백엔드가 필요할 수도 있음

아래 상황들이 발생하면 백엔드가 필요해질 가능성이 있습니다:

| 시나리오 | 설명 | 필요 여부 |
|:---|:---|:---|
| **실제 Spotify 연동** | 사용자별 로그인, 토큰 관리, 현재 재생 곡 가져오기 | 필요 (Spotify 인증 서버 필요할 수도) |
| **실제 Musixmatch 가사 가져오기** | 가사를 API로 받아오려면 API 요청 및 키 관리 필요 | 필요 (보안상 서버 거치는 게 안전) |
| **Google Translate API 사용** | 번역을 실시간 요청하려면 | 필요 (API 키 보호를 위해 서버 필요할 수 있음) |
| **사용자 맞춤 데이터 저장** | 사용자가 좋아하는 가사 저장, 히스토리 관리 등 | 필요 (DB 필요) |
| **유료 서비스로 확장** | 결제, 구독 시스템 도입 | 반드시 필요 |

### 3. 결론

- 지금 상태(데모/개발/기능 테스트용)이라면 **백엔드 없이** Flutter 앱만으로 충분합니다.
- 하지만 **실제 배포**하거나, **API 키 보호**, **사용자 관리**, **데이터 저장** 같은 걸 고려하면 **백엔드 구축이 필요**합니다.

> **API 키 보호** 때문에라도 Google Translate나 Musixmatch 같은 상용 API를 쓸 때는 Flutter에서 직접 호출하지 않고 백엔드 서버를 중간에 두는 것이 **보안상 표준**입니다. (Flutter에서 `.env`에 키를 넣어도 앱 빌드하면 다 노출될 수 있음)

### 가능한 백엔드 구현 방향

1. **Firebase 기반**: 인증, 데이터베이스, Cloud Functions를 통한 API 프록시 구현
2. **경량 Node.js 서버**: Express 기반으로 API 프록시 및 사용자 관리 
3. **서버리스 아키텍처**: AWS Lambda + API Gateway를 활용한 확장 가능한 백엔드

## 설치 및 실행

1. 저장소 클론:
```
git clone https://github.com/Wraith111113/spotify-lyrics-translator.git
```

2. 의존성 설치:
```
flutter pub get
```

3. 실행:
```
flutter run
```

## 환경 설정

실제 API 연동을 위해서는 `.env` 파일을 생성하고 다음 API 키들을 설정해야 합니다:

```
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
MUSIXMATCH_API_KEY=your_musixmatch_api_key
GOOGLE_TRANSLATE_API_KEY=your_google_translate_api_key
```

> 주의: `.env` 파일을 Git에 커밋하지 마세요. 이 파일은 `.gitignore`에 포함되어 있습니다.
