# frozen_string_literal: true
require_relative 'token'
require_relative 'expression'
require_relative 'ast'
require_relative 'lexer'
require_relative 'parser'

def do_eval
  source = "
  i = 0;
  k = 0;
  j = 10;
  while i < 5 do
    local k = 3;
    i = i + k;
  end
  if j > 3 then
    local z = 1000;
    while z > 500 do
      local y = 500;
      z = z - y;
    end
    j = j + z;
  else
    local z = 1000;
    j = j - z;
  end
  local concat_string = \"one_\"..\"two\""
  tokens = Lexer.new(source).lex
  # puts(tokens)
  p = Parser.new(tokens)
  program = Program.new p.parse_program
  # puts(program)
  visitor = Visitor.new
  program.accept(visitor)
  puts("env after program: #{visitor.env}")
end

do_eval
