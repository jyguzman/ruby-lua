# frozen_string_literal: true
require_relative 'env'

class Visitor
  def initialize(env = Env.new)
    @env = env
  end

  attr_reader :env

  def visit_binary_expr(expr)
    op = expr.op.lexeme
    l = expr.left
    r = expr.right
    case op
    when '+'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(Integer) || l.instance_of?(Float)
        puts("#{op} requires two numbers")
        exit 1
      end
      l + r
    when '-'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(Integer) || l.instance_of?(Float)
        puts("#{op} requires two operands of type number")
        exit 1
      end
      l - r
    when '*'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(Integer) || l.instance_of?(Float)
        puts("#{op} requires two operands of type number")
        exit 1
      end
      l * r
    when '/'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(Integer) || l.instance_of?(Float)
        puts("#{op} requires two operands of type number")
        exit 1
      end
      l / r
    when '%'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(Integer) || l.instance_of?(Float)
        puts("#{op} requires two operands of type number")
        exit 1
      end
      l % r
    when '..'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(String) && r.instance_of?(String)
        puts("#{op} requires two operands of type string")
        exit 1
      end
      l + r
    when %w[< <= > >=].include?(op)
      puts("im in here")
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(Integer) || l.instance_of?(Float)
        puts("#{op} requires two operands of type number")
        exit 1
      end
      case op
      when '<'
        l < r
      when '<='
        l <= r
      when '>'
        l > r
      when '>='
        l >= r
      else
        puts("Unhandled op: #{op}")
        exit 1
      end
    when 'and'
      l = l.accept self
      r = r.accept self
      l && r
    when 'or'
      l = l.accept self
      r = r.accept self
      l || r
    when '>'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(Integer) || l.instance_of?(Float)
        puts("#{op} requires two operands of type number")
        exit 1
      end
      l > r
    when '<'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(Integer) || l.instance_of?(Float)
        puts("#{op} requires two operands of type number")
        exit 1
      end
      l < r
    else
      puts("Unrecognized operator #{op}")
      exit 1
    end
  end

  def visit_unary_expr(expr)
    op = expr.op.lexeme
    target = expr.right
    case op
    when '#'
      literal = target.accept self
      return literal.size if literal.instance_of? String

      puts('Operand for "#" must be type String.')
    when 'not'
      literal = target.accept self
      if literal.nil? || literal == false
        true
      else
        false
      end
    when '-'
      return -expr.right if expr.right.instance_of?(Integer) || expr.right.instance_of?(Float)

      puts('Operand for "#" must be type Number.')
    else
      puts("Unrecognized unary op #{op}")
    end
  end

  def visit_grouped_expr(grouping)
    grouping.expr.accept self
  end

  def visit_literal(expr)
    expr.literal
  end

  def visit_block(block)
    @env.add_local_table
    block.stmts.each do |stmt|
      stmt.accept self
    end
    @env.pop_local_table
  end

  def visit_assign_stmt(stmt)
    is_local = stmt.is_local
    expr_res = stmt.expr_node.accept self
    ident = stmt.ident_node.name
    @env.add(ident, expr_res, is_local)
  end

  def visit_while_loop(while_loop)
    condition_res = while_loop.condition.accept self
    while condition_res
      while_loop.while_block.accept self
      condition_res = while_loop.condition.accept self
    end
  end

  def visit_if_stmt(if_stmt)
    condition_res = if_stmt.condition.accept self
    if condition_res
      if_stmt.then_block.accept self
    else
      if_stmt.else_block&.accept self
    end
  end
end
