require "./spec_helper"

describe "clickhouse-client" do
  describe "insert <ymd> <data_path>" do
    it "appends the data of the given file into the table" do
      run!("insert 20180924 data.csv -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-client --query='INSERT INTO logs_20180924 FORMAT CSV' <  data.csv
        EOF
    end

    it "respects config(format)" do
      configure format: "CSVWithNames"
      run!("insert 20180924 data.csv -n").pretty_stdout.should eq(<<-EOF)
        clickhouse-client --query='INSERT INTO logs_20180924 FORMAT CSVWithNames' <  data.csv
        EOF
    end
  end
end
