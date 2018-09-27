Cmds.command "config" do
  include Cu::Helpers::Shell
  include ClickHouse::Schema

  usage "sample > .clickhouse-table.toml"
  usage "from -t logs # generate config from 'logs' table"
  usage "show         # show current config"
  usage "test         # test current config"

  SAMPLE = {{ system("cat " + env("PWD") + "/config/config.toml").stringify }}

  task "sample" do
    if field = args.shift?
      k = field.split(".").last
      v = sample_config[field.gsub(".", "/")]
      puts "%s = %s" % [k, v.inspect]
    else
      puts SAMPLE
    end
  end

  task "from" do
    sql = show_create_table_from(args.shift?)
    return if config.nop?

    create = ClickHouse::Schema::Create.parse(sql)
    s = SAMPLE
    s = s.sub(/^table .*?$/m, "table = #{create.table.inspect}")
    s = s.sub(/^(column\s*=\s*""").*?(""")/m){"#{$1}\n#{create.column}\n#{$2}"}
    s = s.sub(/^engine .*?$/m, "engine = #{create.engine.inspect}")
    puts s
  end
  
  task "show" do
    puts "# %s" % (config.clue? || "unknown")
    puts config
  end

  task "test" do
    src = sample_config.toml
    dst = config.toml

    results = Array(Array(String)).new
    
    src.each do |group, value|
      if value.is_a?(Array)
        # ignore this, cause it may be loggers
      elsif value.is_a?(Hash)
        test_group(results, value, dst[group]?, clue: group)
      end
    end

    errors = [] of String

    body = String.build do |io|
      Pretty.lines(results, delimiter: " ").split(/\n/).each do |line|
        case line
        when / # NG/
          errors << line.split(/\s+/).first
          io.puts line.colorize(:red)
        else
          io.puts line
        end
      end
    end

    if config.verbose?
      puts "# #{config.clue}"
      puts "-" * 60
      puts body
      puts "-" * 60
    end
    
    if errors.any?
      msg = String.build do |io|
        io.puts "%d error(s)" % errors.size
        errors.each do |key|
          io.puts "  #{PROGRAM_NAME} config sample #{key} -v"
        end
      end
      raise Cu::Config::Error.new(msg)
    end
  end

  private def sample_config
    Cu::Config.parse(SAMPLE)
  end

  private def test_group(results, src, dst, clue)
    case dst
    when Hash
      # OK
      src.keys.sort.each do |k|
        label = "#{clue}.#{k}"
        if (value = dst[k]?) != nil
          value = Pretty.truncate(value, size: 20)
          results << [label, value, "# OK"]
        else
          results << [label, "---", "# NG: (not found)"]
        end
      end
    else
      reason = "not Hash (%s)" % [dst.class]
      results << [clue, "---", "# NG: #{reason}"]
    end
  end

  private def show_create_table_from(source)
    case source.to_s
    when "-"
      return ARGF.gets_to_end
    when /^(#{IDENTIFIER})\.(#{IDENTIFIER})$/
      show_create_table($1, $2)
    when /^(#{IDENTIFIER})$/
      show_create_table(nil, $1)
    when ""
      show_create_table(nil, nil)
    else
      abort "invalid table name: '#{source}'. try '-t <name>'"
    end
  end

  private def show_create_table(db, table)
    db    ||= config.db?
    table ||= config.table? || abort "expected table name. try '-t <name>'"

    # by clickhouse-client
    cmd = String.build do |s|
      s << config.clickhouse_client
      s << " -h #{config.host}" if config.host?
      s << " -d #{db}" if db
      s << " --query='SHOW CREATE TABLE #{table} FORMAT CSV'"
    end
    shell.run(cmd)
    buf = shell.stdout
    return buf if config.nop?

    csv = CSV.parse(buf)
    row = csv[0]? || abort "invalid csv. expected rows[0]: #{buf}"
    col = row[0]? || abort "invalid csv. expected cols[0]: #{row}"
    return col
  end
end
