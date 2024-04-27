# frozen_string_literal: true
require_relative 'token'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @pos = 0
  end

  def eof?
    false
  end

  def advance
    nil
  end

  def parse
    nil
  end

  def primary
    nil
  end
end
