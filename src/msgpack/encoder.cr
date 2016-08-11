module Msgpack
    def self.encode_bytes(b : Type) : Bytes
    e = Encoder.new
    e.w = m = MemoryIO.new
    e.encode(b)
    Bytes.new(m.buffer, m.bytesize)
  end

  def self.encode_string(b : Type) : String
    e = Encoder.new
    e.w = m = MemoryIO.new
    e.encode(b)
    String.new(m.to_slice)
  end

  def self.encode(b : Type, w : IO)
    e = Encoder.new
    e.w = w
    e.encode(b)
  end

  class Encoder
    # writer
    property! w : IO  

    def encode(v : Nil)
      w.write_byte(0xc0_u8)
    end

    def encode(v : Bool)
      w.write_byte(v ? 0xc3_u8 : 0xc2_u8)
    end

    def encode(v : Float32)
      w.write_byte(0xca_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : Float64)
      w.write_byte(0xcb_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : UInt8)
      w.write_byte(0xcc_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : UInt16)
      w.write_byte(0xcd_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : UInt32)
      w.write_byte(0xce_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : UInt64)
      w.write_byte(0xcf_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : Int8)
      w.write_byte(0xd0_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : Int16)
      w.write_byte(0xd1_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : Int32)
      w.write_byte(0xd2_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : Int64)
      w.write_byte(0xd3_u8)
      w.write_bytes(v, IO::ByteFormat::BigEndian)
    end

    def encode(v : Array(Type))
      n = v.size
      case
      when n <= 15
        w.write_byte(0x90_u8 | n.to_u8)
      when n <= 65535
        w.write_byte(0xdc_u8)
        encode(n.to_u16)
      when n <= 4294967295
        w.write_byte(0xdd_u8)
        encode(n.to_u32)
      else
        raise "Unencodable array of length #{n}"
      end
      v.each { |x| encode(x) }
    end

    def encode(v : Hash(Type, Type))
      n = v.size
      case
      when n <= 15
        w.write_byte(0x80_u8 | n.to_u8)
      when n <= 65535
        w.write_byte(0xde_u8)
        encode(n.to_u16)
      when n <= 4294967295
        w.write_byte(0xdf_u8)
        encode(n.to_u32)
      else
        raise "Unencodable map of length #{n}"
      end
      v.each { |k, val| encode(k); encode(val) }
    end

    def encode(v : Bytes)
      n = v.size
      case
      when n <= 255
        w.write_byte(0xc4_u8)
        encode(n.to_u8)
      when n <= 65535
        w.write_byte(0xc5_u8)
        encode(n.to_u16)
      when n <= 4294967295
        w.write_byte(0xc6_u8)
        encode(n.to_u32)
      else
        raise "Unencodable bytes of length #{n}"
      end
      w.write(v)
    end

    def encode(v : String)
      n = v.size
      case
      when n <= 15
        w.write_byte(0xa0_u8 | n.to_u8)
      when n <= 255
        w.write_byte(0xd9_u8)
        encode(n.to_u8)
      when n <= 65535
        w.write_byte(0xda_u8)
        encode(n.to_u16)
      when n <= 4294967295
        w.write_byte(0xdb_u8)
        encode(n.to_u32)
      else
        raise "Unencodable string of length #{n}"
      end
      w.write(v.unsafe_byte_slice(0))
    end

    def encode(v : Ext)
      w.write_byte(v.type.to_u8)
      n = v.data.size
      case
      when n <= 255
        w.write_byte(0xc7_u8)
        encode(n.to_u8)
      when n <= 65535
        w.write_byte(0xc8_u8)
        encode(n.to_u16)
      when n <= 4294967295
        w.write_byte(0xc9_u8)
        encode(n.to_u32)
      else
        raise "Unencodable ext of length #{n}"
      end
      w.write(v.data)
    end
  end
end
