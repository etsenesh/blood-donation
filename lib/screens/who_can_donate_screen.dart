import 'package:flutter/material.dart'; // Flutter material design
import 'package:fluttertoast/fluttertoast.dart'; // Toast notifications
import 'package:url_launcher/url_launcher.dart'; // URL launcher for external links

import '../../common/app_config.dart'; // App configuration (e.g., external links)
import '../../common/colors.dart'; // Custom colors
import '../../data/info_group.dart'; // Data model for info groups
import '../../widgets/action_button.dart'; // Custom button widget

class WhoCanDonateScreen extends StatelessWidget {
  static const route = 'who-can-donate'; // Route name for navigation
  const WhoCanDonateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: MainColors.primary); // Title text style

    return Scaffold(
      appBar: AppBar(title: const Text('Who Can Donate Blood?')), // App bar with title
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display info groups in expansion tiles
              ...InfoGroup.whoCanDonate.map(
                (g) => ExpansionTile(
                  title: Text(g.title, style: titleStyle), // Group title
                  initiallyExpanded: g.id == 0, // Expand the first group by default
                  children: g.info
                      .map(
                        (c) => ListTile(
                          leading: const Icon(Icons.bookmark), // List item icon
                          title: Text(c), // List item text
                        ),
                      )
                      .toList(),
                ),
              ),

              // Learn More button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ActionButton(
                  key: const Key('learn_more_button'),
                  callback: () async {
                    // Launch external link
                    if (await canLaunchUrl(Uri.parse(AppConfig.bloodDonationInfoLink))) {
                      await launchUrl(Uri.parse(AppConfig.bloodDonationInfoLink));
                    } else {
                      Fluttertoast.showToast(msg: 'Could not launch the link');
                    }
                  },
                  text: 'Learn More', // Button text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}