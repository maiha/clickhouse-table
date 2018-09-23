module Cu::Helpers::Schema
  protected def build_table(suffix : String? = nil, tmp = false) : String
    name = config.schema_table             # "logs"
    name = "#{name}_%s" % suffix if suffix # "logs_20180911"
    name = "tmp_#{name}" if tmp            # "tmp_logs_20180911"
    return name
  end
  
  protected def build_schema(table : String, merge = false) : String
    column = config.schema_column
    engine = config.schema_engine
    String.build do |io|
      io << "CREATE TABLE IF NOT EXISTS %s\n" % table
      io << "(\n"
      io << column
      io << ")\n"
      if merge
        io << "ENGINE = Merge(currentDatabase(), '^%s_')\n" % [table]
      else
        io << "ENGINE = %s\n" % [engine]
      end
    end    
  end
end

class Cmds::Cmd
  include Cu::Helpers::Schema
end
