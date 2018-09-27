Cmds.command "create" do
  include Cu::Helpers::Shell

  usage "date  <ymd> # ex. '20180911'"
  usage "tmp   <ymd> # create tmp_ymd table"
  usage "merge       # create merge table if not exists"
  usage "merge -f    # drop and create mergetable"

  task "merge" do
    table = build_table
    do_create(table, "merge")
  end

  task "date" do
    ymd   = read_ymd!
    table = build_table(suffix: ymd)
    do_create(table, "date #{ymd}")
  end

  task "tmp" do
    ymd   = read_ymd!
    table = build_table(suffix: ymd, tmp: true)
    do_create(table, "tmp #{ymd}")
  end

  private def do_create(table, arg)
    shell.run("#{client} --query='DROP TABLE IF EXISTS #{table}'") if config.force?
    shell.run("#{program} schema #{arg} | #{client}")
  end
end
