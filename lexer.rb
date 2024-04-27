# frozen_string_literal: true
require_relative 'token'

def digit?(c)
  c.match?(/[[:digit:]]/)
end

def letter?(c)
  c.match?(/[[:alpha:]]/)
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

    }
  end

  def advance
    @pos += 1
    '\0' if @pos >= @source.length

    if peek == "\n"
      @col = 1
    else
      @col += 1
    end

    @source[@pos]
  end

  def eof?
    @pos >= @source.length
  end

  def peek(n = 0)
    '\0' if @pos + n >= @source.length
    @source[@pos + n]
  end

  def lex_string
    lexeme = ''
    start_col = @col
    start_line = @line
    advance
    while peek != '"'
      if peek == "\n"
        @line += 1
        @col = 1
      end
      lexeme += peek
      advance
    end

    advance
    Token.new(TokenType::STRING, start_line, start_col, lexeme, lexeme)
  end

  def lex_keyword
    lexeme = ''
    start_col = @col
    start_line = @line

    while letter? peek
      lexeme += peek
    end
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

    case c = peek
    when "\n", "\r"
      @line += 1
      advance
      @col = 1
      return match
    when ' '
      advance
      return match
    when '+'
      token = Token.new(TokenType::PLUS, @line, @col, c, c)
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
      token = Token.new(TokenType::MULTIPLY, @line, @col, c, c)
      advance
    when '/'
      token = Token.new(TokenType::DIVIDE, @line, @col, c, c)
      advance
    else
      return Token.new(TokenType::EOF, @line, @col, c, c)
    end
    token
  end

  def lex(source = '')
    unless source.empty?
      @source = source
      @line = 0
      @col = 0
      @pos = 0
      @tokens.clear
    end

    @tokens.push match until eof?

    @tokens
  end
end
