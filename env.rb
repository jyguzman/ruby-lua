class Env
  def initialize(global_table = {})
    @symbol_tables = [global_table]
    @level = 0
  end

  attr_reader :symbol_tables, :level

  def add(name, val, is_local = true)
    if is_local
      @symbol_tables[@level][name] = val
      return
    end
    level = level_of_symbol name
    if level != -1
      @symbol_tables[level][name] = val
      return
    end
    @symbol_tables[0][name] = val
  end

  def get(name)
    level = @level
    while level >= 0
      table = @symbol_tables[level]
      return table[name] if table.key? name

      level -= 1
    end
    nil
  end

  def add_local_table
    @level += 1
    @symbol_tables.push({})
  end

  def pop_local_table
    return if @level.zero?

    @level -= 1
    @symbol_tables.pop
  end

  def level_of_symbol(name)
    level = @level
    while level >= 0
      return level if @symbol_tables[level].key? name

      level -= 1
    end
    -1
  end

  def has?(name)
    level_of_symbol name > -1
  end

  def to_s
    @symbol_tables.to_s
  end
end
