require "./spec_helper"

describe ClickHouse::Schema::Create do
  describe ".parse(string)" do
    it "builds a new instance from the string" do
      buf = <<-EOF
        CREATE TABLE default.logs (
          date Date,
          hour Int32,
          imp Int64
        ) ENGINE = Merge(currentDatabase(), '^logs_')
        EOF

      schema = ClickHouse::Schema::Create.parse(buf)
      schema.db?.should eq("default")
      schema.table?.should eq("logs")
      schema.column.gsub(/\s+/m, " ").strip.should eq((<<-EOF).gsub(/\s+/m, " "))
        date Date,
        hour Int32,
        imp Int64
        EOF
      schema.columns.map(&.to_s).should eq(["date Date", "hour Int32", "imp Int64"])
      schema.engine?.should eq("Merge(currentDatabase(), '^logs_')")
    end
  end
end
