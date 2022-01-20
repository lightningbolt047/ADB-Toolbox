import 'dart:io';

import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/models/item.dart';
import 'package:adb_gui/services/string_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:adb_gui/utils/vars.dart';
import 'android_api_checks.dart';
import 'file_services.dart';

class ADBService{
  final Device device;

  ADBService({required this.device});

  Future<List<Item>> getDirectoryContents(String currentPath) async {
    ProcessResult result;
    if(isPreMarshmallowAndroid(device.androidAPILevel)){
      result=await Process.run(adbExecutable, ["-s", device.id, "shell", "ls", "\"$currentPath\""]);
    }else{
      result=await Process.run(adbExecutable, ["-s", device.id, "shell", "ls","-l","-p", "\"$currentPath\""]);
    }
    // result=await Process.run(adbExecutable, ["-s", deviceID, "shell", "ls","-p", "\"$_currentPath\""]);
    List<String> directoryContentDetails = (result.stdout).split("\n");
    directoryContentDetails.removeAt(0);
    directoryContentDetails.removeLast();
    List<Item> directoryItems=[];
    directoryContentDetails=getTrimmedStringList(directoryContentDetails);
    for(int i=0;i<directoryContentDetails.length;i++){
      List<String> directoryContent=directoryContentDetails[i].split(" ");
      directoryContent=getTrimmedStringList(directoryContent);
      print("This: "+directoryContent[9].toString());
      directoryItems.add(Item(directoryContent[9].endsWith("/")?directoryContent[9].replaceAll("/", ""):directoryContent[7],await getFileType(device:device,currentPath:currentPath,fileName:directoryContent[9])));
    }
    return directoryItems;
  }

  void deleteItem({required String itemPath,Function? beforeExecution, Function? onSuccess, Function? onFail}) async {
    if(beforeExecution != null){
      beforeExecution();
    }
    ProcessResult result = await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "rm",
      "-r",
      "\"$itemPath\""
    ]);
    if(result.exitCode == 0 && onSuccess!=null) {
      onSuccess();
    }
  }

  void uploadContent({required currentPath, required FileItemType uploadType, Function? onProgress}) async {
    String? sourcePath = await pickFileFolderFromDesktop(uploadType,uploadType==FileItemType.file?"Select File":"Select Directory");

    if (sourcePath == null) {
      return;
    }
    Process process = await Process.start(
      adbExecutable,
      ["-s", device.id, "push", sourcePath, currentPath],
    );
    if(onProgress!=null){
      onProgress(process,getDesktopFileSize,getFileItemSize,sourcePath,currentPath);
    }
  }

  Future<ProcessResult> executeLs(String path) async{
    return await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "ls",
      "\"$path\""
    ]);
  }

  Future<Process> fileCopy({required oldPath, required newPath}) async{
    Process process = await Process.start(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "cp",
      "-r",
      "\"$oldPath\"",
      "\"$newPath\""
    ]);
    return process;
  }

  Future<Process> fileMove({required oldPath, required newPath}) async{
    Process process = await Process.start(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "mv",
      "\"$oldPath\"",
      "\"$newPath\""
    ]);
    return process;
  }

  Future<ProcessResult> fileRename({required oldPath,required newPath}) async{
    return await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "mv",
      "\"$oldPath\"",
      "\"$newPath\""
    ]);
  }

  void downloadContent({required String itemPath,Function? onProgress}) async {
    String? chosenDirectory = await pickFileFolderFromDesktop(FileItemType.directory,"Where to download");

    if (chosenDirectory == null) {
      return;
    }
    Process process = await Process.start(adbExecutable, ["-s", device.id, "pull", itemPath, chosenDirectory]);
    if(onProgress!=null){
      onProgress(process,getFileItemSize,getDesktopFileSize,itemPath,chosenDirectory);
    }
  }

  Future<int> getFileItemSize(String filePath) async{
    ProcessResult processResult=await Process.run(adbExecutable, ["-s",device.id,"shell","du","-s","\"$filePath\""]);
    return int.parse(processResult.stdout.toString().split("\t")[0]);
  }
  
  Future<List<String>> getUserPackageNames() async{
    List<String> arguments=["-s",device.id,"shell","pm","list","packages","-3"];
    if(isPreIceCreamSandwichAndroid(device.androidAPILevel)){
      arguments.removeLast();
    }
    ProcessResult result=await Process.run(adbExecutable, arguments);
    List<String> packageNames=result.stdout.toString().split("\n");
    packageNames.removeLast();
    for(int i=0;i<packageNames.length;i++){
      packageNames[i]=packageNames[i].split(":")[1];
      packageNames[i]=packageNames[i].trim();
    }
    return packageNames;
  }

  Future<List<String>> getSystemPackageNames() async{
    ProcessResult result=await Process.run(adbExecutable, ["-s",device.id,"shell","pm","list","packages","-s"]);
    List<String> packageNames=result.stdout.toString().split("\n");
    packageNames.removeLast();
    for(int i=0;i<packageNames.length;i++){
      packageNames[i]=packageNames[i].split(":")[1];
      packageNames[i]=packageNames[i].trim();
    }
    return packageNames;
  }

  Future<void> forceStopPackage(String packageName) async{
    await Process.run(adbExecutable, ["-s",device.id,"shell","am","force-stop",packageName]);
  }

  Future<int> uninstallApp(String packageName) async{
    ProcessResult result=await Process.run(adbExecutable, ["-s",device.id,"uninstall",packageName]);
    return result.exitCode;
  }


}