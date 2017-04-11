import 'package:compiler_tools/compiler_tools.dart';
import 'package:matcher/matcher.dart';
import 'package:pug/src/syntax/scanner.dart';
import 'package:pug/src/syntax/token_type.dart';
export 'package:pug/src/syntax/token_type.dart';

List<Token<TokenType>> scan(String text) {
  var scanner = new Scanner()..scan(text);
  if (scanner.syntaxErrors.isNotEmpty)
    throw scanner.syntaxErrors.first;
  else
    return scanner.tokens;
}

Matcher equalsScanned(Iterable<TokenType> expected) => new _EqualsScanned(expected);

class _EqualsScanned extends Matcher {
  final Iterable<TokenType> _expected;
  List<Token<TokenType>> _tokens;

  _EqualsScanned(this._expected);

  @override
  Description describe(Description description) =>
      description.add('matches token type sequence: $_expected');

  @override
  Description describeMismatch(item, Description mismatchDescription,
      Map matchState, bool verbose) {
    print('equalsScanned failed: ${matchState["reason"]}');
    print('Tokens: ');

    for (var token in _tokens) {
      print('  "${token.text.replaceAll('\n', '\\n')}" => ${token.type}');
    }

    return super.describeMismatch(item, mismatchDescription, matchState, verbose);
  }

  @override
  bool matches(String item, Map matchState) {
    _tokens = scan(item);
    return equals(_expected.toList())
        .matches(_tokens.map<TokenType>((t) => t.type).toList(), matchState);
  }
}
