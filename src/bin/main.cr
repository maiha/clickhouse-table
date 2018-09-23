require "../cu"
require "opts"

class Main
  include Opts

  USAGE = <<-EOF
    {{version}}

    Usage: {{program}} <command> [options] [args]

    command:
      schema  show field names in json

    Examples:
    EOF

  option merge : Bool, "--merge", "Use merge table (schema command)", false
  option config_path  : String?, "-c <config>", "config file path (default: '~/.clickhouse-table.toml')", nil
  
  option force   : Bool, "-f", "Force the operation", false
  option nop     : Bool, "-n", "Nop", false
  option verbose : Bool, "-v", "Tell verbose messages", false
  option help    : Bool, "--help"   , "Show this help", false
  option version : Bool, "--version", "Print the version and exit", false

  def run
    cmd = Cmds[args.shift?].new
    cmd.config = load_config
    cmd.run(args)
  rescue err : Cmds::Abort | Cmds::CommandNotFound | Cmds::TaskNotFound | TOML::Config::NotFound
    STDERR.puts err.to_s.colorize(:red)
    exit 1
  end

  private def load_config
    config = Cu::Config.load(config_path)
    config.verbose = verbose
    config.nop     = nop
    config.force   = force
    config.path    = config_path.not_nil! if config_path
    return config
  end
end

Main.run
