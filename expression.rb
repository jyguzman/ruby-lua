# frozen_string_literal: true

class Visitor
  def visit_binary_expr(expr)
    expr
  end
end

class Expression
  def accept(visitor)
    raise NotImplementedError("Must implement visit()")
  end
end
class BinaryExpr < Expression
  def initialize(left, operator, right)
    @left = left
    @op = operator
    @right = right
  end
  attr_reader :left, :op, :right

  def to_s
    "Binary(#{@left} #{@op.lexeme} #{@right})"
  end

  def visit(visitor)
    visitor.visit_binary_expr(self)
  end
end

class GroupedExpr
  def initialize(expr)
    @expr = expr
  end
  attr_reader :expr

  def to_s
    "Grouping(#{@expr})"
  end
end

class UnaryExpr
  def initialize(op, right)
    @op = op
    @right = right
  end

  def to_s
    "Unary(#{@op.lexeme}, #{@right})"
  end
end

class FunctionExpr
  def initialize(ident, params, body)
    @ident = ident
    @params = params
    @body = body
  end

  def to_s
    # params = params[0] if params.size == 1
    "Func(\"#{@ident}\", #{@params}, #{@body})"
  end
end
