import 'package:equatable/equatable.dart';

class PaginatedList<T> extends Equatable {
  final List<T> data;
  final int page;
  final bool isLast;

  const PaginatedList({
    required this.data,
    required this.page,
    required this.isLast,
  });

  PaginatedList<T> copyWith({
    List<T>? data,
    int? page,
    bool? isLast,
  }) {
    return PaginatedList<T>(
      data: data ?? this.data,
      page: page ?? this.page,
      isLast: isLast ?? this.isLast,
    );
  }

  @override
  List<Object?> get props => [data];
}
