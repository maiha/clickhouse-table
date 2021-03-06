class Cu::Config < TOML::Config
  class Error < Exception
  end

  var clue : String
  var path : String

  bool "verbose"
  bool "nop"
  bool "force"
  str  "clickhouse/client"
  str  "clickhouse/format", format
  str  "clickhouse/host", host
  str  "clickhouse/db", db
  str  "schema/table", table
  str  "schema/engine", engine
  str  "schema/column", column

  def clickhouse_client
    clickhouse_client? || "clickhouse-client"
  end

  def to_s(io : IO)
    max = @paths.keys.map(&.size).max
    @paths.each do |(key, val)|
      io.puts "  %-#{max}s = %s" % [key, val]
    end
  end

  private def not_found(key)
    case key
    when "clickhouse/host"
      raise NotFound.new("missing <host>: use -h <host> or set config: '#{key}'")
    when "clickhouse/db"
      raise NotFound.new("missing <db>: use -d <db> or set config: '#{key}'")
    when "schema/table"
      raise NotFound.new("missing <table_name>: use -t <table_name> or set config: '#{key}'")
    else
      raise NotFound.new("missing config: '#{key}'")
    end
  end

  private def pretty_dump(io : IO = STDERR)
    io.puts "[config] #{clue?}"
    io.puts to_s
  end

  def program
    String.build do |io|
      io << PROGRAM_NAME
      io << " -c #{path}" if path?
    end
  end

  def client
    String.build do |io|
      io << clickhouse_client
      io << " -d #{db}" if db? && db? != "default"
    end
  end
end

class Cu::Config < TOML::Config
  FILENAME = ".clickhouse-table.toml"

  def self.parse_file(path : String)
    super(path).tap(&.clue = path)
  end

  def self.empty
    parse("")
  end

  def self.load(path : String?) : Config
    # When the path is specified
    if path
      name = path.sub(/\.toml$/, "")
      ["#{name}.toml", name].each do |p|
        return parse_file(p) if File.exists?(p)
      end
      # delegates errors to parser
      return parse_file(path)
    end

    # When no paths are specified,
    # searchs CONFIG_FILE from here to root dir.
    dir = File.real_path("./")
    while !dir.empty?
      if config = load?(dir)
        return config
      end
      break if dir == "/"
      dir = File.expand_path(File.join(dir, ".."))
    end      

    return load?("~/") || empty
  end

  private def self.load?(dir : String) : Config?
    path = File.expand_path(File.join(dir, FILENAME))
    if File.exists?(path)
      parse_file(path)
    else
      nil
    end
  end
end
