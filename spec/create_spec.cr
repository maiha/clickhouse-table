require "./spec_helper"

describe "clickhouse-client" do
  describe "create merge" do
    it "creates merge table" do
      run!("create merge -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema merge | clickhouse-client
        EOF
    end

    it "drops and creates merge table by '-f'" do
      run!("create merge -f -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-client --query='DROP TABLE IF EXISTS logs'
        clickhouse-table schema merge | clickhouse-client
        EOF
    end

    it "should respect setting(db)" do
      configure db: "db1"
      run!("create merge -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema merge | clickhouse-client -d db1
        EOF
    end

    it "should respect setting(client)" do
      configure client: "clickhouse-client -h host1"
      run!("create merge -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema merge | clickhouse-client -h host1
        EOF
    end

    it "should respect config" do
      Shell.run("cp #{CONFIG_PATH} #{WORK_DIR}/foo.toml")
      run!("create merge -c foo.toml -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table -c foo.toml schema merge | clickhouse-client
        EOF
    end
  end

  describe "schema date <ymd>" do
    it "creates table for the <ymd>" do
      run!("create date 20180924 -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema date 20180924 | clickhouse-client
        EOF
    end

    it "drops and creates table for the <ymd> by '-f'" do
      run!("create date 20180924 -f -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-client --query='DROP TABLE IF EXISTS logs_20180924'
        clickhouse-table schema date 20180924 | clickhouse-client
        EOF
    end
  end

  describe "schema tmp <ymd>" do
    it "creates tmp table for the <ymd>" do
      run!("create tmp 20180924 -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema tmp 20180924 | clickhouse-client
        EOF
    end

    it "drops and creates tmp table for the <ymd> by '-f'" do
      run!("create tmp 20180924 -f -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-client --query='DROP TABLE IF EXISTS tmp_logs_20180924'
        clickhouse-table schema tmp 20180924 | clickhouse-client
        EOF
    end
  end
end
