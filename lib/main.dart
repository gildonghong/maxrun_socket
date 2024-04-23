import 'dart:io';
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'main2.dart' as login;
import 'package:logger/logger.dart';
import 'main3.dart' as dialog;

/*String?  userId;
String?  userPwd;
void callMe(String id, String pwd, Map<String, dynamic> userInfo){
  userId=id;
  userPwd=pwd;

  Future<Directory> userDir = getUserDirectory();
  //print('ddddddddddddddddddddddddddddddddddd');
  userDir.then((value) => print(value.path));

  main();
}*/

int directoryCreatedCnt=0;
int fileCopyCnt=0;
//File logFile=File("log.log");
late File logFile;
/*
var logger = Logger(
    printer: PrettyPrinter(),
    //output: FileOutput({required File file, bool overrideExisting = false, Encoding encoding = utf8})
    output: FileOutput(file: logFile)
);*/

late var logger;

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

Future<File> getLogFile() async{
  Directory d = await getApplicationDocumentsDirectory(); // + "\\" + "maxrun-socket.log";
  String path = d.path + "\\" + "maxrun-socket.log";

  return File(path);
}

//file에서 Map 읽어서 로그인 시도 하기
Future<Map<String, dynamic>?> _read() async {
  try{
    String? filePath;
    Directory myDir = await getUserDirectory();
    filePath = myDir.path + '\\' + 'maxrun.txt';

    //print("_read file path===> $filePath");
    final file = File(filePath!);
    final jsonStr = await file.readAsString();
    //print("_read jsonStr===> $jsonStr");

    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }catch(e,s){
    logger.d("_read function got exception:"+ s.toString());
    print('stackTrace==>' + s.toString());
  }
}

//로그인 정보를 파일로 저장하기
Future<void> _write(Map<String, dynamic> map) async {
  try{
    String? filePath;
    Directory myDir = await getUserDirectory();
    filePath = myDir.path + '\\' + 'maxrun.txt';

    //print("_write file path===> $filePath");
    final jsonStr = jsonEncode(map);
    //print("_write jsonStr===> $jsonStr");

    final file = File(filePath!);

    await file.writeAsString(jsonStr);
  }catch(e,s){
    print("stactkTrace==>" + s.toString());
    logger.d("_write function got exception:"+ s.toString());
  }

}

void main() async{
  print("##################################");
  print("##################################");
  print("##################################");

  logFile = await getLogFile();

  logger = Logger(
      printer: PrettyPrinter(),
      //output: FileOutput({required File file, bool overrideExisting = false, Encoding encoding = utf8})
      output: FileOutput(file: logFile)
  );

  Map<String, dynamic>? _user = await _read();

  logger.d("test");
  if(_user!=null){  //기존 로그인 이력이 있는 경우
    //print('file에서 로그인장보 읽어옴 !!!!');

    connectToMaxrunSvr(_user!['loginId'], _user!['passwd'], _user!);

  }else{  //최초 설치 후 또는 기존 계정이 로그인이 안되는 경우
    print('로그인 화면으로 유도');
    login.main();
  }
}

void connectToMaxrunSvr(String userId, String userPwd, Map<String, dynamic> userInfo) {

  userInfo['passwd']=userPwd;
  _write(userInfo); //사용자 정보 파일로 저장
  int _retryCnt=0;
  final uri = "wss://www.maxrunphoto.com/socket?loginId=$userId&passwd=$userPwd";
  //print("Now trying to $uri");

  try{
    /// Create the WebSocket channel

    final channel = IOWebSocketChannel.connect(
      //Uri.parse("ws://localhost/socket?loginId=0987654321&passwd=0987654321"));
      Uri.parse(uri), );

    Future<void> ready = channel.ready;

    ready.then((value){
      print("Connection sucess");
    },
    onError: (e){
      logger.d("SocketServer is not available"+ e.toString());
      print("SocketServer is not available");  //Host가 실행중이지 않을때 지속적으로 재접속 시도
    });
    /// Listen for all incoming data
    var listen = channel.stream.listen((data) {
      print("data ---> ${data}");
      Map<String, dynamic> message = jsonDecode(data);
      //message 구분
      if (message['division']=='DIRECTORY'){  /* folder 생성*/
        //print('create folder');
        createDirectory(channel, message);
      }else{  /* 파일 복사*/
        //print('file 경로');
        //print(message['clientPath']);
        createFile(channel, message);
      }
    },
        onError: (error) {
          logger.d("listen error==>"+ error.toString());
          print(error.toString());
        },
        onDone: (){ //abnomal disconnected
          print("갑작스런 중단");
          logger.d("갑작스런 중단");
          sleep(Duration(seconds: 50));
          main();
        }
    );
  } on WebSocketException catch (e, s){
    print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    print(e.runtimeType);
    print('Stack trace:\n $s');
  }
}

