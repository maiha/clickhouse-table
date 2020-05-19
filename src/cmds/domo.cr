Cmds.command "domo" do
  include Cu::Helpers::Shell

  task "schema.json" do
    table_name = config.table

    schema = Cu::Domo::Schema.new
    schema.name = table_name
    schema.description = "ClickHouse: #{table_name}"
    schema.columns = get_clickhouse_columns(table_name).map{|column|
      Cu::Domo::Column.new(name: column.name, type: Cu::Domo::Column.type(column))
    }
    puts Pretty.json(schema.to_json)
  end

  private def get_clickhouse_columns(table_name)
    client = Clickhouse.new(host: config.host?, port: 8123)
    case table_name
    when /^(.*?)\.(.*)/
      db = $1
      table_name = $2
    end
    db ||= config.db
    return client.table(database: db, name: table_name).columns
  end
end
