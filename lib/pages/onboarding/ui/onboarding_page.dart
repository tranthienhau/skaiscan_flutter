import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/pages/onboarding/bloc/on_boarding_bloc.dart';
import 'package:skaiscan/pages/onboarding/ui/tab/first_onboaring_tab.dart';
import 'package:skaiscan/pages/onboarding/ui/tab/second_onboaring_tab.dart';
import 'package:skaiscan/widgets/button/common_primary_button.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnBoardingBloc(),
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: _buildBody(context),
        );
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView(
              onPageChanged: (int page) {
                BlocProvider.of<OnBoardingBloc>(context)
                    .add(OnBoardingPageChanged(page));
              },
              children: const [
                FirstOnBoardingTab(),
                SecondOnBoardingTab(),
              ],
            ),
          ),
          _buildBottom(context),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Column(
      children: [
        _buildPageIndicator(context),
        30.toVSizeBox(),
        _buildButton(context),
        16.toVSizeBox(),
      ],
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    return BlocBuilder<OnBoardingBloc, OnBoardingState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              List.generate(state.pageCount, (index) => index).map((index) {
            if (index == state.pageIndex) {
              return Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ).plf(value: 4);
            }

            return Container(
              height: 8,
              width: 24,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
            ).plf(value: 4);
          }).toList(),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context) {
    return CommonPrimaryButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Далее'),
        ],
      ),
      onPressed: () {
        App.pushNamed(AppRoutes.introduce);
      },
    ).plf(value: 16);
  }
}
