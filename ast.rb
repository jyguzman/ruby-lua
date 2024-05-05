class Literal
  def initialize(literal)
    @literal = literal
  end

  def to_s
    "Literal(#{@literal})"
  end
end

class ExprNode

end

class IdentNode
  def initialize(token)
    @token = token
  end

  def to_s
    "Ident(#{@token.lexeme})"
  end
end

class Statement
  def initialize(node, statement_node)
    @node = node
    @statement = statement_node
  end
end

class AssignStatement
  def initialize(token, ident_node, expr_node)
    @token = token
    @ident = ident_node
    @expr = expr_node
  end
  attr_reader :ident, :expr

  def to_s
    "Assignment(#{@ident} = #{@expr})"
  end
end

