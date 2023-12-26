import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/resources/themes.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/edit_profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          textAlign: TextAlign.center,
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.all(20.0),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                            child: CachedNetworkImage(
                              imageUrl: endpoint,
                              placeholder: (context, url) => Image.asset(
                                "${AssetsPath.imagepath}user2.jpg",
                                fit: BoxFit.cover,
                                height: 120,
                                width: 120,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "${AssetsPath.imagepath}user2.jpg",
                                fit: BoxFit.cover,
                                height: 120,
                                width: 120,
                              ),
                              height: 120,
                              width: 120,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Naing  Thura  Kyaw',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  startScreen(
                                      context, const EditProfileScreen());
                                },
                                child: const Icon(
                                  Icons.edit,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text('naingthurakyaw6@gmail.com',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Account Type:',
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w400)),
                      Text('Free',
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600))
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
