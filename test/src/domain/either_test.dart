import 'package:flutter_test/flutter_test.dart';
import 'package:q_architecture/src/domain/either.dart';
import 'package:q_architecture/src/domain/entities/failure.dart';

void main() {
  final failureEither = (Failure.generic(), null);
  const value = 'testValue';
  const valueEither = (null, 'testValue');
  group('fold', () {
    test(
      'Should call left handler when record has left non-null value',
      () {
        failureEither.fold(
          (failure) => expect(failure, isA<Failure>()),
          (p0) => fail(''),
        );
      },
    );
    test(
      'Should call right handler when record has left non-null value',
      () {
        valueEither.fold(
          (failure) => fail(''),
          (data) => expect(data, value),
        );
      },
    );
  });
  group('isLeft', () {
    test('Should return true when result is left', () {
      expect(failureEither.isLeft(), true);
    });
    test('Should return false when result is not left', () {
      expect(valueEither.isLeft(), false);
    });
  });
  group('isRight', () {
    test('Should return true when result is right', () {
      expect(valueEither.isRight(), true);
    });
    test('Should return false when result is not right', () {
      expect(failureEither.isRight(), false);
    });
  });
  group('asLeft', () {
    test('Should return left value when left value present', () {
      expect(failureEither.asLeft(), Failure.generic());
    });
    test('Should throw NoValuePresentException when no left value present', () {
      try {
        valueEither.asLeft();
        fail('Left value present');
      } on NoValuePresentException {
        expect(true, true);
      }
    });
  });
  group('asRight', () {
    test('Should return right value when right value present', () {
      expect(valueEither.asRight(), value);
    });
    test(
      'Should throw NoValuePresentException when no right value present',
      () {
        try {
          failureEither.asRight();
          fail('Left value present');
        } on NoValuePresentException {
          expect(true, true);
        }
      },
    );
  });
  group('right', () {
    test(
      'Should create record with right value present and left value null',
      () {
        final record = right('test');
        expect(record, (null, 'test'));
      },
    );
  });
  group('left', () {
    test(
      'Should create record with left value present and right value null',
      () {
        final record = left('test');
        expect(record, ('test', null));
      },
    );
  });
}
