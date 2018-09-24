Cmds.command "create" do
  include Cu::Helpers::Shell

  usage "create    # create table if not exists"
  usage "create -f # drop and create table"

  def run
    table = build_table
    shell.run("#{client} --query='DROP TABLE IF EXISTS #{table}'") if config.force?
    shell.run("#{program} schema merge | #{client}")
  end
end
