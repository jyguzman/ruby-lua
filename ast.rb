class Literal
  def initialize(literal)
    @literal = literal
  end

  def to_s
    "Literal(#{@literal})"
  end

  def pretty
    @literal.to_s
  end
end

class ExprNode

end

class IdentNode
  def initialize(token)
    @token = token
  end

  def to_s
    "Ident(\"#{@token.lexeme}\")"
  end
end

class Statement
  def initialize(node, statement_node)
    @node = node
    @statement = statement_node
  end
end

class AssignStatement
  def initialize(is_local, ident_node, expr_node)
    @is_local = is_local
    @ident = ident_node
    @expr = expr_node
  end
  attr_reader :ident, :expr

  def to_s
    "Assignment(#{@ident} = #{@expr}, local: #{@is_local})"
  end
end

class ReturnStatement
  def initialize(token, expr)
    @token = token
    @expr = expr
  end

  def to_s
    "Return(#{token.lexeme}, #{expr})"
  end
end

class WhileLoop
  def initialize(condition, body)
    @condition = condition
    @body = body
  end

  def to_s
    "WhileLoop(#{@condition}, #{@body})"
  end
end

