import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controller/profile_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.find();
  final double coverHeight = 220;
  final double profileHeight = 80;
  final double maxHeight = 1000.h;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(fontSize: 70.sp, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  GetBuilder<ProfileController>(builder: (profileController) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    buildCoverImage(),
                    Positioned(
                      top: coverHeight - (profileHeight * 1.2),
                      left: 30,
                      child: biuldProfileImage(),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 20,
                      child: buildEditProfileIcon(context),
                    ),
                  ],
                );
              }),
            ),
            GetBuilder<ProfileController>(builder: (profileController) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  profileController.user?.name ?? "",
                  style: TextStyle(
                    fontSize: 65.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
            GetBuilder<ProfileController>(builder: (profileController) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 3),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 3),
                child: Text(
                  profileController.user?.email ?? "",
                  style: TextStyle(
                    fontSize: 45.sp,
                  ),
                ),
              );
            }),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SettingsGroup(
                settingsGroupTitle: "Account",
                settingsGroupTitleStyle: TextStyle(
                  fontSize: 80.sp,
                  fontWeight: FontWeight.bold,
                ),
                items: [
                  SettingsItem(
                    onTap: () {
                      // Dialog
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      profileController.logout();
                                      Get.back();
                                    },
                                    child: const Text('Yes')),
                                TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text('No')),
                              ],
                            );
                          });
                    },
                    icons: Icons.exit_to_app_rounded,
                    title: "Log Out",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditProfileIcon(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(220),
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: () {
          profileController.coverPic = null;
          profileController.profilePic = null;
          profileController.name.text = profileController.user!.name;
          profileController.phoneNumber.text =
              profileController.user!.phoneNumber;
          profileController.name.text = '';
        },
        icon: Icon(
          Icons.edit,
          size: 15,
          color: Theme.of(context).colorScheme.background,
        ),
      ),
    );
  }

  Widget buildCoverImage() {
    return Container(
      height: coverHeight,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            alignment: Alignment.topCenter,
            image: CachedNetworkImageProvider(
              'https://wallpaperaccess.com/full/3787594.jpg',
            ),
          )),
    );
  }

  Widget biuldProfileImage() {
    return profileController.user == null
        ? const CircleAvatar(
            radius: 40,
            backgroundImage: CachedNetworkImageProvider(
                'https://img.freepik.com/free-icon/user_318-159711.jpg'))
        : !profileController.user!.profilePic
                .startsWith("https://api.dicebear.com")
            ? CircleAvatar(
                radius: 40,
                backgroundImage: CachedNetworkImageProvider(profileController
                        .user!.profilePic ??
                    'https://img.freepik.com/free-icon/user_318-159711.jpg'))
            : const CircleAvatar(
                radius: 40,
                backgroundImage: CachedNetworkImageProvider(
                    'https://img.freepik.com/free-icon/user_318-159711.jpg'));
  }
}
