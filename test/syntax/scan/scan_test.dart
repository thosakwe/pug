import 'package:test/test.dart';
import 'common.dart';

main() {
  group('simple', () {
    test('tag+attributes', () {
      expect(
          'foo(bar="baz")',
          equalsScanned([
            TokenType.TAG_NAME,
            TokenType.LPAREN,
            TokenType.TAG_NAME,
            TokenType.EQUALS,
            TokenType.DOUBLE_QUOTED_STRING,
            TokenType.RPAREN
          ]));
    });
  });

  group('whitespace control', () {
    test('plain text block', () {
      expect(
          'p.\n  Hello\n  world',
          equalsScanned(
              [TokenType.TAG_NAME, TokenType.DOT, TokenType.ARBITRARY_TEXT]));
    });
  });
}
