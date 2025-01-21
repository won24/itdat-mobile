// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
//
//
// Future<String?> downloadAndSaveFile(String url) async {
//   try {
//     final dir = await getTemporaryDirectory();
//     final filePath = '${dir.path}/${url.split('/').last}';
//     final dio = Dio();
//     await dio.download(url, filePath);
//     return filePath;
//   } catch (e) {
//     print('PDF 다운로드 실패: $e');
//     return null;
//   }
// }
