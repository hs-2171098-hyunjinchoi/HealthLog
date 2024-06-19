# Health Log
* 슬로건: "기록하고, 추적하고, 건강해지세요"
* 설명: "HealthLog는 매일의 식단과 운동을 기록하고 분석하여, 당신이 더 건강한 삶을 살 수 있도록 도와줍니다."

## 핵심 기능 설명
1. 알림 설정: 매일 아침 맞춤 알림으로 건강한 하루를 시작하세요.
2. 식단 기록: 사진과 함께 식단을 기록하고, 칼로리를 자동으로 계산하세요.
3. 운동 기록: 운동 활동을 기록하고 소모 칼로리를 추적하세요.
4. 달력 기능: 달력을 통해 월별 건강 기록을 쉽게 확인하세요.
5. 식단 및 운동 기록 분석: 식단 및 운동 기록을 그래프를 통해 한눈에 확인하세요.

## 사용한 API
* Google Translation API: 음식 이름을 번역하여 Edamam API에서 검색할 수 있도록 도와줍니다.
    - 기능: 입력된 음식 이름을 영어로 번역합니다.
    - 사용법: `apikeys.plist` 파일에 `GoogleTranslationAPIKey`를 추가하여 사용합니다.

* Edamam Food Database API: 음식의 칼로리 및 영양 정보를 제공합니다.
    - 기능: 입력된 음식의 칼로리를 검색합니다.
    - 사용법: `apikeys.plist` 파일에 `EdamamAppId`, `EdamamAppKey`를 추가하여 사용합니다.

## 전체 구조 요약
* DashboardViewController: 대시보드 화면, 오늘의 요약 정보를 카드 형식으로 표시.
* DietDetailsViewController: 식단 요약의 세부 정보를 표시.
* DietViewController: 사용자가 새로운 식단 정보를 추가하는 화면.
* ExerciseDetailsViewController: 운동 요약의 세부 정보를 표시.
* ExerciseViewController: 사용자가 운동을 기록하는 화면.
* CalendarViewController: 월별 달력에 식단과 운동 기록을 표시하는 화면.
* AlarmViewController: 사용자가 알람을 설정하고 관리하는 화면.
* DietAnalysisViewController: 사용자가 입력한 식단 데이터를 그래프로 분석하여 시각적으로 표시하는 화면.
* ExerciseAnalysisViewController: 사용자가 입력한 운동 데이터를 그래프로 분석하여 시각적으로 표시하는 화면.

## 시연 영상
https://youtu.be/JbteJZKZFmA
