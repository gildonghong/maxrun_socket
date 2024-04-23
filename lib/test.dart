import 'dart:io';


void main(){
  
  var dir = Directory("C:\\temp2\\TEST");

  dir.delete(recursive: true);
}