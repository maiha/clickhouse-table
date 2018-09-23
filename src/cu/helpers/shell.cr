module Cu::Helpers::Shell
  var shell : ::Shell::Seq = ::Shell::Seq.new

  def before
    shell.dryrun = true if config.nop?
  end

  def after
    abort "failed: %s\n%s" % [shell.last.cmd, shell.stderr] if !shell.success?
    puts shell.manifest if shell.dryrun?
  end
end
