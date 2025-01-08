// import 'package:flutter/material.dart';
// import 'package:flutter_naver_map/flutter_naver_map.dart';
//
// class NaverMap extends StatelessWidget {
//   const NaverMap({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: NaverMap(
//         options: const NaverMapViewOptions(
//           mapType: NMapType.basic,
//           activeLayerGroups: [
//             NLayerGroup.building,
//             NLayerGroup.transit,
//             NLayerGroup.traffic,
//             NLayerGroup.bicycle,
//             NLayerGroup.mountain,
//             NLayerGroup.cadastral,
//           ],
//           pickTolerance: 8, // 오버레이와 심볼의 터치 반경 (pickTolerance)
//           // 제스처에는 회전, 스크롤, 틸트(기울기), 줌(확대), 스톱이 있습니다.
//           rotationGesturesEnable: true,
//           scrollGesturesEnable: true,
//           tiltGesturesEnable: true,
//           zoomGesturesEnable: true,
//           stopGesturesEnable: true,
//           // 마찰계수 (0~1)
//           scrollGesturesFriction: 1.0,
//           zoomGesturesFriction: 1.0,
//           rotationGesturesFriction: 1.0,
//           // 줌/틸트 제한
//           minZoom: 10, // default is 0
//           maxZoom: 16, // default is 21
//           maxTilt: 30, // default is 63
//           // 지도 영역을 한반도 인근으로 제한
//           extent: NLatLngBounds(
//             southWest: NLatLng(31.43, 122.37),
//             northEast: NLatLng(44.35, 132.0),
//           ),
//           // 언어 설정
//           locale: Locale('ko'),
//           // 내 위치 버튼
//           locationButtonEnable: true,
//           // 실내 지도 레벨 피커
//           indoorLevelPickerEnable: true
//
//         ),
//         forceGesture: false, // 지도에 전달되는 제스처 이벤트의 우선순위를 가장 높게 설정할지 여부를 지정합니다.
//         onMapReady: (controller) {
//           print("네이버 맵 로딩됨!");
//         },
//         onMapTapped: (point, latLng) {},
//         onSymbolTapped: (symbol) {},
//         onCameraChange: (position, reason) {},
//         onCameraIdle: () {},
//         onSelectedIndoorChanged: (indoor) {},
//       )
//     );
//   }
// }
