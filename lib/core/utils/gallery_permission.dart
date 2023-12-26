// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryPermission {
  Future<PermissionStatus> galleryPermission(BuildContext context) async {
    if (Platform.isIOS) {
      PermissionStatus permission = await Permission.photos.status;
      if (permission == PermissionStatus.permanentlyDenied) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Photos Permission"),
            content: const Text(
                "Photos permission should be granted to use this feature, would you like to go to app settings to give photos permission?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Color(0xFF2E86C1),
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Settings",
                  style: TextStyle(
                    color: Color(0xFF2E86C1),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
        PermissionStatus permissionStatus = await Permission.photos.request();
        return permissionStatus;
      } else if (permission != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.photos.request();
        return permissionStatus;
      } else {
        return permission;
      }
    } else {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        PermissionStatus permission = await Permission.storage.status;
        if (permission != PermissionStatus.granted &&
            permission != PermissionStatus.permanentlyDenied) {
          PermissionStatus permissionStatus =
              await Permission.storage.request();
          return permissionStatus;
        } else if (permission == PermissionStatus.permanentlyDenied) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Storage Permission"),
              content: const Text(
                  "Storage permission should be granted to use this feature, would you like to go to app settings to give storage permission?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF2E86C1),
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Settings",
                    style: TextStyle(
                      color: Color(0xFF2E86C1),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
          PermissionStatus permissionStatus =
              await Permission.storage.request();
          return permissionStatus;
        } else {
          return permission;
        }
      } else {
        PermissionStatus permission = await Permission.photos.status;
        if (permission != PermissionStatus.granted &&
            permission != PermissionStatus.permanentlyDenied) {
          PermissionStatus permissionStatus = await Permission.photos.request();
          return permissionStatus;
        } else if (permission == PermissionStatus.permanentlyDenied) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Photos Permission"),
              content: const Text(
                  "Photos permission should be granted to use this feature, would you like to go to app settings to give photos permission?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF2E86C1),
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Settings",
                    style: TextStyle(
                      color: Color(0xFF2E86C1),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
          PermissionStatus permissionStatus = await Permission.photos.request();
          return permissionStatus;
        } else {
          return permission;
        }
      }
    }
  }
}
