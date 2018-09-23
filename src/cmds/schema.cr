Cmds.command "schema" do
  usage "date  <ymd> # ex. '20180911'"
  usage "tmp   <ymd>"
  usage "merge"

  var target_date : Time
  
  task "merge" do
    table = build_table
    puts build_schema(table: table, merge: true)
  end

  task "date" do
    table = build_table(suffix: read_ymd!)
    puts build_schema(table: table)
  end

  task "tmp" do
    table = build_table(suffix: read_ymd!, tmp: true)
    puts build_schema(table: table)
  end

  private def read_ymd!
    date = args.shift? || abort "<ymd> not found"
    Pretty.date(date).to_s("%Y%m%d")
  end
end
