import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> askPermission(String s) async {
  if (s == 'Camera') {
    var cameraAccess = await Permission.camera.status;
    debugPrint('cameraAccess=$cameraAccess');
    if (!cameraAccess.isGranted) {
      await Permission.camera.request();
    }
    if(cameraAccess.isGranted) {
      return true;
    }
  }
  else {
    var galleryAccess = await Permission.storage.status;
    debugPrint('galleryAccess=$galleryAccess');
    if (!galleryAccess.isGranted) {
      await Permission.storage.request();
    }
    if (galleryAccess.isGranted) {
      return true;
    }
  }
  return false;
}