# frozen_string_literal: true

class BinaryExpr
  def initialize(left, operator, right)
    @left = left
    @op = operator
    @right = right
  end
  attr_reader :left, :op, :right

  def to_s
    "Binary(#{@left} #{@op.lexeme} #{@right})"
  end

  def pretty
    s1 = "      #{@op.lexeme}       \n"
    s2 = "#{left.pretty}      #{right.pretty}"
    s1 + s2
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
end

class FunctionExpr
  def initialize(ident, params, body)
    @ident = ident
    @params = params
    @body = body
  end

  def to_s
    "Func(\"#{@ident.lexeme}\", #{params}, #{body})"
  end
end
