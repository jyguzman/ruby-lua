# frozen_string_literal: true
class Visitor
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
    when '..'
      l = l.accept self
      r = r.accept self
      unless l.instance_of?(String) && r.instance_of?(String)
        puts("#{op} requires two operands of type string")
        exit 1
      end
      l + r
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
end

module Expression
  def accept(visitor)
    raise NotImplementedError("Must implement accept()")
  end
end

class Literal
  include Expression
  def initialize(literal)
    @literal = literal
  end

  attr_reader :literal

  def to_s
    "Literal(#{@literal})"
  end

  def accept(visitor)
    visitor.visit_literal self
  end
end

class BinaryExpr
  include Expression
  def initialize(left, operator, right)
    @left = left
    @op = operator
    @right = right
  end
  attr_reader :left, :op, :right

  def accept(visitor)
    visitor.visit_binary_expr self
  end

  def to_s
    "Binary(#{@left} #{@op.lexeme} #{@right})"
  end

end

class GroupedExpr
  include Expression
  def initialize(expr)
    @expr = expr
  end
  attr_reader :expr

  def to_s
    "Grouping(#{@expr})"
  end

  def accept(visitor)
    visitor.visit_grouped_expr self
  end
end

class UnaryExpr
  include Expression
  def initialize(op, right)
    @op = op
    @right = right
  end

  attr_reader :op, :right

  def to_s
    "Unary(#{@op.lexeme}, #{@right})"
  end

  def accept(visitor)
    visitor.visit_unary_expr self
  end
end

class FunctionExpr
  include Expression
  def initialize(ident, params, body)
    @ident = ident
    @params = params
    @body = body
  end

  attr_reader :ident, :params, :body

  def to_s
    "Func(\"#{@ident}\", #{@params}, #{@body})"
  end
end

class FunctionCallExpr
  include Expression
  def initialize(ident, args)
    @ident = ident
    @args = args
  end

  def to_s
    "FunctionCall(#{@ident}, #{@args})"
  end
end
