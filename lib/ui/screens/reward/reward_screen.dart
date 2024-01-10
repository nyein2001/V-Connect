import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/get_req_with_userid.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/network_available.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/reward/fragment/reward_current_fragment.dart';
import 'package:ndvpn/ui/screens/reward/fragment/withdrawal_history_fragment.dart';
part 'mixin/reward_mixin.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => RewardScreenState();
}

class RewardScreenState extends State<RewardScreen>
    with _RewardScreenMixin, TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("reward").tr(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rewardDisplayWidget(context),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'current_point'.tr()),
                      Tab(text: 'withdrawal_history'.tr()),
                    ],
                  ),
                  backgroundColor: Colors.transparent,
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: const [
                    RewardCurrentFragment(),
                    WithdrawalHistoryFragment(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardDisplayWidget(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 150,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You Have ',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    totalPoint,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    ' Reward Point',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Text(
              money,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Visibility(
                visible: totalPoint != "0",
                child: ElevatedButton(
                  onPressed: () async => await rewardPointClaim(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff69D54B),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: Text('reward_point_claim',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600))
                      .tr(),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> rewardPointClaim() async {}
}
