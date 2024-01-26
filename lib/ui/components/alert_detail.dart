// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:ndvpn/core/resources/colors.dart';
// import 'package:ndvpn/core/utils/utils.dart';
// import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../core/resources/environment.dart';
// import 'custom_card.dart';
// import 'custom_divider.dart';

// class AlertScreen extends StatelessWidget {
//   final String message;
//   final bool exit;
//   const AlertScreen({super.key, required this.message, required this.exit});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: CustomCard(
//         padding: const EdgeInsets.all(20.0),
//         margin: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               appName,
//               style: Theme.of(context)
//                   .textTheme
//                   .headlineSmall!
//                   .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             FutureBuilder<PackageInfo>(
//               future: PackageInfo.fromPlatform(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return Text("version",
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context)
//                               .textTheme
//                               .bodySmall!
//                               .copyWith(fontWeight: FontWeight.bold))
//                       .tr(args: [snapshot.data!.version]);
//                 } else {
//                   return const SizedBox.shrink();
//                 }
//               },
//             ),
//             const ColumnDivider(space: 10),
//             Text(
//               message,
//               textAlign: TextAlign.justify,
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//             const ColumnDivider(space: 10),
//             SizedBox(
//               height: 50,
//               child: TextButton(
//                 onPressed: () {
//                   if (exit) {
//                     closeScreen(context);
//                     startScreen(context, const LoginScreen());
//                   } else {
//                     closeScreen(context);
//                   }
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: primaryColor,
//                   backgroundColor: primaryColor.withOpacity(0.1),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: const Text("OK"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
