import 'package:q_architecture/q_architecture.dart';

///[GlobalInfoNotifier] can be used to show any info updating [BaseNotifier] state.
///
///The entire app is wrapped in [BaseWidget] which listens to this provider and GlobalInfo can be shown above entire
///app by simply calling setGlobalInfo() inside execute > onDataReceived()
class GlobalInfoNotifier extends SimpleNotifier<GlobalInfo?> {
  GlobalInfoNotifier() : super(null);

  @override
  void setGlobalInfo(GlobalInfo? globalInfo) => state = globalInfo;
}
