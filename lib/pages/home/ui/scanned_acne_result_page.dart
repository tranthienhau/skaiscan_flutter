import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/model/acne.dart';
import 'package:skaiscan/widgets/button/circle_button.dart';

class ScannedAcneResultPage extends StatefulWidget {
  const ScannedAcneResultPage({Key? key, required this.args}) : super(key: key);

  final AcneScanArgs args;

  @override
  _ScannedAcneResultPageState createState() => _ScannedAcneResultPageState();
}

class _ScannedAcneResultPageState extends State<ScannedAcneResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        ViewUtils.getPercentHeight(percent: 0.05).toVSizeBox(),
        Align(
          alignment: Alignment.centerRight,
          child: CircleButton(
            backgroundColor: Colors.transparent,
            child: Assets.icon.cancel.svg(),
            onPressed: () {
              App.pop();
            },
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.memory(
              widget.args.scanBytes,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: _buildAcneList(),
        ),
      ],
    );
  }

  Widget _buildAcneList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: widget.args.acneList.length,
      separatorBuilder: (BuildContext context, int index) {
        return 24.toVSizeBox();
      },
      itemBuilder: (BuildContext context, int index) {
        return _AcneWidget(
          acne: widget.args.acneList[index],
        );
      },
    );
  }
}

class _AcneWidget extends StatelessWidget {
  const _AcneWidget({Key? key, required this.acne}) : super(key: key);

  final Acne acne;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(backgroundColor: acne.color, radius: 24),
        12.toHSizeBox(),
        Text(
          acne.name,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }
}
