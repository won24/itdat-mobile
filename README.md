# 온라인 명함 관리 플랫폼 ITDAT
![logo](https://github.com/user-attachments/assets/8ac6db93-1ac5-4a0f-bf0e-3cf0e3e6382f)
<br>

<summary>목차</summary>

1. [프로젝트 소개](#intro)
2. [요구사항](#reqirements)
3. [팀원 소개](#members)
4. [페이지별 기능](#page)
5. [개발 환경](#env)

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
  
## 3. <span id="members">팀원</span> 
<table>
  <tr>
    <td align="center">
      <strong>김동규</strong><br>
      <img src="https://github.com/user-attachments/assets/48f2fbdf-8839-4498-a1c8-800e3185bc55" width="100"><br>
      <a href="https://github.com/nicdkim">GitHub</a>
    </td>
    <td align="center">
      <strong>서현준</strong><br>
      <img src="여기에 각자 사진 가져오면 됨" width="100"><br>
      <a href="본인 깃허브 링크">GitHub</a>
    </td>
    <td align="center">
      <strong>진원</strong><br>
      <img src="여기에 각자 사진 가져오면 됨" width="100"><br>
      <a href="https://github.com/won24/won24.github.io">GitHub</a>
    </td>
    <td align="center">
      <strong>손정원</strong><br>
      <img src="여기에 각자 사진 가져오면 됨" width="100"><br>
      <a href="본인 깃허브 링크">GitHub</a>
    </td>
  </tr>
</table>

## 🔎 역할 분담
##### 김동규(PM)

##### 서현준

##### 진원
- 명함 템플릿 제작, 커스텀 명함 제작, 명함 상세페이지, 명함 정보 기반 연락처 종류 별 기능 연동, 포트폴리오/히스토리 게시판, 명함 확대보기

##### 손정원

<br>

## 4. <span id="page">위젯 별 상세 기능</span>
| **회원가입** | **명함 정보 입력 및 약관동의** |
| :------------: | :------------: |
|![회원가입](https://github.com/user-attachments/assets/3d66a8de-6305-4b11-9745-d2c588fde04e)|![정보입력](https://github.com/user-attachments/assets/5aeab720-74af-45cf-84d1-bd869e3aa3c2)|
| 가입정보 입력, 이메일 인증을 통해 유효성 검사 후 회원가입 | 명함 기본 정보 입력, 약관동의 |

| **로그인** | **명함 만들기** |
| :------------: | :------------: |
|![로그인](https://github.com/user-attachments/assets/7c52e528-2a5f-453a-9f14-cdc945726a1b)|![커스텀 명함](https://github.com/user-attachments/assets/1143d831-9853-45cd-afcb-6d9c5551788a)|
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

## 5. <span id="env">개발 기간 및 환경</span>

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
![Flutter](https://img.shields.io/badge/Flutter-03E6FF?style=for-the-badge&logo=openjdk&logoColor=grey)   
![Kakao API](https://img.shields.io/badge/Kakao%20API-FFCD00?style=for-the-badge&logo=kakao&logoColor=black)  
![Naver API](https://img.shields.io/badge/Naver%20API-03C75A?style=for-the-badge&logo=naver&logoColor=white)  
![Google API](https://img.shields.io/badge/Google%20API-4285F4?style=for-the-badge&logo=google&logoColor=white) 


#### WBS
[WBS 보기](https://docs.google.com/spreadsheets/d/1GfJm25oclrC1F1lVo9e7SdV8qnmDxA-MVvHAA7A2jsA/edit?gid=1523815437#gid=1523815437)
