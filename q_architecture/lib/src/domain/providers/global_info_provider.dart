// ignore_for_file: always_use_package_imports

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

///[globalInfoProvider] can be used to show any info updating [BaseStateNotifier] state.
///
///The entire app is wrapped in [BaseWidget] which listens to this provider and GlobalInfo can be shown above entire
///app by simply calling setGlobalInfo() inside execute > onDataReceived()
final globalInfoProvider = StateProvider<GlobalInfo?>((_) => null);
