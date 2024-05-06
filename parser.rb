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
    puts("peeking in parse stmt #{peek}, #{stmt}")
    expect TokenType::SEMI
    advance
    stmt
  end

  def parse_function_def
    expect TokenType::FUNCTION
    advance
    expect TokenType::IDENT
    func_ident = advance
    expect TokenType::LPAREN
    params = []
    while peek.token_type != TokenType::RPAREN
      advance
      expect TokenType::IDENT
      params.push(advance)
      expect TokenType::COMMA if peek.token_type != TokenType::RPAREN
    end
    expect TokenType::RPAREN
    advance
    body = []
    body.push parse_statement while peek.token_type != TokenType::LUA_END
    expect TokenType::LUA_END
    advance
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
    advance
    expect TokenType::ASSIGN
    advance
    expr = parse_expression
    AssignStatement.new(is_local, ident_node, expr)
  end

  def parse_block
    stmts = []
    until accept(TokenType::LUA_END)
      stmt = parse_statement
      puts("in loop: #{stmt}")
      stmts.push(stmt)
      puts("is end? #{peek}")
    end
    puts("is end two? #{peek}")
    expect TokenType::LUA_END
    advance
    stmts
  end

  def parse_while_loop
    expect TokenType::WHILE
    advance
    condition = parse_expression
    puts("condition: #{condition}, current: #{peek}")
    expect TokenType::LUA_DO
    advance
    block = parse_block
    advance
    puts("before while loop return #{block}")
    WhileLoop.new(condition, block)
  end

  def parse_return_stmt
    expect TokenType::RETURN
    return_tok = advance
    advance
    expr = parse_expression
    ReturnStatement.new(return_tok, expr)
  end

  def expect(token_type)
    t = peek
    return unless t.token_type != token_type

    puts("Expected token of type #{token_type} at line:column #{t.line}:#{t.col}")
    exit 1
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
  lexer = Lexer.new(loop)
  tokens = lexer.lex
  puts(tokens)
  p = Parser.new(tokens)
  stmts = p.parse_program
  puts(stmts)
end

test

