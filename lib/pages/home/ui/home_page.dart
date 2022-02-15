import 'package:camera/camera.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/all_file.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraDescription? _cameraDescription;
  late Future<void> _initializeControllerFuture;

  Future<void> _initCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    _cameraDescription = cameras.last;
  }

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        return _buildCameraView();
        // if (snapshot.connectionState == ConnectionState.done) {
        //   // If the Future is complete, display the preview.
        //
        // } else {
        //   // Otherwise, display a loading indicator.
        //   return const Center(child: CircularProgressIndicator());
        // }
      },
    );
  }

  Widget _buildCameraView() {
    if (_cameraDescription == null) {
      return 0.toVSizeBox();
    }

    return CameraView(
      description: _cameraDescription!,
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
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.description, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    _controller.startImageStream((image) {
      if (!mounted) {
        return;
      }

      

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox();
    }

    return _buildCameraView();
  }

  Widget _buildCameraView() {
    final scale = 1 /
        (_controller.value.aspectRatio *
            MediaQuery.of(context).size.aspectRatio);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: CameraPreview(_controller),
          ),
          Positioned(
            top: 0,
            left: 38,
            bottom: 0,
            right: 38,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 1.296 * (MediaQuery.of(context).size.width - 76),
                decoration: DottedDecoration(
                  shape: Shape.circle,
                  dash: const <int>[8, 8],
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 25,
            child: SafeArea(
              child: Text(
                'Position your face \ninside the line',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
