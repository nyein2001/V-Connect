import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndvpn/core/utils/gallery_permission.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/register_screen/register_screen.dart';
import 'package:permission_handler/permission_handler.dart';
part 'mixin/edit_profile_mixin.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen>
    with _EditProfileMixin {
  final ImagePicker picker = ImagePicker();
  bool isnetworkimage = false;
  File? image;
  bool isValidate = false;
  String profileImage = "";

  @override
  Widget build(BuildContext context) {
    var themehandler = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Column(
          children: [
            Text("Edit Profile",
                style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600))
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Card(
          color: Theme.of(context).cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Stack(
                    children: [
                      if (isnetworkimage)
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                              child: CachedNetworkImage(
                                imageUrl: profileImage,
                                placeholder: (context, url) => Image.asset(
                                  "${AssetsPath.imagepath}user2.jpg",
                                  fit: BoxFit.cover,
                                  height: 130,
                                  width: 130,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "${AssetsPath.imagepath}user2.jpg",
                                  fit: BoxFit.cover,
                                  height: 130,
                                  width: 130,
                                ),
                                height: 130,
                                width: 130,
                              ),
                            ),
                          ),
                        ),
                      if (!isnetworkimage && image == null)
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                              child: Image.asset(
                                "${AssetsPath.imagepath}user2.jpg",
                                fit: BoxFit.cover,
                                height: 130,
                                width: 130,
                              ),
                            ),
                          ),
                        ),
                      if (!isnetworkimage && image != null)
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                              child: Image.file(
                                image ?? File(""),
                                fit: BoxFit.cover,
                                height: 130,
                                width: 130,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                          bottom: 2,
                          right: 4,
                          child: Visibility(
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Wrap(children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Camera'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_album),
                                      title: const Text('Gallery'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        if (Platform.isAndroid) {
                                          PermissionStatus permissionStatus =
                                              await GalleryPermission()
                                                  .galleryPermission(context);
                                          if (permissionStatus ==
                                              PermissionStatus.granted) {
                                            chooseImageFromGallery();
                                          }
                                        } else if (Platform.isIOS) {}
                                      },
                                    ),
                                  ]),
                                );
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: themehandler.primaryColor,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 45,
                ),
                Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        RegisterTextFormFieldWidget(
                          hintText: 'Enter Name',
                          prefixIcon: Icons.person,
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [
                            AutofillHints.name,
                            AutofillHints.givenName,
                            AutofillHints.familyName,
                            AutofillHints.middleName,
                            AutofillHints.nameSuffix,
                            AutofillHints.namePrefix
                          ],
                          textInputAction: TextInputAction.next,
                          validator: isNameValid,
                        ),
                        RegisterTextFormFieldWidget(
                          hintText: 'E-mail',
                          prefixIcon: Icons.email,
                          controller: emailController,
                          autofillHints: const [AutofillHints.email],
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.next,
                          validator: isEmailValid,
                        ),
                        RegisterTextFormFieldWidget(
                          hintText: 'Phone Number',
                          prefixIcon: Icons.phone,
                          controller: phoneController,
                          textCapitalization: TextCapitalization.none,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          autofillHints: const [AutofillHints.telephoneNumber],
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: isPhoneValid,
                        ),
                      ].map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: e.build(context),
                        );
                      }).toList(),
                    )),
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: double.infinity, // Set to maximum width
                  child: ElevatedButton(
                    onPressed: () async => await profileUpdate(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'SAVE',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> chooseImageFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        image = file;
        File? imageTempoary = image;

        imageTempoary = await _cropImage(imageFile: imageTempoary ?? File(""));

        setState(() {
          if (imageTempoary != null) {
            image = imageTempoary;
            isnetworkimage = false;
          }
        });
      } else {
        return;
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 50);

    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }
}
