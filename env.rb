class Env
  def initialize(symbol_table = {})
    @symbol_table = symbol_table
  end

  attr_reader :symbol_table

  def add(name, val)
    @symbol_table[name] = val
  end

  def get(name)
    @symbol_table[name]
  end

  def has?(name)
    @symbol_table.key? name
  end

  def remove(name)
    @symbol_table.delete name
  end

  def to_s
    @symbol_table.to_s
  end
end
