import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/pages/loading/bloc/application_bloc.dart';
import 'package:skaiscan/widgets/loading_indicator.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    BlocProvider.of<ApplicationBloc>(context).add(ApplicationLoaded());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationBloc, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationLoadSuccess) {
          App.pushNamedAndPopUntil(AppRoutes.onBoarding, null, '/');
        }
      },
      child: const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      ),
    );
  }
}
