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
3. [맡은 기능](#my)
4. [트러블 슈팅](#troubleShooting)
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

## 3. <span id="my">맡은 기능</span>
#### 기획, 디자인, 프론트엔드, 백엔드
| **기능 페이지** | **주요 내용** |
| :-------: | :-------: |
| 메인페이지 | 최근 본 게시글 구현 <br> 배너를 통해 해당 아이템 상세보기 <br> 홈페이지 전체 레이아웃 |
| 라이브 경매 게시판 | 시간에 따른 채팅/입찰/낙찰 후 환불 기능 활성화 <br> 낙찰자 안내 모달창 |
| 경매품 게시판 | 경매 목록 <br> 필터링 <br> 검색 <br> 즐겨찾기 <br> 경매품 상세보기 페이지 |
| 관리자 모드 | 게시글 승인/수정/삭제 기능 <br> 권한 분리 |

<br>

## 4. <span id="troubleShooting">트러블 슈팅</span>

#### 최근 본 게시물 – 브라우저 뒤로가기 시 상태 미반영 문제

- 로컬스토리지를 기반으로 게시물을 보여주도록 구현했으나, 브라우저 뒤로가기 시 `useEffect`가 재실행되지 않아 상태가 갱신되지 않는 문제 발생  
- `window.addEventListener('popstate', ...)`를 통해 뒤로가기 이벤트 감지 후 상태를 업데이트하여 해결  
- **SPA 라우팅과 상태 관리 간의 연결을 명확히 이해하고 대응할 수 있었던 경험**

#### 경매 종료 후 환불 로직 반복 실행 문제

- 경매 종료 후, 낙찰자를 제외한 사용자에게 금액을 환불하는 로직이 타이머가 작동하는 5분간 계속 반복되어 **중복 환불 발생**  
- `requestSent` 상태 플래그를 도입해 로직을 최초 1회만 실행하도록 조건 분기하여 API 호출 중복을 방지  
- **실시간 로직에서의 비동기 제어와 상태 플래그 사용의 중요성을 체감**

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

