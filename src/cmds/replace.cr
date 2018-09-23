Cmds.command "replace" do
  include Cu::Helpers::Shell

  usage "<ymd> <data_path> # ex) 20180924 data.csv"

  def run
    date = args.shift? || abort "<ymd> not found"
    path = args.shift? || abort "<data_path> not found"
    ymd  = Pretty.date(date).to_s("%Y%m%d")
    tmp  = build_table(suffix: ymd, tmp: true)
    dst  = build_table(suffix: ymd)
    old  = tmp + "_old"

    # 1. create merge table
    shell.run("#{program} schema merge | #{client}")

    # 2. create target table
    shell.run("#{program} schema date #{ymd} | #{client}")

    # 3. create target(tmp) table
    shell.run("#{client} --query='DROP TABLE IF EXISTS #{tmp}'")
    shell.run("#{program} schema tmp #{ymd} | #{client}")

    # 4. insert data into target(tmp) table
    shell.run("#{client} --query='INSERT INTO #{tmp} FORMAT #{format}' <  #{path}")

    # 5. rename tables
    shell.run("#{client} --query='DROP TABLE IF EXISTS #{old}'")
    shell.run("#{client} --query='RENAME TABLE #{dst} TO #{old}, #{tmp} TO #{dst}'")

    # 6. delete old table
    shell.run("#{client} --query='DROP TABLE IF EXISTS #{old}'")
  end
end
