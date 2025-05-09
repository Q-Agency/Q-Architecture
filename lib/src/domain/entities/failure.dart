// ignore_for_file: avoid-dynamic

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:q_architecture/q_architecture.dart';

/// Failure class that represents some kind of error that occurs in the app and being passed to UI
class Failure extends Equatable {
  /// title of the Failure which can be shown to user
  final String title;

  /// bool that says if this Failure is a critical one or not and according to it can be displayed to user in a different manner
  final bool isCritical;

  /// error that can be caught by some try catch block, useful for debugging
  final dynamic error;

  /// stackTrace of the [error] that can be caught by some try catch block, also useful for debugging
  final StackTrace? stackTrace;

  /// uniqueKey set by [SimpleNotifierMixin.setGlobalFailure] method to trigger [globalFailureProvider] each time
  final UniqueKey? uniqueKey;

  const Failure({
    required this.title,
    this.isCritical = false,
    this.error,
    this.stackTrace,
    this.uniqueKey,
  });

  /// Generic Failure constructor with default title if not provided
  factory Failure.generic({
    String? title,
    bool isCritical = false,
    dynamic error,
    StackTrace? stackTrace,
    UniqueKey? uniqueKey,
  }) =>
      Failure(
        title: title ?? 'Unknown error occurred',
        isCritical: isCritical,
        error: error,
        stackTrace: stackTrace,
        uniqueKey: uniqueKey,
      );

  factory Failure.permissionDenied({
    String? title,
    bool isCritical = false,
    dynamic error,
    StackTrace? stackTrace,
    UniqueKey? uniqueKey,
  }) =>
      Failure(
        title: title ?? 'Permission denied',
        isCritical: isCritical,
        error: error,
        stackTrace: stackTrace,
        uniqueKey: uniqueKey,
      );

  Failure copyWith({
    String? title,
    bool? isCritical,
    dynamic error,
    StackTrace? stackTrace,
    UniqueKey? uniqueKey,
  }) =>
      Failure(
        title: title ?? this.title,
        isCritical: isCritical ?? this.isCritical,
        error: error ?? this.error,
        stackTrace: stackTrace ?? this.stackTrace,
        uniqueKey: uniqueKey ?? this.uniqueKey,
      );

  @override
  List<Object?> get props => [
        title,
        isCritical,
        error,
        stackTrace,
        uniqueKey,
      ];

  @override
  bool? get stringify => true;
}
