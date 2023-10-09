import 'dart:async';
import 'dart:io';
import 'package:NalaDelivery/src/controller/home_controller.dart';
import 'package:NalaDelivery/src/screens/deliveries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final Completer<GoogleMapController> controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());

    return Scaffold(
      // bottom floating button
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(35, 0, 8, 50),
        child: Row(
          children: [
            true
                ? Container(
                    margin: const EdgeInsets.only(left: 10, right: 20),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20)),
                    child: IconButton(
                      onPressed: () {
                        controller.getCurrentLocation().then((value) {
                          controller.lat = value.latitude;
                          controller.long = value.longitude;
                          controller.update();
                        });
                      },
                      icon: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 80.r,
                      ),
                    ),
                  )
                // ignore: dead_code
                : const SizedBox(),
            Expanded(
              child: SizedBox(
                height: 180.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.bottomSheet(
                      DeliveriesBottomSheet(),
                      shape: Get.theme.bottomSheetTheme.shape,
                      isScrollControlled: true,
                      clipBehavior: Clip.hardEdge,
                      useRootNavigator: true,
                      enableDrag: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      maximumSize: Size.fromHeight(180.h)),
                  child: Text(
                    "Deliveries",
                    style: TextStyle(
                        fontSize: 60.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.7,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontFamily: "Inter"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 2100.h,
              child: Platform.isAndroid
                  ? GetBuilder<HomeController>(builder: (controller) {
                      return GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(controller.lat, controller.long),
                          zoom: 20.4746,
                        ),
                        myLocationButtonEnabled: true,
                        markers: controller.markers,
                        polylines: controller.polylines,
                        onMapCreated: (GoogleMapController ctrl) {
                          if (!controller.tController.isCompleted) {
                            controller.tController.complete(ctrl);
                          }
                        },
                      );
                    })
                  : const SizedBox(
                      height: 500,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
