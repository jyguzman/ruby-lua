# frozen_string_literal: true
require_relative 'lexer'

source = '
  function sum(n) do
    val n = 0;
    while n <= 10 do
      n = n + 1;
    end
    return n;
  end
'

source_two = '
function sum(n) do
    val n = 0;
    while n <= 10 do
      n = n + 1;
    end
end
'

lexer = Lexer.new('59**
')

puts(lexer.lex)
