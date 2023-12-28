import 'dart:io';

class PhotoUploadReq {
  PhotoUploadReq({
    required this.file,
    required this.url,
  });
  late final File file;
  String url;

  factory PhotoUploadReq.fromJson(Map<String, dynamic> json) => PhotoUploadReq(
        file: json["file"],
        url: json["url"],
      );
  Map<String, dynamic> toJson() => {
        "file": file,
        "url": url,
      };
}
