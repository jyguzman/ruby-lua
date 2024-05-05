# frozen_string_literal: true
require_relative 'token'
require_relative 'expression'
require_relative 'ast'
require_relative 'lexer'


class Parser
  def initialize(tokens)
    @tokens = tokens
    @pos = 0
  end

  def peek
    @tokens[@pos]
  end

  def previous
    @tokens[@pos - 1]
  end

  def eof?
    peek.token_type == TokenType::EOF
  end

  def advance
    return peek if eof?

    t = @tokens[@pos]
    @pos += 1
    t
  end

  def accept(token_type)
    if peek.token_type == token_type
      advance
      true
    end
    false
  end

  def parse_identifier
    Literal.new(peek.literal)
  end

  def parse_expression
    parse_equality
  end

  def parse_equality
    expr = parse_comparison
    while [TokenType::NEQ, TokenType::EQUALS].include? peek.token_type
      op = advance
      right = parse_comparison
      expr = BinaryExpr.new(expr, op, right)
    end
    expr
  end

  def parse_comparison
    expr = parse_term
    while [TokenType::GREATER, TokenType::GEQ, TokenType::LESS, TokenType::LEQ].include? peek.token_type
      op = advance
      right = parse_term
      expr = BinaryExpr.new(expr, op, right)
    end
    expr
  end

  def parse_term
    expr = parse_factor
    while [TokenType::PLUS, TokenType::MINUS].include? peek.token_type
      op = advance
      right = parse_factor
      expr = BinaryExpr.new(expr, op, right)
    end
    expr
  end

  def parse_factor
    expr = parse_unary
    while [TokenType::MULTIPLY, TokenType::DIVIDE].include? peek.token_type
      op = advance
      right = parse_unary
      expr = BinaryExpr.new(expr, op, right)
    end
    expr
  end

  def parse_unary
    return parse_unary if peek.token_type == TokenType::NOT

    parse_primary
  end

  def parse_primary
    t = peek
    advance
    if [TokenType::NUMBER, TokenType::STRING,
        TokenType::FALSE, TokenType::TRUE].include? t.token_type
      Literal.new(t.literal)
    elsif t.token_type == TokenType::LPAREN
      expr = GroupedExpr.new(parse_expression)
      expect TokenType::RPAREN
      advance
      expr
    else
      puts("invalid token #{t}")
      exit 1
    end
  end

  def parse_grouping
    # expect TokenType::LPAREN
    # expr = nil
    # while peek.token_type != TokenType::RPAREN
    #
    # end
    nil
  end

  def parse_assignment
    expect TokenType::VAL
    val_token = advance
    expect TokenType::IDENT
    ident_node = parse_identifier
    advance
    expect TokenType::ASSIGN
    advance
    expr = parse_expression
    AssignStatement.new(val_token, ident_node, expr)
  end

  def expect(token_type)
    t = peek
    return unless t.token_type != token_type

    puts("Expected token of type #{token_type} at line:column #{t.line}:#{t.col}")
    exit 1
  end
end

def test
  expr = '(2+6)*8'
  stmt = 'val x = (2 + 6) * 8;'
  lexer = Lexer.new(expr)
  tokens = lexer.lex
  puts(tokens)
  p = Parser.new(tokens)
  stmt = p.parse_expression
  puts(stmt)
end

test

