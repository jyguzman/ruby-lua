# frozen_string_literal: true
require_relative 'lexer'

lexer = Lexer.new('--+-*/*/"hello,world!"
57.8
/')

puts(lexer.lex)
