import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/pages/home/bloc/home_bloc.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/widgets/button/circle_button.dart';
import 'package:skaiscan/widgets/button/common_primary_button.dart';
import 'package:skaiscan/widgets/decoration/skaiscan_decoration.dart';
import 'package:skaiscan/widgets/loading_indicator.dart';
import 'package:skaiscan/widgets/skaiscan_camera_preview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late CameraService _cameraService;

  // @override
  // void initState() {
  //   super.initState();
  //   // _cameraService = GetIt.I<CameraService>();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(HomeLoaded()),
      child: Scaffold(
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeScanFailure) {
          App.pop();
          DialogHelper.showError(content: state.error);
          return;
        }

        if (state is HomeLoadFailure) {
          DialogHelper.showError(content: state.error);
          return;
        }

        if (state is HomeScanComplete) {
          App.pop();
          final result = state.data.captureBytes;

          if (result == null) {
            return;
          }

          App.pushNamed(
            AppRoutes.scannedAcneResult,
            AcneScanArgs(
              acneList: state.acneList,
              scanBytes: result,
            ),
          );
        }
      },
      builder: (context, state) {
        final data = state.data;

        if (data.cameraDescriptionList.isEmpty) {
          return const Center(
            child: LoadingIndicator(),
          );
        }

        return _buildCameraView(
          data.cameraDescriptionList.last,
          context,
        );
      },
    );
  }

  Widget _buildCameraView(
      CameraDescription cameraDescription, BuildContext context) {
    return CameraView(
      description: cameraDescription,
      onCaptured: (XFile file) async {},
      viewInsets: MediaQuery.of(context).viewInsets,
    );
  }
}

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.description,
      this.onCaptured,
      required this.viewInsets})
      : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
  final CameraDescription description;
  final Function(XFile file)? onCaptured;
  final EdgeInsets viewInsets;
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  late CameraService _cameraService;

  @override
  void initState() {
    super.initState();

    _cameraService = GetIt.I<CameraService>();

    _initCamera();
  }

  Future<void> _initCamera() async {
    await _cameraService.startService(widget.description);
    _cameraService.startImageStream();
    _controller = _cameraService.controller;
    // BlocProvider.of<HomeBloc>(context).add(HomeLoaded());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!(_controller?.value.isInitialized ?? false)) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    return _buildCameraView();
  }

  Widget _buildCameraView() {
    final controller = _controller;
    if (controller == null) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    double originTop = ViewUtils.getPercentHeight(percent: 0.08) + 10;
    if (originTop < 60) {
      originTop = 60;
    }

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SkaiscanCameraPreview(controller),
              ),
              if (!state.data.allowScan)
                Positioned(
                  top: originTop,
                  left: 27,
                  right: 27,
                  child: SafeArea(
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: (MediaQuery.of(context).size.width - 54) * 1.2,
                        decoration: const SkaiscanDottedDecoration(
                          shape: SkaiscanShape.box,
                          dash: <int>[1, 1],
                          divideSpace: 8,
                          color: AppColors.dotLine,
                        ),
                      ),
                    ),
                  ),
                ),
              if (state.data.allowScan)
                Positioned(
                  top: originTop,
                  left: 27,
                  right: 27,
                  child: SafeArea(
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: (MediaQuery.of(context).size.width - 54) * 1.2,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.dotLine,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: ViewUtils.getPercentHeight(percent: 0.2),
                  width: double.infinity,
                  color: Colors.black,
                ),
              ),
              if (!state.data.allowScan)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: ViewUtils.getPercentHeight(percent: 0.0554),
                  child: SafeArea(
                    child: Text(
                      'Убедитесь что лицо в рамке и посмотрите в\nкамеру',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                    ),
                  ),
                ),
              if (state.data.allowScan)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: ViewUtils.getPercentHeight(percent: 0.0554),
                  child: SafeArea(
                    child: _buildButton(),
                  ),
                ),
              Positioned(
                top: 10,
                right: 16,
                child: SafeArea(
                  child: CircleButton(
                    backgroundColor: AppColors.grey.withOpacity(0.5),
                    child: Assets.icon.cancel.svg(),
                    onPressed: () {
                      App.pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton() {
    return CommonPrimaryButton(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Сканировать'),
        ],
      ),
      onPressed: () async {
        _showProgressDialog(context, BlocProvider.of<HomeBloc>(context));
        BlocProvider.of<HomeBloc>(context).add(HomeAcneScanned());
      },
    );
  }

  void _showProgressDialog(BuildContext context, HomeBloc homeBloc) {
    // bool animateFromLastPercent = false;
    showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.only(bottom: 20),
        insetPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        buttonPadding: EdgeInsets.zero,
        titlePadding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Text(
            'Обработка',
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
          ),
        ),
        content: BlocBuilder<HomeBloc, HomeState>(
          bloc: homeBloc,
          builder: (context, state) {
            return LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 32,
              lineHeight: 16.0,
              animation: true,
              animateFromLastPercent: state.data.scanPercent != 0,
              animationDuration: 1000,
              percent: state.data.scanPercent / 100,
              progressColor: Theme.of(context).primaryColor,
              backgroundColor: AppColors.primaryLight,
              barRadius: const Radius.circular(16),
            );
          },
        ),
      ),
    );
  }
}
