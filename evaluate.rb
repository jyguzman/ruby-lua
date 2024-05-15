# frozen_string_literal: true
require_relative 'token'
require_relative 'expression'
require_relative 'ast'
require_relative 'lexer'
require_relative 'parser'

def do_eval
  source = "
  i = 0;
  j = 10;
  while i < 5 or j > 8 do
    --local k = 5;
    i = i + 1;
    j = j - 1;
  end
  if j < 0 then
    k = 100;
  else
    m = 50;
  end
  concat_string = \"one_\"..\"two\""
  lexer = Lexer.new(source)
  tokens = lexer.lex
  puts(tokens)
  p = Parser.new(tokens)
  program = Program.new p.parse_program
  puts(program)
  visitor = Visitor.new
  program.accept(visitor)
  puts(visitor.env)
  # expr = program.statements[0]
  # puts(expr)
  # puts(expr.accept visitor)
  # puts(visitor.env)
  # program.statements.each { |stmt|
  #   puts(stmt.accept(visitor))
  # }
end

do_eval
