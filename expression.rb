# frozen_string_literal: true

class BinaryExpr
  def initialize(left, operator, right)
    @left = left
    @op = operator
    @right = right
  end
  attr_reader :left, :op, :right

  def to_s
    "Binary(#{@left}, #{@op.lexeme}, #{@right})"
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
