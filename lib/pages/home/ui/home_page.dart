import 'package:camera/camera.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/pages/home/bloc/home_bloc.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/widgets/button/common_primary_button.dart';
import 'package:skaiscan/widgets/loading_indicator.dart';
import 'package:skaiscan/widgets/skaiscan_camera_preview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraService _cameraService;

  @override
  void initState() {
    super.initState();
    _cameraService = GetIt.I<CameraService>();
  }

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
        if (state is HomeScanComplete) {
          App.pop();

          // showDialog<String>(
          //   context: context,
          //   builder: (BuildContext context) => AlertDialog(
          //     contentPadding: EdgeInsets.zero,
          //     insetPadding: EdgeInsets.zero,
          //     actionsPadding: EdgeInsets.zero,
          //     buttonPadding: EdgeInsets.zero,
          //     titlePadding: EdgeInsets.zero,
          //
          //     title: const Text('AlertDialog Title'),
          //     content: Image.memory(state.bytes),
          //     actions: <Widget>[
          //       TextButton(
          //         onPressed: () => Navigator.pop(context, 'Cancel'),
          //         child: const Text('Cancel'),
          //       ),
          //       TextButton(
          //         onPressed: () => Navigator.pop(context, 'OK'),
          //         child: const Text('OK'),
          //       ),
          //     ],
          //   ),
          // );
        }
      },
      builder: (context, state) {
        final data = state.data;

        if (data.cameraDescriptionList.isEmpty) {
          return const Center(
            child: LoadingIndicator(),
          );
        }

        return _buildCameraView(data.cameraDescriptionList.last);
      },
    );
  }

  Widget _buildCameraView(CameraDescription cameraDescription) {
    return CameraView(
      description: cameraDescription,
      onCaptured: (XFile file) async {},
    );
  }
}

class CameraView extends StatefulWidget {
  const CameraView({Key? key, required this.description, this.onCaptured})
      : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
  final CameraDescription description;
  final Function(XFile file)? onCaptured;
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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!(_controller?.value.isInitialized ?? false)) {
      return const SizedBox();
    }

    return _buildCameraView();
  }

  Widget _buildCameraView() {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox();
    }

    // final scale = 1 /
    //     (controller.value.aspectRatio *
    //         MediaQuery.of(context).size.aspectRatio);

    // return FittedBox();
    // return FittedSizes(source, destination);

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
          // Transform.scale(
          //   scale: scale,
          //   alignment: Alignment.topCenter,
          //   child: CameraPreview(controller),
          // ),
          Positioned(
            top: ViewUtils.getPercentHeight(percent: 0.1083),
            left: 27,
            right: 27,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width - 54,
                decoration: DottedDecoration(
                  shape: Shape.box,
                  dash: const <int>[3, 3],
                  color: AppColors.dotLine,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: ViewUtils.getPercentHeight(percent: 0.307),
              width: double.infinity,
              color: Colors.black,
            ),
          ),
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
          //
          // Positioned(
          //   left: 16,
          //   right: 16,
          //   bottom: ViewUtils.getPercentHeight(percent: 0.0554),
          //   child: SafeArea(
          //     child: _buildButton(),
          //   ),
          // ),
        ],
      ),
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
        try {
          await _cameraService.stopImageStream();
        } catch (_) {}

        final XFile? file = await _controller?.takePicture();
        if (file != null) {
          _showProgressDialog(context, BlocProvider.of<HomeBloc>(context));
          BlocProvider.of<HomeBloc>(context).add(HomeAcneScan(file));
        }
      },
    );
  }

  void _showProgressDialog(BuildContext context, HomeBloc homeBloc) {
    showDialog<String>(
      context: context,
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
