import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:q_architecture/src/domain/entities/enums/global_info_status.dart';

/// GlobalInfo class that represents some kind of info that occurs in the app and being passed to UI
class GlobalInfo extends Equatable {
  /// GlobalInfoStatus of the GlobalInfo which defines type of info
  final GlobalInfoStatus globalInfoStatus;

  /// GlobalInfo message that is required and shown to user
  final String message;

  /// GlobalInfo title that can be shown to user
  final String? title;

  /// uniqueKey set by [BaseStateNotifier.setGlobalInfo] method to trigger [globalInfoProvider] each time
  final UniqueKey? uniqueKey;

  const GlobalInfo({
    required this.globalInfoStatus,
    required this.message,
    this.title,
    this.uniqueKey,
  });

  GlobalInfo copyWith({
    GlobalInfoStatus? globalInfoStatus,
    String? title,
    String? message,
    UniqueKey? uniqueKey,
  }) =>
      GlobalInfo(
        globalInfoStatus: globalInfoStatus ?? this.globalInfoStatus,
        title: title ?? this.title,
        message: message ?? this.message,
        uniqueKey: uniqueKey ?? this.uniqueKey,
      );

  @override
  List<Object?> get props => [
        globalInfoStatus,
        title,
        message,
        uniqueKey,
      ];

  @override
  bool? get stringify => true;
}
