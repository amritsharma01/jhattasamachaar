import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  AboutUsPage({Key? key}) : super(key: key);

  final List<Map<String, String>> teamMembers = [
    {
      'name': 'Amrit Sharma',
      'email': 'amritsharma1027@gmail.com',
      'image': 'lib/assets/images/amrit.jpg',
      'facebook': 'https://www.facebook.com/profile.php?id=100007365211859',
      'github': 'https://github.com/amritsharma01',
      'linkedin': 'https://linkedin.com/in/johndoe',
      'website': 'https://www.sharmaamrit.com.np', // Added website
    },
    {
      'name': 'Darpan Kattel',
      'email': 'darpankattel1@gmail.com', // Updated email
      'image': 'lib/assets/images/darpan.jpg',
      'facebook': 'https://facebook.com/darpan.kattel',
      'github': 'https://github.com/darpankattel',
      'linkedin': 'https://linkedin.com/in/darpankattel',
      'website': 'https://www.darpankattel.com.np', // Added website
    },
    {
      'name': 'Kripesh Nihure',
      'email': 'kripeshnihure@gmail.com', // Updated email
      'image': 'lib/assets/images/kripesh.jpg',
      'facebook': 'https://facebook.com/kripeshnihure',
      'github': 'https://github.com/kripeshnihure',
      'linkedin': 'https://linkedin.com/in/kripeshnihure',
      'website': 'https://www.kripeshnihure.com.np', // Added website
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'About Us',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView.builder(
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          return _buildTeamCard(teamMembers[index], context);
        },
      ),
    );
  }

  Widget _buildTeamCard(Map<String, String> member, BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                member['image']!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 120),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              member['name']!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              member['email']!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                    SimpleIcons.facebook, member['facebook']!, context),
                _buildSocialIcon(
                    SimpleIcons.github, member['github']!, context),
                _buildSocialIcon(
                    SimpleIcons.linkedin, member['linkedin']!, context),
                _buildSocialIcon(SimpleIcons.googleearth, member['website']!,
                    context), // Added website icon
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData iconData, String url, BuildContext context) {
    return IconButton(
      icon: Icon(iconData),
      color: Theme.of(context).colorScheme.onPrimary,
      iconSize: 25,
      onPressed: () => _launchURL(url),
    );
  }

  // Ensure URLs can be launched
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
