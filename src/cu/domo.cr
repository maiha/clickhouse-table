module Cu::Domo
  # https://developer.domo.com/docs/dataset-api-reference/dataset
  # STRING, DECIMAL, LONG, DOUBLE, DATE, DATETIME

  record Column, type : String, name : String do
    def to_json(json : JSON::Builder)
      {
        "type" => type,
        "name" => name,
      }.to_json(json)
    end

    def self.type(clickhouse : Clickhouse::Column) : String
      case clickhouse.type
      when "String"  ; "STRING"
      when "Float64" ; "DOUBLE"
      when "Float32" ; "DECIMAL"
      when "Time"    ; "TIME"
      when "Date"    ; "DATE"
      when "DateTime"; "DATETIME"
      when /Int/     ; "LONG"
      else
        raise ArgumentError.new("no column type mappings for [#{clickhouse.type}]")
      end
    end
  end

  class Schema
    var name : String
    var description : String
    var columns : Array(Column)

    def to_json(json : JSON::Builder)
      {
        "name" => name,
        "description" => description,
        "schema" => {
          "columns" => columns,
        }
      }.to_json(json)
    end
  end
end
