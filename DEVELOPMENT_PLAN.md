# SoccerHeatmap (KICKOFF) 개발 지시서 - 1단계

나는 지금 Flutter 기반의 축구 히트맵 앱 'KICKOFF'를 개발 중이야. 현재 UI는 90% 완성되었지만 데이터는 더미 데이터를 쓰고 있어. 이제 실제 Apple Watch와 HealthKit을 연동하는 작업을 시작할 거야. 아래 단계에 따라 최소 기능(MVP)을 구현해줘.

## 1. iOS 설정
- `Info.plist`에 HealthKit 사용 권한(`NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`) 및 백그라운드 모드 설정을 추가해줘.
- 프로젝트에 HealthKit 및 CoreLocation 프레임워크를 추가할 수 있도록 가이드를 줘.

## 2. HealthKit 서비스 구현
- `lib/core/services/` 폴더에 `health_kit_service.dart`를 만들어줘.
- 사용자의 심박수(Heart Rate)와 워크아웃 세션 권한을 요청하고, 실시간 심박수를 가져오는 기본 로직을 작성해줘.

## 3. Flutter - iOS 브릿지 (MethodChannel)
- iOS 네이티브 레벨(`Swift`)에서 HealthKit 데이터를 Flutter로 쏘아줄 `MethodChannel` 또는 `EventChannel` 코드를 작성해줘.

## 4. 상태 관리 연동
- `lib/data/providers/`에 기존의 더미 데이터 대신 실제 HealthKit 스트림을 구독하는 `RealTimeStatsProvider` (Riverpod)를 구현해줘.

## ⚠️ 주의사항
- 복잡한 기능보다는 우선 '연결 확인'과 '실시간 심박수 표시'에 집중해서 가장 심플한 코드로 짜줘.
- 기존 `MatchData` 모델 구조를 깨뜨리지 말고 연동해줘.