Future<Directory> getUserDirectory() async{

  Directory app_Dir = await getApplicationDocumentsDirectory();
  print("userDirectory===>" + app_Dir.path);
  return app_Dir;
}

void createFile(WebSocketChannel channel, Map<String, dynamic> message) async{
  try{
    print('starting file creation now');
    if(message['base64']==null){
      String serverPath = message['serverPath'];
      print('$serverPath does not provide base64 string');
      //print(message);

      message['result'] = 'FAIL';
      message['exception'] = 'base64 string did not transffered!';
      notifyToSvrFileIOWork(channel, message);

      return;
    }

    String bs4str = message['base64'];
    String fileExt = message['fileExt'];
    //print('11111');
    //Uint8List : A fixed-length list of 8-bit unsigned integers.
    Uint8List decodedbytes = base64.decode(bs4str);
    //print('2222');
    String filePath = message['clientPath']  + message['clientFileName'] + '.' + message['fileExt'];
    String claimedFinishedPath = message['clientPath']  + "청구완료\\" + message['clientFileName'] + '.' + message['fileExt'];

    if(FileSystemEntity.isFileSync(claimedFinishedPath)){
      print("청구완료상태 파일입니다");
    }else{
      //print('filePath-->' + filePath);
      File decodedimgfile = await File(filePath).writeAsBytes(decodedbytes);
      String decodedpath = decodedimgfile.path;
      message['result'] = 'SUCCESS';
      fileCopyCnt++;
      notifyToSvrFileIOWork(channel, message);
    }
  }catch(e, s){
    //print('Exception details:\n $e');
    print("file 복사 중 에러 발생");
    print('e.runtimeType-->' + e.runtimeType.toString());
    print(message['divison']);
    print(message['clientFilePath']);

    if("FileSystemException" == e.runtimeType.toString()){
      if(e.toString().contains("errno = 112")){
        dialog.main();  // 하드디스크 공간 부족 에러메시지 창 제공
      }
    }

    logger.d("file 복사 중 에러 발생 ==> " + e.toString());
    logger.d("file 복사 중 에러 발생 ==> " + message['clientPath']  + message['clientFileName'] + '.' + message['fileExt']);
    //print('message-->' + message.toString());
    //print('Stack trace:\n $s');
    message['result'] = 'FAIL';
    message['exception'] = e.toString();
    notifyToSvrFileIOWork(channel, message);
  }
}

