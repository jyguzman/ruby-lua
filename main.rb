#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lexer'
def load_source_file(path = 'test.rua')
  File.open(path).read
end

def repl
  puts('Welcome to Rua! Start typing stuff, I guess.')
  until (input = gets).chomp.eql? 'exit'
    puts("You said #{input}")
  end
end

def run
  args = ARGV
  if args.empty?
    repl
  else
    lexer = Lexer.new(load_source_file)
    puts(lexer.lex)
  end
end

run
