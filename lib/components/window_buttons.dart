import 'dart:io';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:adb_gui/utils/vars.dart';
import 'package:system_theme/system_theme.dart';

import '../utils/const.dart';

class CustomMinimizeWindowButton extends MinimizeWindowButton{
  CustomMinimizeWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){

    return WindowMaterialButton(
      // buttonColor: Colors.blue,
      hoverColor: SystemTheme.accentColor.accent,
      buttonIcon: Icon(Icons.minimize,color: Theme.of(context).brightness == Brightness.dark?Colors.white:kLightModeAppBarTitleColor,),
      onPressed: super.onPressed!,
    );
  }


}

class CustomMaximizeWindowButton extends MaximizeWindowButton{
  CustomMaximizeWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return WindowMaterialButton(
      // buttonColor: Colors.blue,
      hoverColor: SystemTheme.accentColor.accent,
      buttonIcon: Icon(Icons.check_box_outline_blank,color: Theme.of(context).brightness == Brightness.dark?Colors.white:kLightModeAppBarTitleColor,),
      onPressed: super.onPressed!,
    );
  }
}

class CustomCloseWindowButton extends CloseWindowButton{
  CustomCloseWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return WindowMaterialButton(
      // buttonColor: Colors.blue,
      hoverColor: Colors.redAccent,
      darkModeHoverColor: Colors.redAccent,
      buttonIcon: Icon(Icons.close,color: Theme.of(context).brightness == Brightness.dark?Colors.white:kLightModeAppBarTitleColor,),
      onPressed: () async{
        if((await getKillADBOnExitPreference())!){
          await Process.run(adbExecutable, ["kill-server"],runInShell: true);
          if(Platform.isWindows){
            await Process.run("taskkill", ["/IM","adb.exe","/F"],runInShell: true);
          }
        }
        super.onPressed!();
      },
    );
  }
}


class WindowMaterialButton extends StatelessWidget {

  // final Color? buttonColor;
  final Color? hoverColor;
  final Color? darkModeHoverColor;
  final Icon buttonIcon;
  final Color? buttonColor;
  final VoidCallback onPressed;

  const WindowMaterialButton({Key? key,this.hoverColor=Colors.black26, this.darkModeHoverColor=Colors.black26,required this.buttonIcon, this.buttonColor = Colors.transparent,required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const CircleBorder(),
      color: buttonColor,
      elevation: 0,
      minWidth: 8,
      hoverColor: Theme.of(context).brightness==Brightness.light?hoverColor:darkModeHoverColor,
      height: 150,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: buttonIcon,
      ),
    );
  }
}
