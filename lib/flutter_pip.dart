import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pip/platform_channel/channel.dart';

class PipWidget extends StatefulWidget {
  final Widget child;
  final Function(bool)? onResume;
  final Function? onSuspending;
  PipWidget({required this.child, this.onResume, this.onSuspending});
  @override
  _PipWidgetState createState() => _PipWidgetState();
}

class _PipWidgetState extends State<PipWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding?.instance?.addObserver(new LifecycleEventHandler(resumeCallBack: () async {
      bool isInPipMode = await FlutterPip.isInPictureInPictureMode();
      widget.onResume?.call(isInPipMode);
      return;
    }, suspendingCallBack: () async {
      widget.onSuspending?.call();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;
  final AsyncCallback? suspendingCallBack;

  LifecycleEventHandler({this.resumeCallBack, this.suspendingCallBack});

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack?.call();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspendingCallBack?.call();
        break;
    }
  }
}
