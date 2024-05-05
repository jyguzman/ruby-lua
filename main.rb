#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lexer'

def load_source_file(path = 'test.rua')
  File.open(path).read
end

def repl
  lexer = Lexer.new
  puts('Welcome to Rua! This just tokenizes each string.')
  until (input = gets.chomp).eql? 'exit'
    puts(lexer.lex(input))
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
