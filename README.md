# 온라인 명함 관리 플랫폼 ITDAT
![logo](https://github.com/user-attachments/assets/8ac6db93-1ac5-4a0f-bf0e-3cf0e3e6382f)
<br>
버전 코드 : 16 (2.0.7)

> 본 README는 ITDAT 프로젝트에서 제가 맡은 기능에 한해 포트폴리오 용도로 일부 수정하였습니다.
전체 프로젝트는 아래 원본 저장소에서 확인할 수 있습니다.
> [원본 GitHub Repository](https://github.com/itdat-namewallet/Mobile)
>

<br>


<summary>목차</summary>

1. [프로젝트 소개](#intro)
2. [요구사항](#reqirements)
3. [주요 기술 성과](#my)
4. [프로젝트 회고](#troubleShooting)
5. [페이지별 기능](#page)
6. [개발 환경](#env)

<br>

## 1. <span id="intro">프로젝트 소개</span>

##### ITDAT은 기존 종이 명함을 디지털 명함으로 대체하여 환경오염을 줄이고, 효율적인 네트워킹을 가능하게 하는 서비스입니다.

##### ITDAT은 ESG 경영 실천 및 탄소중립 목표 달성을 위한 솔루션으로 기획되었습니다.

✅ 디지털 명함 생성 및 관리: 사용자가 자신만의 명함을 생성하고, QR 코드나 NFC를 통해 손쉽게 교환 가능

✅ 명함 데이터 저장 및 분류 기능: 물리적인 보관이 필요 없이, 명함 지갑에 저장하고 분류 가능

✅ 인증된 사용자 기반 서비스: 인증된 사용자 기반의 서비스로, 신뢰할 수 있는 명함 제작 가능

✅ 관리자의 사용자 관리: 부적절한 명함 제작의 사용자에 대한 관리자의 제재 가능

<br>

## 2. <span id="reqirements">요구사항</span>
📁 인증: 자체 회원가입/로그인, 소셜 회원가입/로그인, 이메일 인증 및 유효성 검사

📁 명함 제작: 템플릿 선택, 명함 정보 입력, 명함 커스텀

📁 내 명함: 명함 생성/조회, 명함 정보 기반 연락처 기능 별 연동, 포트폴리오 & 히스토리 작성 및 관리  

📁 QR 코드: QR코드 생성/스캔/이미지를 통해 명함 전송

📁 NFC: NFC 카드에 명함 등록, 휴대폰 태깅을 통해 전달

📁 명함첩: 받은 명함 폴더로 관리, 명함 상세 보기, 명함첩 관리

📁 공개 명함: 공개된 명함 조회, 명함 상세보기, 부적절한 명함 신고

📁 내 정보: 어플 환경설정, 내 정보 수정/삭제, 내 명함 수정/삭제, 공개 명함 설정

<br>

## 3. <span id="my">주요 기술 성과</span>
#### 기획, 디자인, 프론트엔드, 백엔드

### 1. Flutter 위젯 기반 동적 템플릿 시스템 아키텍처
- 문제 <br>
초기 기획의 Figma 스타일 자유 편집 에디터의 기술적 복잡성과 개발 리소스 한계

- 기술적 전환 과정 <br>
**1단계: API 기반 자유 편집 에디터 프로토타입 개발 시도** <br>
          → 상용 API 부재 및 자체 구현 난이도로 현실화 불가<br>
**2단계: SVG 기반 템플릿 도입** <br>
     → 데이터 바인딩 시 동적 텍스트 길이 변화로 레이아웃 파괴<br>
**3단계: Flutter 위젯 기반 컴포넌트 템플릿 시스템으로 최종 결정**<br>

- 해결 <br>
**템플릿-데이터 분리 아키텍처 설계로 재사용성 및 확장성 확보**<br>
동적 데이터 바인딩 시에도 **레이아웃 일관성 유지**<br>
다양한 텍스트 길이 변화 시나리오에서 레이아웃 파괴 발생 여부를 정성적으로 테스트하여 검증

### 2. 비동기 데이터 처리 및 상태 관리 최적화
- **실시간 미리보기 기능**으로 사용자 편집 경험 향상 (응답시간 **300ms 이내**)
- 사용자 편집 액션부터 미리보기 업데이트까지의 실제 응답 시간을 밀리초 단위로 측정
- FutureBuilder + Provider 패턴을 활용한 **효율적 비동기 상태 관리**
- 명함 목록/상세/템플릿 렌더링 로직에서 FRONT/BACK 구분 기반 **양면 렌더링 시스템 구현**
- StreamBuilder를 통한 **실시간 데이터 스트리밍 처리**

### 3. RESTful API 기반 백엔드 통합 및 미디어 처리
- Spring Boot 기반 **RESTful API 12개** 엔드포인트 설계 및 구현
- **명함/게시글 CRUD, 파일 업로드, 미디어 첨부** 기능의 완전한 **API 연동**
- **연락처 액션 통합**: 전화, 문자, 이메일, 지도 연동을 위한 **딥링크** 처리

### 4. 커스터마이징 및 통합 정보 관리 플랫폼
- 색상, 폰트, 로고 등 세밀한 **커스터마이징 옵션 제공**
- 포트폴리오, 히스토리, 개인 메모, 연락처 액션 등을 **하나의 통합 플랫폼으로 구현**

<br>

## 4. <span id="troubleShooting">프로젝트 회고</span>
#### 1. 성과
프로젝트를 통해 Flutter, Spring Boot 기술 스택을 실제 개발에 적용하며 소중한 경험을 쌓았습니다. <br>
무엇보다 제한된 시간 안에도 목표한 프로젝트를 완성해낼 수 있었다는 점에서 빠른 개발 실행력을 확인할 수 있었습니다.

#### 2. 아쉬운 점
프로젝트 완성에만 급급했던 나머지, 각 기능이 어떤 원리로 동작하는지, 어떻게 최적화 할 수 있는 지에 대한 깊이 있는 고민이 부족했습니다. <br>
또한 개발 과정에서 내가 왜 이런 기술적 선택을 했는지, 어떤 의도로 설계 했는지를 체계적으로 기록하지 않아 나중에 코드를 다시 봤을 때 혼란스러웠습니다.<br>
문제가 생겼을 때도 당장 해결하는 데만 집중했지, 다양한 해결 방안이나 근본적인 원인까지는 파고들지 못했습니다.

#### 3. 개선하고 싶은 점
**- 체계적 문서화 습관 확립**
<br>
개발하면서 내린 모든 의사 결정과 기술적 선택의 이유를 기록하고, 구현 의도와 설계 배경을 명확히 문서화할 필요성을 느꼈습니다.

**- 기술적 이해도 향상**
<br>
단순히 코드가 돌아가게 만드는 것을 넘어서 왜 이렇게 동작하는지, 어떻게 하면 더 좋게 만들 수 있는 지를 생각하며 기능을 구현해야 문제를 만났을 때도 여러 해결책을 검토하고 근본적인 원인을 분석할 수 있음을 느꼈습니다.<br>
빠른 개발도 중요하지만, 그 과정에서 기술적 이해도를 높이는 것도 함께 챙기고자 합니다.

#### 4. 결론
새로운 기술 스택을 익히고 실무 경험을 쌓는 데 성공했으나, 문서화와 원리 이해라는 개선점을 발견할 수 있었습니다. 

향후 프로젝트에서는 기능 구현과 함께 체계적인 학습 기록과 깊이 있는 기술 탐구를 병행하여 더욱 의미 있는 개발 경험을 쌓아나가고자 합니다.

<br>

## 5. <span id="page">위젯 별 상세 기능</span>
| **회원가입** | **명함 정보 입력 및 약관동의** |
| :------------: | :------------: |
|![회원가입](https://github.com/user-attachments/assets/3d66a8de-6305-4b11-9745-d2c588fde04e)|![정보입력](https://github.com/user-attachments/assets/5aeab720-74af-45cf-84d1-bd869e3aa3c2)|
| 가입정보 입력, 이메일 인증을 통해 유효성 검사 후 회원가입 | 명함 기본 정보 입력, 약관동의 |

| **로그인** | **명함 만들기** |
| :------------: | :------------: |
|![로그인](https://github.com/user-attachments/assets/7c52e528-2a5f-453a-9f14-cdc945726a1b)|![커스텀 명함](https://github.com/user-attachments/assets/8fc0cbab-91a8-4c3c-852b-178e59f4e88f)|
| 이메일 또는 아이디 로그인 / 소셜 로그인  | 템플릿 선택 후 명함 정보 확인 및 수정, 배경 색, 글씨색, 글씨체 변경으로 커스텀 제작 가능, 추가로 뒷면 제작 가능 |

| **내 명함/ 명함 디테일 페이지** | **포트폴리오/히스토리** |
| :------------: | :------------: |
|![연락처](https://github.com/user-attachments/assets/1b1cd736-b37b-4608-897a-deb1f80ab686)|![게시판](https://github.com/user-attachments/assets/607f5009-b7bf-4523-a3c9-053870b911d3)|
| 명함 확인, 명함 정보 기반 연락처 별 바로가기 기능 제공 | 포트폴리오/히스토리 게시판 작성, 조회, 수정, 삭제 |

| **QR 코드** | **NFC** |
| :------------: | :------------: |
|![qr](https://github.com/user-attachments/assets/23585de3-fe1b-4263-a084-1ec725a5aae6)|![nfc](https://github.com/user-attachments/assets/ff9ea19f-977e-4a42-831a-a2e1033e7cc3)|
| 선택 명함 QR 생성, QR 코드를 통해 명함 전달 | NFC카드에 명함 저장, 핸드폰에 태깅으로 명함 전송 |

| **명함 상세보기** | **명함첩** |
| :------------: | :------------: |
|![명함 수정](https://github.com/user-attachments/assets/4fedcfcd-b80a-40d2-9ff1-cf2734f2102b)|![명함첩](https://github.com/user-attachments/assets/7f9a0953-21cb-4479-a80a-4671a11ab277)|
| 명함 클릭 후 명함 확대 보기 가능, 내 명함 수정,삭제 기능 | 받은 명함을 폴더별로 정리 가능, 폴더 생성/수정/삭제, 명함첩 내 명함 관리 |

| **공개명함** | **공개명함 신고** |
| :------------: | :------------: |
|![공개명함](https://github.com/user-attachments/assets/531b0ee0-74ef-42d6-a7fe-7065c4d99e5c)|![명함 신고](https://github.com/user-attachments/assets/b49c2dac-86a4-4c24-9d3e-e63529961f74)|
| 공개된 명함 조회, 명함 상세보기 | 부적절한 명함 관리자에게 신고 가능 |

| **내 정보** | **공개명함 설정** |
| :------------: | :------------: |
|![어플설정](https://github.com/user-attachments/assets/ac9ac667-5097-4d78-bdf2-88fdbb0da86e)|![공개명함설정](https://github.com/user-attachments/assets/6b4955c6-e0e8-4c5b-844d-e226b4b6e208)|
| 다국어, 어플테마, 글씨체 변경, 로그아웃, 내 정보 변경 등 어플 환경설정 및 내 정보 관리 가능 | 내정보 위젯에서 명함 선택 후 공개/비공개 설정 가능 |

<br>

## 6. <span id="env">개발 기간 및 환경</span>
#### 개발기간 
2024.12.09 ~ 2025.01.23
(4인 팀 프로젝트)

#### 시스템 구성도
![시스템 아키텍쳐](https://github.com/user-attachments/assets/82c7dc8f-7522-4054-aae9-79587cd45691)
#### UML
![UML](https://github.com/user-attachments/assets/1186f30a-a9a7-4fad-97d9-3a1f5ad3773a)

#### 데이터베이스
ERD(데이터 사전 정의서를 기반으로 설계)
  ![image](https://github.com/user-attachments/assets/e7ae9990-93e5-421e-a1b2-04e0b17e38a9)
  
#### 기술 스택
![Flutter](https://img.shields.io/badge/Flutter-03E6FF?style=for-the-badge&logo=flutter&logoColor=grey)   
![Kakao API](https://img.shields.io/badge/Kakao%20API-FFCD00?style=for-the-badge&logo=kakao&logoColor=black)  
![Naver API](https://img.shields.io/badge/Naver%20API-03C75A?style=for-the-badge&logo=naver&logoColor=white)  
![Google API](https://img.shields.io/badge/Google%20API-4285F4?style=for-the-badge&logo=google&logoColor=white) <br>
![Firebase](https://img.shields.io/badge/Firebase-BC0000?style=for-the-badge&logo=firebase&logoColor=white) <br>
Flutter (Dart) + Android (Java) 네이티브 연동

#### TOOLS
![Github](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)  
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)  
<br>

