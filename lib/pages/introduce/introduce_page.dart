import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/widgets/button/common_primary_button.dart';

class IntroducePage extends StatefulWidget {
  const IntroducePage({Key? key}) : super(key: key);

  @override
  _IntroducePageState createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Нажмите ‘Начать\nсканирование’ для начала\nдиагностики',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        24.toVSizeBox(),
        _buildButton(context),
      ],
    ).plf(value: 16);
  }

  Widget _buildButton(BuildContext context) {
    return CommonPrimaryButton(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icon.cornersOut.svg(),
          10.toHSizeBox(),
          const Text('Начать сканирование'),
        ],
      ),
      onPressed: () {
        App.pushNamed(AppRoutes.home);
      },
    );
  }
}
