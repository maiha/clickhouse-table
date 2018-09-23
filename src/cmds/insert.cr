Cmds.command "insert" do
  include Cu::Helpers::Shell

  usage "<ymd> <data_path> # ex) 20180924 data.csv"

  def run
    date = args.shift? || abort "<ymd> not found"
    path = args.shift? || abort "<data_path> not found"
    ymd  = Pretty.date(date).to_s("%Y%m%d")
    dst  = build_table(suffix: ymd)

    shell.run("#{client} --query='INSERT INTO #{dst} FORMAT #{format}' <  #{path}")
  end
end