void createDirectory(WebSocketChannel channel, Map<String, dynamic> message) async{
  // print (message);
  try{
    var directory;

    // if(message["subDiv"] == "MODI"){ //폴더 명 변경
    //   if(await Directory(message['clientPath']).exists()==true){//정비소 컴터에 해당 경로의 폴더가 존재하는 경우 폴더명을 변경
    //     directory = await Directory(message['beforeDirectoryName']).rename(message["clientPath"]) ;
    //   }else{
    //     directory = await Directory(message['clientPath']).create(recursive: true);
    //   }
    // }else if(message["subDiv"] == "DEL"){
    //   if(await Directory(message['clientPath']).exists()==true){  //정비소 컴터에 해당 경로의 폴더가 존재하는 경우 삭제
    //     directory = await Directory(message['clientPath']).delete(recursive: true);
    //   }
    // }else{
    //   directory = await Directory(message['clientPath']).create(recursive: true);
    // }
    if(message["subDiv"] == "DEL" || message["subDiv"] == "MODI"){ //디렉토리 삭제 메시지, MODI(폴더명변경도)도 일단 삭제 후 변경된 폴더명으로 새로 만들고 파일은 다시 다운로드 됨
      if(message["subDiv"] == "DEL") {
        if(await Directory(message['clientPath']).exists()==true) {
          directory = await Directory(message['clientPath']).delete(recursive: true);
        }
      }else {
        if(await Directory(message['beforeDirectoryName']).exists()==true) {
          directory = await Directory(message['beforeDirectoryName']).delete(recursive: true);
        }
        directory = await Directory(message['clientPath']).create(recursive: true);
      }
      message['result'] = 'SUCCESS';
    }else{  //폴더 생성
      directory = await Directory(message['clientPath']).create(recursive: true);
      message['result'] = 'SUCCESS';
    }

    directoryCreatedCnt++;
    notifyToSvrFileIOWork(channel, message);
    //print("directory 생성개수 --> $directoryCreatedCnt");
  }catch(e, s){
    print("Directory 생성 중 오류 발생 !!!");
    //print('e.runtimeType-->' + e.runtimeType.toString());
    print(message['divison']);
    print(message['clientFilePath']);
    //print('Exception details:\n $e');
    //print('message-->' + message.toString());
    //print('Stack trace:\n $s');
    message['result'] = 'FAIL';
    message['exception'] = e.toString();
    logger.d("Directory 생성 중 오류 발생 !!! ==> " + e.toString());
    logger.d("Directory 생성 중 오류 발생 !!! ==> " + message['clientPath']);
    notifyToSvrFileIOWork(channel, message);
  }
}

void notifyToSvrFileIOWork(WebSocketChannel channel, Map<String, dynamic> message) async{
  try {
    print("notify starting");
    Map<String, dynamic> retMsg ={};

    retMsg['division'] = message['division'];
    retMsg['repairShopNo'] = message['repairShopNo'];
    retMsg['reqNo'] = message['reqNo'];
    retMsg['fileNo'] = message['fileNo']??'';
    retMsg['result'] = message['result'];
    retMsg['exception']=message['exception']??'';

    String msgStr = jsonEncode(retMsg);

    //print('msgStr ------------>' + msgStr);
    channel.sink.add(msgStr);
    //print('msgStr ------------>' + msgStr);
    if(message['division']=='DIRECTORY'){
      if(message["subDiv"] == "MODI"){
        print(message['beforeDirectoryName'] + "이 " + message['clientPath'] + "로 변경되었습니다");
        logger.d(message['beforeDirectoryName'] + "이 " + message['clientPath'] + "로 변경되었습니다");
      }else if(message["subDiv"] == "DEL"){
        print(message['clientPath'] + " 디렉토리 삭제 !!!!");
        logger.d(message['clientPath'] + " 디렉토리 삭제 !!!!");
      }else{
        print(message['clientPath'] + " 디렉토리 생성 !!!!");
        logger.d(message['clientPath'] + " 디렉토리 생성 !!!!");
      }
    }else{
      print(message['clientPath'] + " 파일 생성 !!!!");
      logger.d(message['clientPath'] + " 파일 생성 !!!!");
    }
  }catch(e, s){
    print('error 발생한 메시지============>');
    print(message.toString());
    print(message['divison']);
    print(message['clientPath']);

    logger.d("서버로 메시지 송신 중 에러 발생 ==> " + e.toString());
    logger.d("서버로 메시지 송신 중 에러 발생 clientFilePath ==> " + message['clientFilePath']);
    //print('e.runtimeType-->' + e.runtimeType.toString());
    //print('Exception details:\n $e');
    //print('message-->' + message.toString());
    //print('Stack trace:\n $s');
  }
}