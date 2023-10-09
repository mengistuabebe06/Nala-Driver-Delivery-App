import 'package:NalaDelivery/src/controller/home_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'shimmer.dart';

String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays >= 365) {
    final years = (difference.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  } else if (difference.inDays >= 30) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months == 1 ? '' : 's'} ago';
  } else if (difference.inDays >= 7) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  } else {
    return 'just now';
  }
}

class DeliveriesBottomSheet extends StatelessWidget {
  DeliveriesBottomSheet({super.key});

  final GlobalKey<FormState> myFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Deliveries",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Adjust the font size as needed
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.sort_rounded,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 22,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // Add some spacing
            SizedBox(
              height: 500, // Adjust the height as needed
              child: ListOfCategories(
                  w: w), // Assuming this widget is correctly implemented
            ),
          ],
        ),
      ),
    );
  }
}

class ListOfCategories extends StatelessWidget {
  const ListOfCategories({
    super.key,
    required double w,
  }) : _w = w;

  final double _w;

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return FutureBuilder(
        future: homeController.getHistory(),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while the future is waiting
            return ListView.builder(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(10),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: ShimmerWidgets.rectangular(
                        height: 300.h,
                        width: 310.w,
                        baseColor: Colors.grey[400]!,
                        highlightColor: Colors.grey[100]!),
                  );
                });
          } else {
            // When the future is done, check if it has an error or not
            if (snapshot.hasError) {
              // Show an error message if the future has an error
              return Text('Error: ${snapshot.error}');
            }
          }
          // If the future is successful, but empty then show a message
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50.h),
                  Icon(
                    Icons.event_busy,
                    size: 150.w,
                    color: Colors.grey[400],
                  ),
                  Text('No Deliveries Yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            );
          }
          // If the future is successful, display the booked tickets
          return ListView.builder(
            padding: EdgeInsets.all(_w / 35),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              String timestamp = snapshot.data![index]['created_at'];

              // Parse the given timestamp into a DateTime object
              DateTime parsedTime = DateTime.parse(timestamp);

              // Format the remaining time using the timeago package
              String remainingTime = formatTimeAgo(parsedTime);

              return Ticket(
                  w: _w,
                  remainingTime: remainingTime,
                  snapshot: snapshot,
                  index: index);
            },
          );
        });
  }
}

class Ticket extends StatelessWidget {
  const Ticket({
    super.key,
    required double w,
    required this.remainingTime,
    required this.snapshot,
    required this.index,
  }) : _w = w;

  final double _w;
  final String remainingTime;
  final AsyncSnapshot snapshot;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Get.find<HomeController>().getSnack(snapshot.data![index]);
        showDeliveryDetailsPopup(context, snapshot.data![index]);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: _w / 30,
        ),
        height: _w / 4,
        decoration: BoxDecoration(
          color: snapshot.data![index]['status'] == "Delivered"
              ? Colors.green[900]!.withOpacity(0.7)
              : snapshot.data![index]['status'] == "Accepted"
                  ? Colors.yellow[900]!.withOpacity(0.7)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.8),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: _w / 4,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: CachedNetworkImage(
                  imageUrl:
                      "https://cdn.vectorstock.com/i/preview-1x/25/51/delivery-order-flat-style-logo-vector-47762551.jpg"),
            ),
            Container(
              margin: EdgeInsets.only(left: _w / 20, top: _w / 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 190),
                    child: Text(
                      "Product: ${snapshot.data![index]['products'][0]['product']['name']}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _w / 29,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Text(
                    "Delivery To: ${snapshot.data![index]['deliverTo']}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _w / 31,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    remainingTime,
                    style: TextStyle(
                      fontSize: _w / 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300],
                    ),
                  ),
                  Chip(text: "${snapshot.data![index]['status']}", size: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Chip extends StatelessWidget {
  const Chip({
    super.key,
    required this.text,
    required this.size,
  });
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.25),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class DeliveryDetailsPopup extends StatelessWidget {
  final Map<String, dynamic> deliveryData;

  const DeliveryDetailsPopup({Key? key, required this.deliveryData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      insetPadding: const EdgeInsets.all(18),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    final products = deliveryData['products'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Details',
            style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          buildInfoRow('ORDER ID : ', '${deliveryData['orderId']}'),
          buildInfoRow('USER ID : ', '${deliveryData['userId']}'),
          buildInfoRow('CREATED AT : ', '${deliveryData['created_at']}'),
          buildInfoRow('STATUS : ', '${deliveryData['status']}'),
          buildInfoRow('DELIVER TO : ', '${deliveryData['deliverTo']}'),
          buildInfoRow('FEE : ', '${deliveryData['fee']}'),
          const SizedBox(height: 16.0),
          const Text(
            'PRODUCTS:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: products.map<Widget>((product) {
              return Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                margin: const EdgeInsets.only(top: 3, left: 16),
                child: buildInfoRow(
                  '    ${product['product']['name']}',
                  'Price: ${product['product']['price']}',
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (deliveryData['accepted'])
                TextButton(
                  onPressed: () {
                    Get.find<HomeController>().setDelivered(deliveryData);
                    Navigator.pop(context);
                    Get.back();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const SuccessModal();
                      },
                    );
                  },
                  child: const Text('Mark as Delivered'),
                )
              else
                TextButton(
                  onPressed: () {
                    Get.find<HomeController>().getSnack(deliveryData);
                    Navigator.pop(context);
                    Get.back();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AcceptedModal(
                          deliverTo: deliveryData['deliverTo'],
                        );
                      },
                    );
                  },
                  child: const Text('Accept'),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Chip(
              text: value,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
}

void showDeliveryDetailsPopup(
    BuildContext context, Map<String, dynamic> deliveryData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return DeliveryDetailsPopup(deliveryData: deliveryData);
    },
  );
}

class SuccessModal extends StatelessWidget {
  const SuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64.0,
          ),
          SizedBox(height: 16.0),
          Text(
            'Great Successfully Delivered',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('OK', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}

class AcceptedModal extends StatelessWidget {
  const AcceptedModal({super.key, required this.deliverTo});
  final deliverTo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            color: Colors.green,
            size: 64.0,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Accepted, Delivery to $deliverTo',
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('OK', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}
