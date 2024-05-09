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

  def accept(visitor)
    nil
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
    "Return(#{@expr})"
  end
end


class Block
  def initialize(stmts)
    @stmts = stmts
  end

  def add(stmt)
    @stmts.push stmt
  end

  def to_s
    'Block(' + @stmts.join(', ') + ')'
  end
end

class IfStatement
  def initialize(condition, then_block, else_block)
    @condition = condition
    @then_block = then_block
    @else_block = else_block
  end
  attr_reader :condition, :then_block, :else_block

  def to_s
    "IfStatement(#{@condition}, #{@then_block}, #{@else_block})"
  end
end

class ForLoop
  def initialize(var_init_assignment, stop, step, body)
    @var_init_assignment = var_init_assignment
    @stop = stop
    @step = step
    @body = body
  end

  def to_s
    "ForLoop(#{@var_init_assignment}, #{@stop}, #{@step}, #{@body})"
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

