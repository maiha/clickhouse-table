require "./spec_helper"

describe "clickhouse-client" do
  describe "replace <ymd> <data_path>" do
    it "replaces the data of the given file into the table" do
      run!("replace 20180924 data.csv -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-table schema merge | clickhouse-client
        clickhouse-table schema date 20180924 | clickhouse-client
        clickhouse-client --query='DROP TABLE IF EXISTS tmp_logs_20180924'
        clickhouse-table schema tmp 20180924 | clickhouse-client
        clickhouse-client --query='INSERT INTO tmp_logs_20180924 FORMAT CSV' <  data.csv
        clickhouse-client --query='DROP TABLE IF EXISTS tmp_logs_20180924_old'
        clickhouse-client --query='RENAME TABLE logs_20180924 TO tmp_logs_20180924_old, tmp_logs_20180924 TO logs_20180924'
        clickhouse-client --query='DROP TABLE IF EXISTS tmp_logs_20180924_old'
        EOF
    end
  end
end
