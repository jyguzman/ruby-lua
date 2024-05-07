# frozen_string_literal: true
require_relative 'token'

def digit?(char)
  !char.nil? and char.match?(/[[:digit:]]/)
end

def letter?(char)
  !char.nil? and char.match?(/[[:alpha:]]/)
end

##
# This class produces a list of tokens from a given source code input.
class Lexer
  def initialize(source = '')
    @source = source
    @line = 1
    @col = 1
    @pos = 0
    @tokens = []
    @keywords = {
      'function' => TokenType::FUNCTION,
      'return' => TokenType::RETURN,
      'val' => TokenType::VAL,
      'local' => TokenType::LOCAL,
      'for' => TokenType::FOR,
      'true' => TokenType::TRUE,
      'false' => TokenType::FALSE,
      'and' => TokenType::AND,
      'or' => TokenType::LUA_OR,
      'not' => TokenType::NOT,
      'while' => TokenType::WHILE,
      'then' => TokenType::THEN,
      'else' => TokenType::ELSE,
      'end' => TokenType::LUA_END,
      'if' => TokenType::LUA_IF,
      'elseif' => TokenType::ELSEIF,
      'do' => TokenType::LUA_DO
    }
  end

  attr_reader :source, :line, :col, :pos, :keywords, :tokens

  def advance
    @pos += 1
    '\0' if @pos >= @source.length

    if peek == "\n"
      @col = 0
      @line += 1
    else
      @col += 1
    end

    @source[@pos]
  end

  def eof?
    @pos >= @source.length
  end

  def peek(n = 0)
    "\0" if @pos + n >= @source.length
    @source[@pos + n]
  end

  def lex_string
    lexeme = ''
    start_col = @col
    start_line = @line
    advance
    while peek != '"'
      lexeme += peek
      advance
    end

    advance
    Token.new(TokenType::STRING, start_line, start_col, lexeme, lexeme)
  end

  def lex_keyword_or_ident
    lexeme = ''
    start_col = @col
    start_line = @line

    while letter?(peek) || peek == '_' || peek == '-'
      lexeme += peek
      advance
    end

    type = (@keywords.key?(lexeme) ? @keywords[lexeme] : TokenType::IDENT)
    Token.new(type, start_line, start_col, lexeme, lexeme)
  end

  def lex_number
    lexeme = ''
    start_col = @col
    start_line = @line
    is_float = false

    while digit?(peek) || peek == '.'
      is_float = true if peek == '.'
      lexeme += peek
      advance
    end

    literal = (is_float ? Float(lexeme) : Integer(lexeme))
    Token.new(TokenType::NUMBER, start_line, start_col, lexeme, literal)
  end

  def match
    return lex_number if digit?(peek)
    return lex_string if peek == '"'
    return lex_keyword_or_ident if letter?(peek)

    case c = peek
    when "\n", "\r"
      advance while peek == "\n" || peek == "\r"
      return eof? ? Token.new(TokenType::EOF, @line, @col, '', '') : match
    when ' '
      advance
      return match
    when ','
      token = Token.new(TokenType::COMMA, @line, @col, c, c)
      advance
    when ';'
      token = Token.new(TokenType::SEMI, @line, @col, c, c)
      advance
    when '#'
      token = Token.new(TokenType::HASHTAG, @line, @col, c, c)
      advance
    when '='
      if peek(1) == '='
        token = Token.new(TokenType::EQUALS, @line, @col, '==', '==')
        advance
      else
        token = Token.new(TokenType::ASSIGN, @line, @col, c, c)
      end
      advance
    when '~'
      if peek(1) == '='
        token = Token.new(TokenType::NEQ, @line, @col, '~=', '~=')
        advance
      else
        puts('Invalid token ~')
        exit 1
      end
      advance
    when '<'
      if peek(1) == '='
        token = Token.new(TokenType::LEQ, @line, @col, '<=', '<=')
        advance
      else
        token = Token.new(TokenType::LESS, @line, @col, c, c)
      end
      advance
    when '>'
      if peek(1) == '='
        token = Token.new(TokenType::GEQ, @line, @col, '>=', '>=')
        advance
      else
        token = Token.new(TokenType::GREATER, @line, @col, c, c)
      end
      advance
    when '+'
      token = Token.new(TokenType::PLUS, @line, @col, c, c)
      advance
    when '%'
      token = Token.new(TokenType::PERCENT, @line, @col, c, c)
      advance
    when '-'
      if peek(1) == '-'
        advance until peek == "\n"
        return match
      else
        token = Token.new(TokenType::MINUS, @line, @col, c, c)
        advance
      end
    when '*'
      token = Token.new(TokenType::STAR, @line, @col, c, c)
      advance
    when '/'
      token = Token.new(TokenType::SLASH, @line, @col, c, c)
      advance
    when '('
      token = Token.new(TokenType::LPAREN, @line, @col, c, c)
      advance
    when ')'
      token = Token.new(TokenType::RPAREN, @line, @col, c, c)
      advance
    when '{'
      token = Token.new(TokenType::LBRACE, @line, @col, c, c)
      advance
    when '}'
      token = Token.new(TokenType::RBRACE, @line, @col, c, c)
      advance
    when '['
      token = Token.new(TokenType::LBRACKET, @line, @col, c, c)
      advance
    when ']'
      token = Token.new(TokenType::RBRACKET, @line, @col, c, c)
      advance
    else
      puts("Unrecognized token #{c}.")
      exit 1
    end
    token
  end

  def lex(source = '')
    unless source.empty?
      @source = source
      @line = 1
      @col = 1
      @pos = 0
      @tokens.clear
    end

    @tokens.push match until eof?
    @tokens.push Token.new(TokenType::EOF, @line, @col, '', '') if @tokens[-1].token_type != TokenType::EOF
    @tokens
  end
end
