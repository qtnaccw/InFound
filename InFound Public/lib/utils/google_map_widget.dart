import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infound/components/buttons.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/styles.dart';

class GoogleMapsWidget extends StatefulWidget {
  final Function(String, String) onSubmit;
  final LatLng initialLatLng;
  final double initialRadius;
  final bool clickable;
  const GoogleMapsWidget(
      {super.key, required this.onSubmit, required this.initialLatLng, this.clickable = true, this.initialRadius = 50});

  @override
  State<GoogleMapsWidget> createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  late GoogleMapController googleMapController;
  TextEditingController descriptionController = TextEditingController();
  double radius = 0;
  String address = '';

  final api = GoogleGeocodingApi('AIzaSyBEeDVDloZFew4-p-UGOBG9vPVQU9YBYk8', isLogged: false);

  late CameraPosition initialPosition;
  late Marker centerPoint;

  Future getAddress(LatLng pos) async {
    try {
      final reversedSearchResults = await api.reverse(
        '${pos.latitude},${pos.longitude}',
        language: 'en',
      );

      var prettyAddress = reversedSearchResults.results.firstOrNull?.mapToPretty();
      if (prettyAddress == null) {
        return;
      } else {
        if (mounted)
          setState(() {
            address = "Around ${prettyAddress.address} within ${radius.toStringAsFixed(0)}m";
            descriptionController.text = address;
          });
      }
    } catch (e) {
      printDebug(e);
    }
  }

  Future mapChangePos(LatLng pos) async {
    try {
      if (mounted) {
        setState(() {
          centerPoint = Marker(
              markerId: MarkerId('center'),
              position: pos,
              draggable: widget.clickable,
              onDrag: (value) async {
                if (widget.clickable) {
                  await mapChangePos(value);
                }
              },
              onDragEnd: (value) async {
                if (widget.clickable) {
                  if (mounted) {
                    await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(target: centerPoint.position, zoom: getZoom(radius))));
                  }
                  await getAddress(value);
                }
              });
        });
      }
    } catch (e) {
      AppPopups.customToast(message: 'An error occurred changing pin position. Please try again.');
    }
  }

  Future mapOnTap(LatLng pos) async {
    if (widget.clickable == false) {
      return;
    }
    try {
      if (mounted) {
        setState(() {
          centerPoint = Marker(
              markerId: MarkerId('center'),
              position: pos,
              draggable: true,
              onDrag: (value) async {
                if (widget.clickable == false) {
                  await mapChangePos(value);
                  await getAddress(value);
                }
              },
              onDragEnd: (value) async {
                if (widget.clickable == false) {
                  await getAddress(value);
                }
              });
        });
      }
      if (mounted) {
        await googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(CameraPosition(target: centerPoint.position, zoom: getZoom(radius))));
      }
      await getAddress(pos);
    } catch (e) {
      AppPopups.customToast(message: 'An error occurred changing pin position. Please try again.');
    }
  }

  double getZoom(double radius) {
    double zoom = 20;
    if (radius <= 100) {
      zoom = 19;
    } else if (radius <= 200) {
      zoom = 18;
    } else if (radius <= 400) {
      zoom = 17;
    } else if (radius <= 800) {
      zoom = 16;
    } else if (radius <= 1600) {
      zoom = 15;
    } else if (radius <= 3200) {
      zoom = 14;
    } else {
      zoom = 13;
    }
    return zoom;
  }

  String getString() {
    return "(" +
        centerPoint.position.latitude.toString() +
        ', ' +
        centerPoint.position.longitude.toString() +
        ', ' +
        radius.toStringAsFixed(0) +
        'm)';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      initialPosition = CameraPosition(
        target: widget.initialLatLng,
        zoom: getZoom(widget.initialRadius),
      );
      radius = widget.initialRadius;
      mapChangePos(widget.initialLatLng);
      getAddress(widget.initialLatLng);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      width: double.infinity,
      height: double.infinity,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(right: 16, top: 16),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppStyles.bgGrey,
                borderRadius: BorderRadius.circular(24.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: GoogleMap(
                                mapType: MapType.normal,
                                initialCameraPosition: initialPosition,
                                onMapCreated: (controller) {
                                  if (mounted)
                                    setState(() {
                                      googleMapController = controller;
                                    });
                                },
                                markers: {
                                  centerPoint,
                                },
                                circles: {
                                  Circle(
                                    consumeTapEvents: true,
                                    circleId: CircleId('center'),
                                    center: centerPoint.position,
                                    radius: radius,
                                    fillColor: AppStyles.primaryTeal.withOpacity(0.4),
                                    strokeColor: AppStyles.primaryTeal,
                                    strokeWidth: 3,
                                  )
                                },
                                onTap: (pos) async {
                                  if (widget.clickable) {
                                    await mapOnTap(pos);
                                  }
                                }),
                          ),
                          if (widget.clickable)
                            Container(
                              height: double.infinity,
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 80,
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                constraints: BoxConstraints(maxWidth: 500),
                                decoration: BoxDecoration(
                                  color: AppStyles.pureWhite.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [AppStyles().lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        'Radius: ${radius.toStringAsFixed(0)} m',
                                        style: GoogleFonts.poppins(
                                            fontSize: 18, fontWeight: FontWeight.w600, color: AppStyles.primaryBlack),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      child: Slider(
                                          min: 50,
                                          max: 5000,
                                          value: radius,
                                          activeColor: AppStyles.primaryTeal,
                                          inactiveColor: AppStyles.lightGrey,
                                          onChanged: (value) async {
                                            if (mounted)
                                              setState(() {
                                                radius = value;
                                              });
                                            if (mounted) {
                                              await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                                                  CameraPosition(target: centerPoint.position, zoom: getZoom(radius))));
                                            }
                                          },
                                          onChangeEnd: (value) async {
                                            await getAddress(centerPoint.position);
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  )),
                  Container(
                    width: double.infinity,
                    height: 100,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            padding: EdgeInsets.only(right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, bottom: 2),
                                  child: Text(
                                      widget.clickable
                                          ? "Describe your location range. (You can edit this)"
                                          : "Location range",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppStyles.mediumGray,
                                      )),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppStyles.pureWhite,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: TextField(
                                    controller: descriptionController,
                                    maxLines: 1,
                                    enabled: widget.clickable,
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, color: AppStyles.primaryBlack, fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      hintText: 'Describe your location range',
                                      hintStyle: GoogleFonts.poppins(
                                          fontSize: 16, color: AppStyles.mediumGray, fontWeight: FontWeight.w600),
                                      contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.clickable)
                          Container(
                            height: double.infinity,
                            alignment: Alignment.bottomCenter,
                            child: MaterialButtonIcon(
                              height: 48,
                              onTap: () {
                                widget.onSubmit(descriptionController.text + " " + getString(), getString());
                                AppPopups.closeDialog();
                              },
                              withIcon: false,
                              withText: true,
                              text: "USE LOCATION",
                              buttonPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              buttonColor: AppStyles.primaryTeal,
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(color: AppStyles.primaryTeal, borderRadius: BorderRadius.circular(16)),
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppStyles.pureWhite,
                    size: 16,
                  ),
                  onPressed: () {
                    AppPopups.closeDialog();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
