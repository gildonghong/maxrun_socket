import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'Executor.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  runApp(MaterialApp(home: ShowMessage(),));
}


class ShowMessage extends StatelessWidget {
  const ShowMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        content: Text("사진을 저장할 하드디스크 공간이 부족합니다. 기존 저장된 사진을 삭제하셔서 공간을 확보하시기 바랍니다. 공간 확보하신 후 맥스런 운영사업팀에 전화 주시면 다시 사진 전송 가능하도록 해드리겠습니다."),
        title: Text("maxrun photoApp 시스템 알림"),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
            windowManager.hide();
          }, child: Text("OK"))
        ],
      ),
    );
  }
}
