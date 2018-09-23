class Cmds::Cmd
  var config : Cu::Config
  delegate program, client, format, to: config
end
