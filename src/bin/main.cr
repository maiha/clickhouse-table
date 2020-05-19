require "../cu"
require "opts"

class Main
  include Opts

  USAGE = <<-EOF
    {{version}}

    Usage: {{program}} <command> [options] [args]

    Options:
    {{options}}

    Command:
      #{Cmds.names}

    Examples:
      clickhouse-table config from default.logs
      clickhouse-table create  merge
      clickhouse-table insert  20180924 diff.csv
      clickhouse-table replace 20180924 full.csv
    EOF

  option _host   : String?, "-h <host>"  , "server host name", nil
  option _db     : String?, "-d <dbname>", "database name", nil
  option _table  : String?, "-t <table>" , "table name", nil
  option _path   : String?, "-c <config>", "config file path (default: '~/.clickhouse-table.toml')", nil
  option merge   : Bool, "--merge", "Use merge table", false
  
  option force   : Bool, "-f", "Force the operation", false
  option nop     : Bool, "-n", "Print the commands that would be executed (dry-run)", false
  option verbose : Bool, "-v", "Tell verbose messages", false
  option help    : Bool, "--help"   , "Show this help", false
  option version : Bool, "--version", "Print the version and exit", false

  def run
    cmd = Cmds[args.shift?].new
    cmd.config = load_config
    cmd.run(args)
  rescue Cmds::Finished
  rescue err : Cmds::Navigatable
    STDERR.puts Cmds::Navigator.new.navigate(err)
    exit err.exit_code
  rescue err : Cmds::Abort
    STDERR.puts err.to_s.chomp.colorize(:red)
    exit 1
  rescue err : Cmds::Abort | TOML::Config::NotFound | Cu::Config::Error
    STDERR.puts err.to_s.colorize(:red)
    exit 1
  end

  private def load_config
    config = Cu::Config.load(_path)
    config.verbose = verbose
    config.nop     = nop
    config.force   = force
    config.db      = _db
    config.host    = _host
    config.table   = _table
    config.path    = _path.not_nil! if _path
    return config
  end
end

Main.run
