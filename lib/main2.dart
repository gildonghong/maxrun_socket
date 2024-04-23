import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:maxrun_socket/main.dart' as mv;
import 'package:window_manager/window_manager.dart';
import 'Executor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(500, 350),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MaterialApp(debugShowCheckedModeBanner: false,
    home: LoginApp(),));
}

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> with WindowListener{
  final ctrl = TextEditingController();
  final ctrl2 = TextEditingController();
  final FocusNode _f1 = new FocusNode();
  final FocusNode _f2 = new FocusNode();

  String? id;
  String? pwd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _f1.dispose();
    _f2.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
    id = ctrl.text;
    pwd = ctrl2.text;
  }

  @override
  void onWindowMinimize() {
    // do something
    //popMessage("최소화");
  }

  @override
  void onWindowRestore() {
    //popMessage("다시 복구");
  }

  void tryLogin() async{
    if(ctrl.text.isEmpty){
      popMessage("ID를 입력하세요");
      _f1.requestFocus();
      return;
    }else if(ctrl2.text.isEmpty){
      popMessage("PASSWORD를 입력하세요");
      _f2.requestFocus();
      return;
    }

    Map<String, dynamic> param = {"loginId":ctrl.text, "passwd":ctrl2.text};
    Future<Map<String, dynamic>?> _user = login(endPoint: "http://www.maxrunphoto.com/login", param: param);

    _user.then((value) {
      if(value==null){
        popMessage("존재하지 않는 사용자입니다. ID/PASSWORD를 확인하십시오!");
        return;
      }else{
        print('hi');
        print(value);
        if(value.containsKey("exception")){
          popMessage(value["exception"]);
        }else{
          //print("환영합니다. $value[repairShopName]");
          String uName=value['repairShopName'];
          popMessage("환영합니다. $uName님");
          //callMe(ctrl.text, ctrl2.text, _user);
          mv.connectToMaxrunSvr(ctrl.text, ctrl2.text, value);
          windowManager.hide();
        }
      }
    });
  }

  void popMessage(String msg){
    //print("msg=======>$msg");
    showDialog( context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text("Warming"),
            content: Text(msg, style: TextStyle(fontSize: 13),),
            actions: [
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: const Text("OK"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( backgroundColor: Colors.blueGrey,
                      title: Text("MaxRun PhotoApp System", style: TextStyle(color: Colors.white)),
                      actions: [IconButton(onPressed: (){windowManager.minimize();}, icon: Icon(Icons.close))],),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            TextField(textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15),
                decoration: InputDecoration(labelText: "ID :"),
                focusNode: _f1,
                controller: ctrl),
            TextField(textAlign: TextAlign.left,
                obscureText:true,
                style: TextStyle(fontSize: 15),
                decoration: InputDecoration(labelText: "PASSWORD :"),
                focusNode: _f2,
                controller: ctrl2),
            SizedBox(height: 20,),
            ElevatedButton( onPressed: () =>tryLogin(),
                            child: Text("LOG IN")),
            SizedBox(height: 40,),
            Text("(주)맥스런 /대표이사 김우겸 / 사업자등록번호 556-86-00899 경기도 파주시 월롱면 휴암로 79번길 62-24 / 고객센터 : 1688-4294 이메일: ADMIN@MAXRUN.COM",
              style: TextStyle(
                  fontSize: 10
              ),)
          ],
        ),
      ),
    );
  }
}
