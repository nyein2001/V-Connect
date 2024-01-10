import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/earn_point.dart';
import 'package:ndvpn/core/models/points_details_req.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/network_available.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
part 'mixin/earn_point_mixin.dart';

class EarnPointScreen extends StatefulWidget {
  const EarnPointScreen({super.key});

  @override
  State<EarnPointScreen> createState() => EarnPointScreenState();
}

class EarnPointScreenState extends State<EarnPointScreen> with _EarnPointMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("earn_point").tr(),
        automaticallyImplyLeading: true,
        centerTitle: false,
      ),
      body: noData
          ? const Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            child: Icon(
                          Icons.not_listed_location,
                          size: 80,
                          color: Colors.blue,
                        )),
                        SizedBox(height: 16),
                        Text(
                          'Empty Withdrawal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Looks like there are no withdrawal to display.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                EarnPoint rewardPoint = earnPointLists[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: '',
                        placeholder: (context, url) => Image.asset(
                          "${AssetsPath.iconpath}logo_android.png",
                          fit: BoxFit.cover,
                          height: 125,
                          width: 125,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          "${AssetsPath.iconpath}logo_android.png",
                          fit: BoxFit.cover,
                          height: 125,
                          width: 125,
                        ),
                        imageBuilder: (context, imageProvider) => Container(
                          height: 125,
                          width: 125,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        height: 125,
                        width: 125,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rewardPoint.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          rewardPoint.points,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.all(12),
                  // subtitle: Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.baseline,
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       textBaseline: TextBaseline.alphabetic,
                  //       children: [
                  //         Text(
                  //           "${rewardPoint.date} - ${rewardPoint.time}",
                  //           overflow: TextOverflow.fade,
                  //           softWrap: false,
                  //           style: const TextStyle(
                  //               fontWeight: FontWeight.w400, fontSize: 14),
                  //         ),
                  //         Text(
                  //           rewardPoint.activityType,
                  //           overflow: TextOverflow.fade,
                  //           softWrap: false,
                  //           style: const TextStyle(
                  //               fontSize: 14, color: Color(0xfff20056)),
                  //         ),
                  //       ],
                  //     ),
                  //     const Text('Points'),
                  //   ],
                  // ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemCount: earnPointLists.length),
    );
  }
}
