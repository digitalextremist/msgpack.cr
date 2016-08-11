module Msgpack
  def self.decode(b : Bytes) : Type
    decode(MemoryIO.new(b, false))
  end

  def self.decode(b : Array) : Type
    decode(Bytes.new(b.to_unsafe, b.size * sizeof(typeof(b[0]))))
  end

  def self.decode(r : IO) : Type
    d = Decoder.new
    d.r = r
    d.decode
  end

  def self.decode(s : String) : Type
    decode(s.reader)
_ end   

  class Decoder
    # reader
    property! r : IO
    
    def decode : Type
      res = Array(Type).new
      begin
        until eof?
          res << decode!
        end
      rescue IO::EOFError
      end
      res.size == 1 ? res[0] : res
    end

    private def decode! : Type
      case c = read_u8
      when 0x80..0x8f
        read_map((c & 0x0f).to_u32)
      when 0x90..0x9f
        read_array((c & 0x0f).to_u32)
      when 0xa0..0xbf
        read_string((c & 0x1f).to_u32)
      when 0xc0
        nil
      when 0xc1 # never used
        raise "Decode error"
      when 0xc2
        false
      when 0xc3
        true
      when 0xc4
        read_bin(read_u8.to_u32)
      when 0xc5
        read_bin(read_u16.to_u32)
      when 0xc6
        read_bin(read_u32)
      when 0xc7
        read_ext(read_u8.to_u32)
      when 0xc8
        read_ext(read_u16.to_u32)
      when 0xc9
        read_ext(read_u32)
      when 0xca
        read_float32
      when 0xcb
        read_float64
      when 0xcc
        read_u8
      when 0xcd
        read_u16
      when 0xce
        read_u32
      when 0xcf
        read_u64
      when 0xd0
        read_i8
      when 0xd1
        read_i16
      when 0xd2
        read_i32
      when 0xd3
        read_i64
      when 0xd9
        read_string(read_u8.to_u32)
      when 0xda
        read_string(read_u16.to_u32)
      when 0xdb
        read_string(read_u32)
      when 0xdc
        read_array(read_u16.to_u32)
      when 0xdd
        read_array(read_u32)
      when 0xde
        read_map(read_u16.to_u32)
      when 0xdf
        read_map(read_u32)
      when 0xe0..0xff # -32..-1
        c.to_i8
      else # 0x00..0x7f 0..127 u8
        c
      end
    end

    private def eof? : Bool
      case r
      when MemoryIO, File
        f = r as File | MemoryIO
        f.tell == f.size
      else
        false
      end
    end

    private def read_string(n : UInt32) : String
      String.new(n) { |buf| read(Slice.new(buf, n)) }
    end

    private def read_bin(n : UInt32) : Bytes
      read(n)
    end

    private def read_ext(n : UInt32) : Ext
      Ext.new do |e|
        e.type = read_i8
        e.data = read(n)
      end
    end

    private def read_map(n : UInt32) : Hash(Type, Type)
      res = Hash(Type, Type).new(initial_capacity = n)
      n.times do
        k = decode!
        v = decode!
        res[k] = v
      end
      res
    end

    private def read_array(n : UInt32) : Array(Type)
      res = Array(Type).new
      n.times { res << decode! }
      res
    end

    private def read_u8 : UInt8
      b = r.read_byte
      raise "Truncated input" if b.nil?
      b
    end

    private def read_i8 : Int8
      read_u8.to_i8
    end

    macro define_reader(type, suffix)
      private def read_{{suffix}} : {{type}}
        r.read_bytes({{ type }}, IO::ByteFormat::BigEndian)
      end
    end

    define_reader   Int16,     i16
    define_reader   Int32,     i32
    define_reader   Int64,     i64
    define_reader  UInt16,     u16
    define_reader  UInt32,     u32
    define_reader  UInt64,     u64
    define_reader Float32, float32
    define_reader Float64, float64

    private def read(buf : Bytes) : Bytes 
      actual = r.read(buf)
      raise "Truncated input" unless actual == buf.size
      buf
    end

    private def read(n : UInt32) : Bytes 
      read(Bytes.new(n))
    end
  end
end
