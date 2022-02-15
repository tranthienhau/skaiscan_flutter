/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class $AssetsIconGen {
  const $AssetsIconGen();

  SvgGenImage get call => const SvgGenImage('assets/icon/call.svg');
  SvgGenImage get checklist => const SvgGenImage('assets/icon/checklist.svg');
  SvgGenImage get delete => const SvgGenImage('assets/icon/delete.svg');
  SvgGenImage get edit => const SvgGenImage('assets/icon/edit.svg');
  SvgGenImage get googleMap => const SvgGenImage('assets/icon/google_map.svg');
  SvgGenImage get home => const SvgGenImage('assets/icon/home.svg');
  SvgGenImage get logout => const SvgGenImage('assets/icon/logout.svg');
  SvgGenImage get moreHorizontal =>
      const SvgGenImage('assets/icon/more_horizontal.svg');
  SvgGenImage get noAvatar => const SvgGenImage('assets/icon/no_avatar.svg');
  SvgGenImage get pin => const SvgGenImage('assets/icon/pin.svg');
  SvgGenImage get refreshDisable =>
      const SvgGenImage('assets/icon/refresh_disable.svg');
  SvgGenImage get refreshEnable =>
      const SvgGenImage('assets/icon/refresh_enable.svg');
  SvgGenImage get wifiOff => const SvgGenImage('assets/icon/wifi_off.svg');
}

class $AssetsImageGen {
  const $AssetsImageGen();

  AssetGenImage get assignedJobsEmpty =>
      const AssetGenImage('assets/image/assigned_jobs_empty.png');
  AssetGenImage get background =>
      const AssetGenImage('assets/image/background.png');
  AssetGenImage get googleMap =>
      const AssetGenImage('assets/image/google_map.png');
  AssetGenImage get inputEmail =>
      const AssetGenImage('assets/image/input_email.png');
  AssetGenImage get loginImage =>
      const AssetGenImage('assets/image/login_image.png');
  AssetGenImage get mail => const AssetGenImage('assets/image/mail.png');
  AssetGenImage get marker => const AssetGenImage('assets/image/marker.png');
  AssetGenImage get selectedMarker =>
      const AssetGenImage('assets/image/selected_marker.png');
  AssetGenImage get shapeLogin =>
      const AssetGenImage('assets/image/shape_login.png');
  AssetGenImage get textLogin =>
      const AssetGenImage('assets/image/text_login.png');
}

class Assets {
  Assets._();

  static const $AssetsIconGen icon = $AssetsIconGen();
  static const $AssetsImageGen image = $AssetsImageGen();
}

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName) : super(assetName);

  Image image({
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      key: key,
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => assetName;
}

class SvgGenImage {
  const SvgGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return SvgPicture.asset(
      _assetName,
      key: key,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      color: color,
      colorBlendMode: colorBlendMode,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      clipBehavior: clipBehavior,
    );
  }

  String get path => _assetName;
}
