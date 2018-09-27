class ClickHouse::Schema::Create
  var db      : String
  var table   : String
  var column  : String
  var columns : Array(Column) = self.class.parse_columns(column)
  var engine  : String
end

class ClickHouse::Schema::Create
  def self.parse(buf : String) : Create
    schema = new
    case buf
    when /\A\s*CREATE\s+TABLE\s+(?:(?<db>#{IDENTIFIER})\.)?(?<table>#{IDENTIFIER})\s*\((?<column>.*?)\)\s*ENGINE\s*=\s*(?<engine>.*)(?:;|\Z)/m
      schema.db     = $~["db"]?
      schema.table  = $~["table"]
      schema.column = $~["column"].strip
      schema.engine = $~["engine"].strip
    else
      raise "can't parse create schema from: #{buf}"
    end
    return schema
  end

  def self.parse_columns(buf : String) : Array(Column)
    array = Array(Column).new
    buf.split(/,/).each do |line|
      column = Column.new
      case line
      when /\A\s*(#{IDENTIFIER})\s+(#{IDENTIFIER})\s*\Z/m
        column.name = $1
        column.type = Field::Types.parse($2)
      else
        raise "can't parse schema column: #{line}"
      end
      array << column
    end
    return array
  end
end
