// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:window_manager/window_manager.dart';
// import 'package:maxrun_socket/main.dart' as mv;
// import 'main2.dart' as login;

void main() async{
  // WidgetsFlutterBinding.ensureInitialized();
  // await windowManager.ensureInitialized();
  //
  // WindowOptions windowOptions = const WindowOptions(
  //   size: Size(500, 350),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: false,
  //   titleBarStyle: TitleBarStyle.hidden,
  //   windowButtonVisibility: false,
  // );
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });
  //
  // MyApp loading = MyApp();
  // runApp(loading);
  //
  // loading.letMeHide();
  // print("사라졌냐??");
  //
  // login.main();

}

// class MyApp extends StatelessWidget {
//   void letMeHide() async{
//     windowManager.hide();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Spinkit Example', // 앱 타이틀 설정
//       theme: ThemeData(
//         primarySwatch: Colors.blue, // 앱 테마 설정
//       ),
//       home: MyLoadingScreen(), // 앱 시작 시 로딩 화면으로 설정
//     );
//   }
// }
//
// class MyLoadingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         //로딩바 구현 부분
//         child: SpinKitFadingCube( // FadingCube 모양 사용
//           color: Colors.blue, // 색상 설정
//           size: 50.0, // 크기 설정
//           //duration: Duration(seconds: 2), //속도 설정
//         ),
//       ),
//     );
//   }
// }