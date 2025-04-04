import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/notification_service.dart';
import 'package:infound/utils/styles.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';

class MaterialButtonIcon extends StatelessWidget {
  const MaterialButtonIcon({
    super.key,
    this.height,
    this.width,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.buttonColor,
    this.highlightColor,
    this.splashColor,
    this.borderRadius,
    required this.onTap,
    this.iconPadding,
    this.withIcon = true,
    this.withText = false,
    this.text,
    this.fontSize,
    this.fontColor,
    this.fontWeight,
    this.buttonPadding,
    this.iconTextDistance,
    this.fontFamily,
    this.isHorizontal = true,
    this.iconIsSVG,
    this.svgIcon,
    this.withShadow,
    this.withOutline,
  });

  final double? height;
  final double? width;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? buttonColor;
  final Color? highlightColor;
  final Color? splashColor;
  final BorderRadius? borderRadius;
  final VoidCallback onTap;
  final EdgeInsets? iconPadding;
  final EdgeInsets? buttonPadding;
  final bool? withIcon;
  final bool? withText;
  final String? text;
  final double? fontSize;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final double? iconTextDistance;
  final String? fontFamily;
  final bool? isHorizontal;
  final bool? iconIsSVG;
  final String? svgIcon;
  final bool? withShadow;
  final bool? withOutline;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      shadowColor: withShadow ?? false ? AppStyles.mediumGray.withAlpha(80) : Colors.transparent,
      color: buttonColor ?? AppStyles.primaryTeal,
      borderRadius: borderRadius ?? BorderRadius.circular(height ?? 30),
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(height ?? 30),
        onTap: onTap,
        splashColor: splashColor ?? AppStyles.lightGrey.withAlpha(80),
        highlightColor: highlightColor ?? AppStyles.lightGrey.withAlpha(80),
        child: Container(
            height: height,
            width: width,
            padding: buttonPadding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(height ?? 30),
                border:
                    withOutline ?? false ? Border.all(color: fontColor ?? AppStyles.primaryTeal, width: 2.0) : null),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: isHorizontal ?? true
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (withIcon ?? true)
                          Padding(
                            padding: iconPadding ?? EdgeInsets.all(0),
                            child: Icon(
                              icon,
                              size: iconSize ?? 25,
                              color: iconColor ?? AppStyles.pureWhite,
                            ),
                          ),
                        if (withText ?? false)
                          Container(
                            padding: EdgeInsets.only(left: iconTextDistance ?? 0),
                            child: Text(
                              text ?? "",
                              style: fontFamily == null
                                  ? GoogleFonts.poppins(
                                      fontSize: fontSize ?? 16,
                                      color: fontColor ?? AppStyles.pureWhite,
                                      fontWeight: fontWeight ?? FontWeight.w600)
                                  : TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: fontSize ?? 16,
                                      color: fontColor ?? AppStyles.pureWhite,
                                      fontWeight: fontWeight ?? FontWeight.w600),
                            ),
                          )
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (withIcon ?? true)
                          Padding(
                            padding: iconPadding ?? EdgeInsets.all(0),
                            child: Icon(
                              icon,
                              size: iconSize ?? 25,
                              color: iconColor ?? AppStyles.pureWhite,
                            ),
                          ),
                        if (withText ?? false)
                          Container(
                            padding: EdgeInsets.only(top: iconTextDistance ?? 0),
                            child: Text(
                              text ?? "",
                              style: fontFamily == null
                                  ? GoogleFonts.poppins(
                                      fontSize: fontSize ?? 16,
                                      color: fontColor ?? AppStyles.pureWhite,
                                      fontWeight: fontWeight ?? FontWeight.w600)
                                  : TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: fontSize ?? 16,
                                      color: fontColor ?? AppStyles.pureWhite,
                                      fontWeight: fontWeight ?? FontWeight.w600),
                            ),
                          )
                      ],
                    ),
            )),
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  const MenuOption({
    super.key,
    required this.isActive,
    required this.title,
    required this.icon,
    required this.iconActive,
    required this.onTap,
    required this.constraints,
    this.isMobile = false,
  });

  final bool isActive;
  final String title;
  final IconData icon;
  final IconData iconActive;
  final VoidCallback onTap;
  final BoxConstraints constraints;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    int count = 0;
    if (title == "Notifications" && AuthenticationRepository.instance.currentUserModel.value != null) {
      count = context.watch<NotificationService>().notificationCount;
    }
    final _controller = SuperTooltipController();
    return
        // SuperTooltip(
        // showOnTap: false,
        // fadeInDuration: Duration(milliseconds: 200),
        // fadeOutDuration: Duration(milliseconds: 200),
        // onShow: () async {
        //   await Future.delayed(Duration(milliseconds: 700), () {
        //     if (_controller.isVisible) {
        //       _controller.hideTooltip();
        //     }
        //   });
        // },
        // verticalOffset: -8,
        // arrowTipDistance: 40,
        // showBarrier: false,
        // controller: _controller,
        // hasShadow: false,
        // borderColor: Colors.transparent,
        // arrowLength: 0,
        // content: Text(
        //   title,
        //   style: GoogleFonts.poppins(fontSize: 14, color: AppStyles.pureWhite, fontWeight: FontWeight.w500, height: 1.5),
        // ),
        // backgroundColor: AppStyles.primaryTeal.withAlpha(200),
        // popupDirection: TooltipDirection.right,
        // child:
        Container(
      margin: EdgeInsets.only(bottom: 8),
      height: 48,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onHover: (hovered) {
            if (constraints.maxWidth < AppConstants.navbarBreakpoint || isMobile) {
              if (hovered) {
                _controller.showTooltip();
              } else {
                if (_controller.isVisible) _controller.hideTooltip();
              }
            }
          },
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.visitChildElements((element) {
                onTap();
              });
            });
          },
          borderRadius: BorderRadius.circular(30),
          hoverColor: AppStyles.primaryTealLightest,
          splashColor: AppStyles.primaryTealLighter,
          highlightColor: AppStyles.primaryTealLighter,
          child: Container(
            height: 56,
            padding: EdgeInsets.symmetric(
                vertical: 8, horizontal: (constraints.maxWidth >= AppConstants.navbarBreakpoint || isMobile) ? 24 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: (constraints.maxWidth >= AppConstants.navbarBreakpoint || isMobile)
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Container(
                  child: (constraints.maxWidth >= AppConstants.navbarBreakpoint || isMobile)
                      ? Icon(isActive ? iconActive : icon,
                          color: isActive ? AppStyles.primaryTeal : AppStyles.mediumGray, size: 28)
                      : (title == "Notifications" && count > 0)
                          ? Container(
                              height: 28,
                              width: 28,
                              child: Stack(
                                children: [
                                  Icon(isActive ? iconActive : icon,
                                      color: isActive ? AppStyles.primaryTeal : AppStyles.mediumGray, size: 28),
                                  Transform.translate(
                                    offset: Offset(20, 0),
                                    child: Container(
                                      height: 12,
                                      width: 12,
                                      decoration: BoxDecoration(
                                        color: AppStyles.primaryRed,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  )
                                ],
                              ))
                          : Icon(isActive ? iconActive : icon,
                              color: isActive ? AppStyles.primaryTeal : AppStyles.mediumGray, size: 28),
                  margin: (constraints.maxWidth >= AppConstants.navbarBreakpoint || isMobile)
                      ? EdgeInsets.only(right: 12)
                      : null,
                ),
                (constraints.maxWidth >= AppConstants.navbarBreakpoint || isMobile)
                    ? Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: isActive ? AppStyles.primaryTeal : AppStyles.mediumGray,
                                height: 1),
                          ),
                        ),
                      )
                    : Container(),
                if (title == "Notifications" && count > 0)
                  (constraints.maxWidth >= AppConstants.navbarBreakpoint || isMobile)
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppStyles.primaryRed,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "${count > 9 ? "9+" : count}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500, fontSize: 12, color: AppStyles.pureWhite, height: 1),
                          ),
                        )
                      : Container()
              ],
            ),
          ),
        ),
      ),
      // ),
    );
  }
}
