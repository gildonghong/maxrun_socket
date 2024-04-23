import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black12,
        body: Container(
          child: LoginApp(),
        ),
        appBar: AppBar(backgroundColor: Colors.blueGrey,
          title: Text("LogIn", style: TextStyle(color: Colors.white),),
        ),
      ),
      title: "LogIn",
    );
  }
}


class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final _formKey = GlobalKey<FormState>();
  String? _id;
  String? _pwd;

  static double getScaleHeight(BuildContext context){
    double realHeight = MediaQuery.of(context).size.height;

    return realHeight;
  }

  void popMessage(){
    showDialog( context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text("Warming"),
            content: const Text("Warning Dialog Message"),
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
    return LayoutBuilder(
        builder: (context, constraint){
          return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                      children:[
                        Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5.0, top:5.0, bottom: 70),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                border: Border.all(style: BorderStyle.solid,
                                  color: Colors.white,
                                  width: 5,
                                ),
                              ),
                              width: double.infinity,
                              height: 100,
                              child: const Center(child: Text("MAX-RUN",style: TextStyle(color: Colors.white, fontSize:39.0))),
                            )
                        ),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "ID",
                                    labelStyle: TextStyle(color: Colors.white),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  validator: (String? value){
                                    if(value?.isEmpty ?? false){
                                      return "Please enter your ID";
                                    }
                                    return null;
                                  },
                                  onSaved: (String? value){
                                    _id = value;
                                  },
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(color: Colors.white),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  validator: (value){
                                    if(value?.isEmpty ?? false){
                                      return "Please enter password";
                                    }
                                    return null;
                                  },
                                  onSaved: (String? value){
                                    _pwd = value;
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 50.0,
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: ElevatedButton(
                                onPressed: (){
                                  if(_formKey.currentState?.validate() ?? false){
                                    _formKey.currentState?.save();
                                    popMessage();
                                  }
                                },
                                style: ButtonStyle(
                                    backgroundColor:MaterialStateProperty.all(Colors.blueGrey)
                                ),
                                child: const Text(
                                    "LogIn"
                                )),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          child: Text("(주)맥스런 /대표이사 김우겸 / 사업자등록번호 556-86-00899 경기도 파주시 월롱면 휴암로 79번길 62-24 / 고객센터 : 1688-4294 이메일: ADMIN@MAXRUN.COM",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ]
                  ),
                ),
              )
          );
        }
    );
  }
}
