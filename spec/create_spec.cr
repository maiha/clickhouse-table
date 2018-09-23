require "./spec_helper"

describe "clickhouse-client" do
  describe "create" do
    it "creates merge table" do
      run!("create -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema merge | clickhouse-client
        EOF
    end

    it "should respect setting(db)" do
      configure db: "db1"
      run!("create -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema merge | clickhouse-client -d db1
        EOF
    end

    it "should respect setting(client)" do
      configure client: "clickhouse-client -h host1"
      run!("create -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema merge | clickhouse-client -h host1
        EOF
    end

    it "should respect config" do
      Shell.run("cp #{CONFIG_PATH} #{WORK_DIR}/foo.toml")
      run!("create -c foo.toml -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table -c foo.toml schema merge | clickhouse-client
        EOF
    end
  end
end
