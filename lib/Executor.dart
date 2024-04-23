import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Executor.dart';

void main(){
  Map<String, dynamic> param = {"loginId":"1_manager", "loginpwd":"1_manager"};
  Future<List<dynamic>> lst = getList(endPoint: "http://www.maxrunphoto.com/login", param: param) as Future<List<dynamic>>;
}

Future<Map<String, dynamic>?> login({required String endPoint, Map<String, dynamic>? param}) async{
  try{
    String queryString = _getQueryString(param);
    endPoint = endPoint + queryString;
    print("queyrString==>" + queryString);
    print("endPoint==>" + endPoint);

    http.Response _response = await http.get( Uri.parse(endPoint));
    print("_response.statusCode:${_response.statusCode}");
    print(_response.statusCode);
    if (_response.statusCode == 200 || _response.statusCode == 201) {
      Map<String,dynamic> _data = jsonDecode(_response.body);
      print("resultset===>");
      print(_data);
      return _data;
    } else {
      print(111111111);
      //Map<String,dynamic> _data = jsonDecode(_response.body);
      print(222222222);
      return null;
    }
  }catch(error){
    print(error.runtimeType);
    if(error.runtimeType.toString() == "_ClientSocketException"){
      return {"exception":"네트워크 에러가 발생했습니다. 잠시 후 다시 시도해주십시오!!! 지속적으로 문제가 발생할 시 맥스런 본사로 연락주십시오"};
    }
    print(error);
    return {};
  }
}

Future<List<dynamic>> getList({ required String endPoint,
                                Map<String, dynamic>? param}) async {
  try {
    String queryString = _getQueryString(param);
    endPoint = endPoint + queryString;

    print("queyrString==>" + queryString);
    print("endPoint==>" + endPoint);

    http.Response _response = await http.get( Uri.parse(endPoint));
    if (_response.statusCode == 200 || _response.statusCode == 201) {
      List<dynamic> _data = jsonDecode(_response.body);
      print("resultset===>");
      print(_data);
      return _data;
    } else {
      return [];
    }
  } catch (error) {
    print(error);
    return [];
  }
}

String _getQueryString(Map<String, dynamic>? param){
  String  queryString="";

  param?.forEach((key, value) {
    queryString = queryString==""?"?":queryString + "&";
    queryString += key + '=' + value.toString();
  });

  return queryString;
}