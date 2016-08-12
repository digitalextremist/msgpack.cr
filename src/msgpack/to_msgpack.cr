module Msgpack::Encodable
  def to_msgpack : Bytes
    m = MemoryIO.new
    to_msgpack(m)
    m.to_slice
  end

  abstract def to_msgpack(io : IO)
end

struct Nil
  include Msgpack::Encodable

  def to_msgpack(io : IO)
    io.write_byte(0xc0_u8)
  end
end

struct Bool
  include Msgpack::Encodable

  def to_msgpack(io : IO)
    io.write_byte(self ? 0xc3_u8 : 0xc2_u8)
  end
end

class Array
  include Msgpack::Encodable

  def to_msgpack(io : IO)
    n = size
    if n <= 15
      io.write_byte(0x90_u8 | n.to_u8)
    elsif n <= 65535
      io.write_byte(0xdc_u8)
      io.write_bytes(n.to_u16, IO::ByteFormat::BigEndian)
    elsif n <= 4294967295
      io.write_byte(0xdd_u8)
      io.write_bytes(n.to_u32, IO::ByteFormat::BigEndian)
    else
      raise "Unencodable Array of length #{n}"
    end
    each &.to_msgpack(io)
  end
end

class Hash
  include Msgpack::Encodable

  def to_msgpack(io : IO)
    n = size
    if n <= 15
      io.write_byte(0x80_u8 | n.to_u8)
    elsif n <= 65535
      io.write_byte(0xde_u8)
      io.write_bytes(n.to_u16, IO::ByteFormat::BigEndian)
    elsif n <= 4294967295
      io.write_byte(0xdf_u8)
      io.write_bytes(n.to_u32, IO::ByteFormat::BigEndian)
    else
      raise "Unencodable Hash of length #{n}"
    end
    each { |k, v| k.to_msgpack(io); v.to_msgpack(io) }
  end
end

struct Slice
  include Msgpack::Encodable

  def to_msgpack(io : IO)
    n = size
    if n <= 255
      io.write_byte(0xc4_u8)
      io.write_byte(n.to_u8)
    elsif n <= 65535
      io.write_byte(0xc5_u8)
      io.write_bytes(n.to_u16, IO::ByteFormat::BigEndian)
    elsif n <= 4294967295
      io.write_byte(0xc6_u8)
      io.write_bytes(n.to_u32, IO::ByteFormat::BigEndian)
    else
      raise "Unencodable Slice(UInt) of length #{n}"
    end
    io.write(self) # byte slices only
  end
end

class String
  include Msgpack::Encodable

  def to_msgpack(io : IO)
    n = size
    if n <= 15
      io.write_byte(0xa0_u8 | n.to_u8)
    elsif n <= 255
      io.write_byte(0xd9_u8)
      io.write_byte(n.to_u8)
    elsif n <= 65535
      io.write_byte(0xda_u8)
      io.write_bytes(n.to_u16, IO::ByteFormat::BigEndian)
    elsif n <= 4294967295
      io.write_byte(0xdb_u8)
      io.write_bytes(n.to_u32, IO::ByteFormat::BigEndian)
    else
      raise "Unencodable String of length #{n}"
    end
    io.write(Bytes.new(to_unsafe, bytesize))
  end
end

# struct Symbol
#   include Msgpack::Encodable
#
#   def to_msgpack(io : IO)
#     to_s.to_msgpack(io)
#   end
# end

macro define_to_msgpack(type, code)
  struct {{type}}
    include Msgpack::Encodable

    def to_msgpack(io : IO)
      io.write_byte({{code}})
      if sizeof({{type}}) == 1
        io.write_byte(to_u8)
      else
        io.write_bytes(self, IO::ByteFormat::BigEndian)
      end
    end
  end
end

define_to_msgpack(UInt8, 0xcc_u8)
define_to_msgpack(UInt16, 0xcd_u8)
define_to_msgpack(UInt32, 0xce_u8)
define_to_msgpack(UInt64, 0xcf_u8)
define_to_msgpack(Int8, 0xd0_u8)
define_to_msgpack(Int16, 0xd1_u8)
define_to_msgpack(Int32, 0xd2_u8)
define_to_msgpack(Int64, 0xd3_u8)
define_to_msgpack(Float32, 0xca_u8)
define_to_msgpack(Float64, 0xcb_u8)

class Msgpack::Extension
  include Msgpack::Encodable

  def to_msgpack(io : IO)
    n = data.size
    if n == 1
      io.write_byte(0xd4_u8)
    elsif n == 2
      io.write_byte(0xd5_u8)
    elsif n == 4
      io.write_byte(0xd6_u8)
    elsif n == 8
      io.write_byte(0xd7_u8)
    elsif n == 16
      io.write_byte(0xd8_u8)
    elsif n <= 255
      io.write_byte(0xc7_u8)
      io.write_byte(n.to_u8)
    elsif n <= 65535
      io.write_byte(0xc8_u8)
      io.write_bytes(n.to_u16, IO::ByteFormat::BigEndian)
    elsif n <= 4294967295
      io.write_byte(0xc9_u8)
      io.write_bytes(n.to_u32, IO::ByteFormat::BigEndian)
    else
      raise "Unencodable Extension of size #{n}"
    end
    io.write_byte(type.to_u8)
    io.write(data)
  end
end
