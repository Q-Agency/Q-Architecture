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

  @override
  List<Object?> get props => [data];
}
