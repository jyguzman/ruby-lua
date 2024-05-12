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
    while accept(TokenType::STAR, TokenType::SLASH, TokenType::PERCENT)
      op = advance
      right = parse_unary
      expr = BinaryExpr.new(expr, op, right)
    end
    expr
  end

  def parse_unary
    if accept(TokenType::NOT, TokenType::HASHTAG, TokenType::MINUS)
      op = advance
      expr = parse_unary
      return UnaryExpr.new(op, expr)
    end
    parse_primary
  end

  def parse_primary
    if accept(TokenType::NUMBER, TokenType::STRING,
              TokenType::FALSE, TokenType::TRUE)
      advance
      Literal.new(previous.literal)
    elsif accept TokenType::IDENT
      return parse_function_call if peek(1).token_type == TokenType::LPAREN
      advance
      Literal.new(previous.literal)
    elsif accept TokenType::LPAREN
      advance
      expr = GroupedExpr.new(parse_expression)
      expect TokenType::RPAREN
      expr
    elsif accept TokenType::FUNCTION
      parse_function_def
    else
      puts("invalid token #{peek}")
      exit 1
    end
  end

  def parse_statement
    if accept(TokenType::IDENT, TokenType::LOCAL)
      stmt = if peek(1).token_type == TokenType::LPAREN
               parse_function_call
             else
               parse_assignment
             end
    elsif accept(TokenType::RETURN)
      stmt = parse_return_stmt
    elsif accept TokenType::WHILE
      stmt = parse_while_loop
    elsif accept TokenType::FOR
      stmt = parse_for_loop
    elsif accept TokenType::FUNCTION
      stmt = parse_function_def
    elsif accept TokenType::LUA_IF
      stmt = parse_if_statement
    else
      stmt = parse_expression
      expect TokenType::SEMI unless accept(TokenType::EOF, TokenType::LUA_END, TokenType::ELSE)
    end
    stmt
  end

  def parse_function_def
    expect TokenType::FUNCTION
    func_ident = advance if accept TokenType::IDENT
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

  def parse_function_call
    expect TokenType::IDENT
    func_ident = previous
    expect TokenType::LPAREN
    args = []
    until accept TokenType::RPAREN
      args.push(parse_expression)
      expect TokenType::COMMA unless accept(TokenType::RPAREN)
    end
    expect TokenType::RPAREN
    FunctionCallExpr.new(func_ident, args)
  end

  def parse_assignment(is_local = false)
    if accept TokenType::LOCAL
      is_local = true
      advance
    end
    expect TokenType::IDENT
    ident_node = IdentNode.new(previous)
    expect TokenType::ASSIGN
    expr = parse_expression
    expect TokenType::SEMI unless accept(TokenType::EOF, TokenType::LUA_END,
                                         TokenType::ELSE, TokenType::COMMA)
    AssignStatement.new(is_local, ident_node, expr)
  end

  def parse_block
    block = Block.new []
    block.add parse_statement until accept(TokenType::LUA_END, TokenType::ELSE)
    block
  end

  def parse_while_loop
    expect TokenType::WHILE
    condition = parse_expression
    expect TokenType::LUA_DO
    block = parse_block
    advance
    WhileLoop.new(condition, block)
  end

  def parse_for_loop
    expect TokenType::FOR
    assignment = parse_assignment true
    expect TokenType::COMMA
    stop = parse_expression
    step = 1
    if accept TokenType::COMMA
      advance
      step = parse_expression
    end
    expect TokenType::LUA_DO
    body = parse_block
    expect TokenType::LUA_END
    advance
    ForLoop.new(assignment, stop, step, body)
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
    expect TokenType::SEMI unless accept(TokenType::EOF, TokenType::LUA_END, TokenType::ELSE)
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
    blocks = []
    blocks.push parse_statement until eof?
    blocks
  end
end

def test
  source =
    "for i = 0, 10, 3 do
      x = y + 3
    end
    3 - 4;
    u = -5;
    x = #\"hello\";
    y = (2 + 6) * 8;
    z = true and not false or (5 * 8 == 40);
    w = 0;
    while y <= 100 do
      y = y + 5;
      w = w + 10;
    end
    if x <= 100 then
      y = 3 + 5
    else
      y = 3 + 6
    end
    add = function(m, n)
      res = m + n;
      return res
    end;
    function square(n) return n * n end
    q = add(5, 10);
    z = square(10);
    square(10)"
  lexer = Lexer.new(source)
  tokens = lexer.lex
  puts(tokens)
  p = Parser.new(tokens)
  stmts = p.parse_program
  program = Program.new stmts
  puts(stmts)

end

test

