import 'package:compiler_tools/compiler_tools.dart';
import 'package:string_scanner/string_scanner.dart';
import 'token_type.dart';

final RegExp _WHITESPACE = new RegExp(r'( |\n|\r|\t)+');

final Map<Pattern, TokenType> _PATTERNS = {
  '[': TokenType.LBRACKET,
  ']': TokenType.RBRACKET,
  '(': TokenType.LPAREN,
  ')': TokenType.RPAREN,
  ';': TokenType.SEMI,
  '&': TokenType.AMPERSAND,
  '|': TokenType.PIPE,
  '//': TokenType.COMMENT_START,
  '//-': TokenType.COMMENT_START_UNBUFFERED,
  '*': TokenType.ASTERISK,
  ':': TokenType.COLON,
  ',': TokenType.COMMA,
  '-': TokenType.DASH,
  '.': TokenType.DOT,
  '=': TokenType.EQUALS,
  '+': TokenType.PLUS,
  '/': TokenType.SLASH,
  '?': TokenType.QUESTION,
  '&&': TokenType.BOOL_AND,
  '==': TokenType.EQUALS,
  '!=': TokenType.BOOL_NOT_EQUALS,
  '||': TokenType.BOOL_OR,
  'append': TokenType.APPEND,
  'block': TokenType.BLOCK,
  'doctype': TokenType.DOCTYPE,
  'each': TokenType.EACH,
  'extends': TokenType.EXTENDS,
  'if': TokenType.IF,
  'in': TokenType.IN,
  'include': TokenType.INCLUDE,
  'else': TokenType.ELSE,
  'mixin': TokenType.MIXIN,
  'prepend': TokenType.PREPEND,
  'unless': TokenType.UNLESS,
  'while': TokenType.WHILE,
  'true': TokenType.BOOLEAN,
  'false': TokenType.BOOLEAN,
  new RegExp(r'-?[0-9]+(\.[0-9]+)?((E|e)-?[0-9]+)?'): TokenType.NUMBER,
  new RegExp(r"'(([^'\n\r])|(\\')|(\\(n|r)))*'"):
      TokenType.SINGLE_QUOTED_STRING,
  new RegExp(r'"(([^"\n\r])|(\\")|(\\(n|r)))*"'):
      TokenType.DOUBLE_QUOTED_STRING,
  new RegExp(r'`[^`]*`'): TokenType.TEMPLATE_STRING,
  new RegExp(r'\.-?[_a-zA-Z]+[_a-zA-Z0-9-]*'): TokenType.CLASS_NAME,
  new RegExp(r'#[^\s]+'): TokenType.ELEMENT_ID,
  new RegExp(r'[_a-zA-Z]+[_a-zA-Z0-9-]*'): TokenType.TAG_NAME,
  new RegExp(r'<[^\n]*(\n|$)'): TokenType.PLAIN_TEXT,
  '\n  ': TokenType.INDENT,
  _WHITESPACE: TokenType.WHITESPACE
};

class Scanner {
  final List<SyntaxError> _syntaxErrors = [];
  final List<Token<TokenType>> _tokens = [];

  List<SyntaxError> get syntaxErrors =>
      new List<SyntaxError>.unmodifiable(_syntaxErrors);

  List<Token<TokenType>> get tokens =>
      new List<Token<TokenType>>.unmodifiable(_tokens);

  void scan(String text, {sourceUrl}) {
    var scanner = new SpanScanner(text, sourceUrl: sourceUrl);
    LineScannerState arbitraryStart;

    void flushBuffer() {
      if (arbitraryStart != null) {
        _tokens.add(new Token(TokenType.ARBITRARY_TEXT,
            span: scanner.spanFrom(arbitraryStart)));
        arbitraryStart = null;
      }
    }

    while (!scanner.isDone) {
      bool matched = false;

      for (var pattern in _PATTERNS.keys) {
        if (scanner.scan(pattern)) {
          flushBuffer();
          _tokens.add(new Token(_PATTERNS[pattern], span: scanner.lastSpan));
          matched = true;
          break;
        }
      }

      if (!matched) {
        if (arbitraryStart == null) arbitraryStart = scanner.state;
        scanner.readChar();
      }
    }

    flushBuffer();
  }
}
