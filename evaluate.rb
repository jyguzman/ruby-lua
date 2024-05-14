# frozen_string_literal: true
require_relative 'token'
require_relative 'expression'
require_relative 'ast'
require_relative 'lexer'
require_relative 'parser'

def test
  source = '(2 + 3) * 5 - 10 + #"size";'
  lexer = Lexer.new(source)
  tokens = lexer.lex
  puts(tokens)
  p = Parser.new(tokens)
  program = Program.new p.parse_program
  puts(program)
  visitor = Visitor.new
  expr = program.statements[0]
  puts(expr)
  puts(expr.accept visitor)
  program.statements.each { |stmt|
    puts(stmt.accept(visitor))
  }
end

test
