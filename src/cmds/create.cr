Cmds.command "create" do
  include Cu::Helpers::Shell

  usage "create    # create table if not exists"
  usage "create -f # drop and create table"

  def run
    shell.run("#{program} schema merge | #{client}")
  end
end
