# frozen_string_literal: true

module TokenType
  # punctuation
  SEMI = 'SEMICOLON'
  COMMA = 'COMMA'
  LPAREN = 'LPAREN'
  RPAREN = 'RPAREN'
  LBRACE = 'LBRACE'
  RBRACE = 'RBRACE'
  LBRACKET = 'LBRACKET'
  RBRACKET = 'RBRACKET'

  # binary operators
  PLUS = 'PLUS'
  MINUS = 'MINUS'
  MULTIPLY = 'MULTIPLY'
  DIVIDE = 'DIVIDE'
  EQUALS = 'EQUALS'
  GREATER = 'GREATER'
  GEQ = 'GEQ'
  LESS = 'LESS'
  LEQ = 'LEQ'
  ASSIGN = 'ASSIGNMENT'

  # types
  TRUE = 'TRUE'
  FALSE = 'FALSE'
  NUMBER = 'NUMBER'
  STRING = 'STRING'
  NIL = 'NIL'

  # keywords
  FUNCTION = 'FUNCTION'
  RETURN = 'RETURN'
  VAL = 'VAL'
  FOR = 'FOR'
  LUA_DO = 'DO'
  LUA_END = 'END'
  LUA_IF = 'IF'
  WHILE = 'WHILE'
  THEN = 'THEN'
  ELSE = 'ELSE'

  EOF = 'EOF'
end

class Token
  def initialize(token_type, line, col, lexeme, literal)
    @token_type = token_type
    @line = line
    @col = col
    @lexeme = lexeme
    @literal = literal
  end

  def to_s
    "Token(#{@token_type}, (#{@line}, #{@col}), #{@lexeme})"
  end
end
