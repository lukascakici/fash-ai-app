import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomButton extends StatelessWidget {
  final bool showAds;
  final bool isPremium;
  final double elevation;
  final Widget widget;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final BorderSide border;
  final double borderRadius;
  final bool disable;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const CustomButton({
    super.key,
    required this.widget,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.gradient,
    this.width,
    this.height,
    this.disable = false,
    this.border = BorderSide.none,
    this.borderRadius = 8.0,
    this.elevation = 1.25,
    this.showAds = false,
    this.isPremium = false,
  });

  CustomButton copyWith({
    Color? color,
    DecorationImage? image,
    BorderSide? border,
    double? borderRadius,
    List<BoxShadow>? boxShad,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape? shape,
    double? elevation,
  }) {
    return CustomButton(
      widget: widget,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: MaterialButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          side: border,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        disabledColor: Theme.of(context).disabledColor,
        disabledTextColor: Theme.of(context).colorScheme.scrim.withOpacity(0.5),
        onPressed: disable ? null : onPressed,
        elevation: elevation,
        color: disable
            ? Theme.of(context).disabledColor
            : backgroundColor ?? Colors.transparent,
        textColor: disable
            ? Theme.of(context).colorScheme.scrim.withOpacity(0.5)
            : foregroundColor ?? Theme.of(context).colorScheme.scrim,
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: disable ? null : gradient,
            color: disable ? Theme.of(context).disabledColor : backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: showAds
                ? Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: Directionality.of(context) == TextDirection.rtl
                              ? 10.0
                              : 0,
                          right: Directionality.of(context) == TextDirection.ltr
                              ? 10.0
                              : 0,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/watch_ads.svg',
                          colorFilter: ColorFilter.mode(
                            disable
                                ? Theme.of(context)
                                    .colorScheme
                                    .scrim
                                    .withOpacity(0.5)
                                : Theme.of(context).colorScheme.scrim,
                            BlendMode.srcIn,
                          ),
                          height: 22.h,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          widget,
                          Text(
                            'Watch an Ad',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      height: 1,
                                      fontSize: 10,
                                      color: disable
                                          ? Theme.of(context)
                                              .colorScheme
                                              .scrim
                                              .withOpacity(0.5)
                                          : Theme.of(context).colorScheme.scrim,
                                    ),
                          )
                        ],
                      ),
                    ],
                  )
                : isPremium
                    ? Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: Directionality.of(context) ==
                                      TextDirection.rtl
                                  ? 10.0
                                  : 0,
                              right: Directionality.of(context) ==
                                      TextDirection.ltr
                                  ? 10.0
                                  : 0,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/crown.svg',
                              colorFilter: ColorFilter.mode(
                                disable
                                    ? Theme.of(context)
                                        .colorScheme
                                        .scrim
                                        .withOpacity(0.5)
                                    : Theme.of(context).colorScheme.scrim,
                                BlendMode.srcIn,
                              ),
                              height: 14.h,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              widget,
                              Text(
                                'Get Premium',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      height: 1,
                                      fontSize: 10,
                                      color: disable
                                          ? Theme.of(context)
                                              .colorScheme
                                              .scrim
                                              .withOpacity(0.5)
                                          : Theme.of(context).colorScheme.scrim,
                                    ),
                              )
                            ],
                          ),
                        ],
                      )
                    : widget,
          ),
        ),
      ),
    );
  }
}
