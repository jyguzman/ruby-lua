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

  def peek(n = 0)
    @tokens[@pos + n]
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

  def accept(*token_types)
    token_types.include? peek.token_type
  end

  def parse_identifier
    IdentNode.new(peek)
  end

  def parse_expression
    parse_or
  end

  def parse_or
    expr = parse_and
    while accept TokenType::LUA_OR
      op = advance
      right = parse_or
      expr = BinaryExpr.new(expr, op, right)
    end
    expr
  end

  def parse_and
    expr = parse_equality
    while accept TokenType::AND
      op = advance
      right = parse_equality
      expr = BinaryExpr.new(expr, op, right)
    end
    expr
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
        TokenType::FALSE, TokenType::TRUE, TokenType::IDENT].include? t.token_type
      Literal.new(t.literal)
    elsif t.token_type == TokenType::LPAREN
      expr = GroupedExpr.new(parse_expression)
      expect TokenType::RPAREN
      expr
    else
      puts("invalid token #{t}")
      exit 1
    end
  end

  def parse_statement
    puts("peek #{peek}")
    stmt = if accept(TokenType::IDENT, TokenType::LOCAL)
             parse_assignment
           elsif accept TokenType::WHILE
             parse_while_loop
           elsif accept TokenType::FUNCTION
             parse_function_def
           else
             parse_expression
           end
    expect TokenType::SEMI
    stmt
  end

  def parse_function_def
    expect TokenType::FUNCTION
    expect TokenType::IDENT
    func_ident = previous
    expect TokenType::LPAREN
    params = []
    until accept TokenType::RPAREN
      expect TokenType::IDENT
      params.push(previous)
      expect TokenType::COMMA unless accept(TokenType::RPAREN)
    end
    expect TokenType::RPAREN
    body = parse_block
    expect TokenType::LUA_END
    FunctionExpr.new(func_ident, params, body)
  end

  def parse_assignment
    is_local = false
    if accept TokenType::LOCAL
      is_local = true
      advance
    end
    expect TokenType::IDENT
    ident_node = parse_identifier
    expect TokenType::ASSIGN
    expr = parse_expression
    AssignStatement.new(is_local, ident_node, expr)
  end

  def parse_block
    stmts = []
    stmts.push(parse_statement) until accept(TokenType::LUA_END, TokenType::ELSE)
    stmts
  end

  def parse_while_loop
    expect TokenType::WHILE
    condition = parse_expression
    expect TokenType::LUA_DO
    block = parse_block
    advance
    WhileLoop.new(condition, block)
  end

  def parse_if_statement
    expect TokenType::LUA_IF
    condition = parse_expression
    expect TokenType::THEN
    then_block = parse_block
    expect TokenType::ELSE
    else_block = parse_block
    expect TokenType::LUA_END
    IfStatement.new(condition, then_block, else_block)
  end

  def parse_return_stmt
    expect TokenType::RETURN
    return_tok = previous
    expr = parse_expression
    ReturnStatement.new(return_tok, expr)
  end

  def expect(token_type)
    t = peek
    if accept token_type
      advance
    else
      puts("Expected token of type #{token_type} at line:column #{t.line}:#{t.col}")
      exit 1
    end
  end

  def parse_program
    stmts = []
    stmts.push parse_statement until eof?
    stmts
  end
end

def test
  expr = '2+6*8'
  stmts = "x = (2 + 6) * 8; local y = true and false or (5 * 8 == 40);"
  loop = 'while 3 <= 5 do z = 2 + 5; w = 5 + 10; end'
  if_stmt = "
  if x <= 3 then
    y = 3 + 5;
  else
    y = 3 + 6;
  end"
  lexer = Lexer.new(if_stmt)
  tokens = lexer.lex
  puts(tokens)
  p = Parser.new(tokens)
  stmts = p.parse_if_statement
  puts(stmts)
end

test

