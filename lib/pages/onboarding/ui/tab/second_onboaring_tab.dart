import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/all_file.dart';

class SecondOnBoardingTab extends StatelessWidget {
  const SecondOnBoardingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ViewUtils.getPercentHeight(percent: 0.15).toVSizeBox(),
        Assets.feature.onBoarding2.svg(fit: BoxFit.fitWidth),
        16.toVSizeBox(),
        Text(
          'Просто отсканируйте\n'
          'лицо и получите\n'
          'рекомендации',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        )
      ],
    );
  }
}
