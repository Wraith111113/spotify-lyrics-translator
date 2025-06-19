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

## 추가 라이브러리 및 개발 환경

- overlay_support: 오버레이/알림/팝업 위젯 지원
- flutter_overlay_window: 시스템 오버레이(윈도우/안드로이드 등) 지원

## CI/CD

- GitHub Actions를 통한 자동 빌드/테스트/배포 파이프라인 적용 예정

## 라이센스

- 본 프로젝트는 MIT 라이센스를 따릅니다. 자세한 내용은 LICENSE 파일을 참고하세요.
- 

Lyrics Translator App
This is a Flutter application that displays and translates Spotify music lyrics in real-time.

Project Overview
This app shows the lyrics of the currently playing music in a UI similar to PAPAGO MINI, presenting them in a timeline format. Each lyric line is displayed along with its translation.

Features
Displays the currently playing song.
Presents song lyrics in a timeline format.
Provides translations for lyrics.
Clean and intuitive PAPAGO MINI-style UI.
Automatic lyric progression based on the timeline.
Code and Structure Analysis
1. Project Structure
lib/: Contains core Dart code.
main.dart: App entry point, defines app settings and theme.
screens/: UI screen-related widgets.
home_screen.dart: Main screen UI and state management.
services/: Backend logic, data processing, API integration.
dummy_service.dart: Provides hardcoded tracks and lyrics for demo mode.
spotify_service.dart: (Unused) Spotify API integration.
lyrics_service.dart: (Unused) Musixmatch API integration.
translate_service.dart: (Unused) Google Translate API integration.
pubspec.yaml: Project dependencies and app metadata.
platform folders (android/, ios/, web/, etc.): Native code for each platform.
.gitignore: List of files excluded from Git tracking.
Other configuration files: .metadata, analysis_options.yaml, etc.
2. Key File Analysis
main.dart

Sets up MaterialApp and designates HomeScreen as the home screen.
Disables the debug banner.
screens/home_screen.dart

A StatefulWidget managing loading, error, initialization, and lyric change states.
Directly instantiates and uses DummySpotifyService.
Uses two StreamBuilder widgets to receive current track and lyric/translation streams.
Implements lyric transition animations using AnimatedSwitcher, FadeTransition, and SlideTransition.
UI style is similar to PAPAGO MINI.
services/dummy_service.dart

Hardcodes BTS 'Dynamite' and 'Spring Day' tracks.
Manages LyricLine (lyric timeline).
Sends track and lyric streams via StreamController.
Changes lyrics every 3 seconds using Timer.periodic.
Other Service Files

Contains basic logic for actual API integration.
Currently unused.
Designed for secure API key management via flutter_dotenv.
3. Structural Characteristics
UI/Logic Separation: Distinct screens/ and services/ folders.
State Management: Utilizes StatefulWidget + StreamBuilder.
Demo Mode: Allows UI testing without actual API integration.
API Key Management: Securely separates API keys using an .env file.
Backend Necessity Review
1. No Backend Needed in Current Structure
As the current structure hardcodes data (lyrics, translations, track info) locally in dummy_service.dart,
and the app streams data internally,
there's no need for a separate server to send or receive data.
In other words, it's currently a completely client-side app.

2. However, Expanding Functionality May Require a Backend
A backend may become necessary under the following scenarios:

Scenario	Description	Backend Needed?
Actual Spotify Integration	User-specific login, token management, fetching currently playing song.	Yes (May require Spotify authentication server)
Fetching Real Musixmatch Lyrics	If lyrics are retrieved via API, API requests and key management are needed.	Yes (Safer to route through a server for security)
Using Google Translate API	For real-time translation requests.	Yes (Server may be needed to protect API keys)
Storing User-Specific Data	Saving user's favorite lyrics, managing history, etc.	Yes (Requires a database)
Expanding to Paid Services	Implementing payment and subscription systems.	Absolutely Yes

Export to Sheets
3. Conclusion
For its current state (demo/development/feature testing), a Flutter app without a backend is sufficient.
However, for actual deployment, considering API key protection, user management, and data storage, building a backend will be necessary.
For API key protection alone, when using commercial APIs like Google Translate or Musixmatch, it is standard security practice to use a backend server as an intermediary rather than calling them directly from Flutter. (Even if you put keys in .env in Flutter, they can be exposed when the app is built.)

Possible Backend Implementation Approaches
Firebase-based: Implementing authentication, database, and API proxy via Cloud Functions.
Lightweight Node.js Server: An Express-based server for API proxy and user management.
Serverless Architecture: Utilizing AWS Lambda + API Gateway for a scalable backend.
Installation and Running
Clone the repository:
git clone https://github.com/Wraith111113/spotify-lyrics-translator.git
Install dependencies:
flutter pub get
Run the app:
flutter run
Environment Setup
To integrate with actual APIs, create a .env file and configure the following API keys:

SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
MUSIXMATCH_API_KEY=your_musixmatch_api_key
GOOGLE_TRANSLATE_API_KEY=your_google_translate_api_key
Note: Do not commit the .env file to Git. It is included in .gitignore.

Additional Libraries and Development Environment
overlay_support: Supports overlay/notification/popup widgets.
flutter_overlay_window: Supports system overlays (e.g., Windows/Android).
CI/CD
Automated build/test/deployment pipeline via GitHub Actions is planned.
License
This project is licensed under the MIT License. Refer to the LICENSE file for more details.
