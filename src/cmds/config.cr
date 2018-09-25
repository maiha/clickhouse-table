Cmds.command "config" do
  usage "sample > .clickhouse-table.toml"
  usage "show  # show current config"
  usage "test  # test current config"

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
end
