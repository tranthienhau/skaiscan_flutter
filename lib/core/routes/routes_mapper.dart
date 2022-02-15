import 'package:skaiscan/core/theme_provider.dart';
import 'package:flutter/material.dart';


class RoutesMapper {
  RoutesMapper._();

  static Route _buildRoute(
      {required Widget page, required RouteSettings settings}) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => _buildApplyTextOptionsPage(page),
    );
  }

  ///Return route with settings (you can pass parameters to pages)
  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case AppRoutes.details:
      //   final Job arguments = settings.arguments! as Job;
      //   return _buildRoute(
      //     page: JobDetailsPage(job: arguments),
      //     settings: settings,
      //   );
      // case AppRoutes.previewPhoto:
      //   final argument = settings.arguments! as PreviewPhotoArg;
      //   return _buildRoute(
      //     page: PhotoPreviewPage(previewPhotoArg: argument),
      //     settings: settings,
      //   );
      // case AppRoutes.editComment:
      //   final argument = settings.arguments! as EditCommentArg;
      //   return _buildRoute(
      //     page: EditCommentPage(args: argument),
      //     settings: settings,
      //   );

      //
      // case AppRoutes.home:
      //   return _buildRoute(
      //     page: const HomePage(),
      //     settings: settings,
      //   );
    }
    return null;
  }

  static Widget _buildApplyTextOptionsPage(Widget page) {
    return ApplyTextOptions(child: page);
  }

  ///Return route without settings
  static Map<String, WidgetBuilder> buildRoute() => {

        // AppRoutes.previewPhoto: (BuildContext context)=> _buildApplyTextOptionsPage(const PhotoPreviewPage()),
      };
}
