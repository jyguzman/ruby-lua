# frozen_string_literal: true
require_relative 'visitor'
class Node
  def accept(visitor)
    raise NotImplementedError("Must be implemented")
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

  def name
    @token.lexeme
  end

  def accept(visitor)
    val = visitor.env.get(name)
    if val.nil?
      puts("Identifier \"#{name}\" not previously declared")
      exit 1
    end
    val
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
    @ident_node = ident_node
    @expr_node = expr_node
  end
  attr_reader :is_local, :ident_node, :expr_node

  def to_s
    "Assignment(#{@ident_node} = #{@expr_node}, local: #{@is_local})"
  end

  def accept(visitor)
    visitor.visit_assign_stmt self
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

  def accept(visitor)
    expr.accept(visitor)
  end
end


class Block
  def initialize(stmts)
    @stmts = stmts
  end

  def add(stmt)
    @stmts.push stmt
  end

  attr_reader :stmts

  def to_s
    "Block(#{@stmts.join(', ')})"
  end

  def accept(visitor)
    visitor.visit_block self
  end
end

class IfStatement
  def initialize(condition, then_block, else_block = nil)
    @condition = condition
    @then_block = then_block
    @else_block = else_block
  end
  attr_reader :condition, :then_block, :else_block

  def to_s
    "IfStatement(#{@condition}, #{@then_block}, #{@else_block})"
  end

  def accept(visitor)
    visitor.visit_if_stmt self
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
  def initialize(condition, while_block)
    @condition = condition
    @while_block = while_block
  end

  attr_reader :condition, :while_block

  def to_s
    "WhileLoop(#{@condition}, #{@while_block})"
  end

  def accept(visitor)
    visitor.visit_while_loop self
  end
end

class PrintStatement
  def initialize(expr)
    @expr = expr
  end

  def accept(visitor)
    expr_res = @expr.accept(visitor)
    puts(expr_res)
  end
end

class Program
  def initialize(statements)
    @statements = statements
  end

  attr_reader :statements

  def add(statement)
    @statements.push statement
  end

  def accept(visitor)
    @statements.each { |stmt| stmt.accept(visitor) }
  end

  def to_s
    "Program(#{@statements.join(', ')})"
  end
end
