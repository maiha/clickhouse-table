class ClickHouse::Column
  var name : String
  var type : Field::Types

  def to_s(io : IO)
    io << name << " " << type.to_s
  end
end
