require "spec"

require "../src/cu"

BINARY_NAME = "clickhouse-table"
CONFIG_NAME = ".clickhouse-table.toml"

WORK_DIR    = File.join(Dir.current, "tmp/spec")
BINARY_PATH = File.join(Dir.current, "bin", BINARY_NAME)
CONFIG_PATH = File.join(WORK_DIR, CONFIG_NAME)

# patch to `Shell::Seq` to ajudst binary path in stdout
class Shell::Seq
  def pretty_stdout : String
    stdout.gsub(/[^\s]+clickhouse-table/, "clickhouse-table").chomp
  end
end

def run(arg) : Shell::Seq
  shell = Shell::Seq.new
  Dir.cd(WORK_DIR) {
    shell.run("./#{BINARY_NAME} #{arg}")
  }
  return shell
end

def run!(arg) : Shell::Seq
  shell = run(arg)
  unless shell.success?
    msg = shell.stderr.split(/\n/)[0..2].join("\n")
    fail "(exit #{shell.exit_code}) clickhouse-table #{arg}\n#{msg}".strip
  end
  shell
end

def remove_ansi_color(buf : String) : String
  buf.gsub(/\e\[\d{1,3}[mK]/, "")
end

def configure(**hash)
  Dir.cd(WORK_DIR) {
    buf = File.read(CONFIG_NAME)
    hash.each do |k,v|
      buf = buf.sub(/^#{k} .*?$/m, "#{k} = #{v.inspect}")
    end
    File.write(CONFIG_NAME, buf)
  }
end

Pretty::Dir.clean(WORK_DIR)
Dir.cd(WORK_DIR) {
  Shell.run("ln -s #{BINARY_PATH} #{BINARY_NAME}")
}

Spec.before_each do
  Dir.cd(WORK_DIR) {
    Shell.run("./#{BINARY_NAME} config sample > #{CONFIG_PATH}")
  }
end
