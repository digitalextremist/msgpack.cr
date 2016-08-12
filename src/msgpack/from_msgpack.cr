require "./to_msgpack"

class Array(T)
  def from_msgpack
    Bytes.new(to_unsafe, size * sizeof(T)).from_msgpack
  end
end

struct Slice
  def from_msgpack
    Msgpack::Decoder.decode(MemoryIO.new(self, false))
  end
end

module IO
  def from_msgpack
    Msgpack::Decoder.decode(self)
  end
end


module Msgpack
  module Decodable
    abstract def decode?(e : Msgpack::Extension) : Bool
    abstract def decode(e : Msgpack::Extension)
    abstract def filter(v : Msgpack::Encodable) : Msgpack::Encodable

    def register_filter
      Msgpack::Decoder.register_filter(filter_to_proc)
    end

    def unregister_filter
      Msgpack::Decoder.unregister_filter(filter_to_proc)
    end

    def filter_to_proc
      ->filter(Msgpack::Encodable)
    end

    def with_filter
      register_filter
      yield
    ensure
      unregister_filter
    end
  end

  class Decoder
    # reader
    property! r : IO

    alias FilterProc = Msgpack::Encodable -> Msgpack::Encodable
    @@filters = [] of FilterProc

    def self.unregister_filter(f : FilterProc)
      @@filters.delete f
    end

    def self.register_filter(f : FilterProc)
      unregister_filter f
      @@filters << f
    end

    private def initialize(@r : IO)
    end

    def self.decode(r : IO)
      new(r).decode
    end

    def decode
      res = Array(typeof(decode!)).new
      begin
        until eof?
          res << decode!
        end
      rescue IO::EOFError
      end
      (res.size == 1) ? res[0] : res
    end

    private def decode!
      x = _decode!
      @@filters.each { |f| x = f.call(x) }
      x
    end

    private def _decode!
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
      when 0xd4
        read_ext(1_u32)
      when 0xd5
        read_ext(2_u32)
      when 0xd6
        read_ext(4_u32)
      when 0xd7
        read_ext(8_u32)
      when 0xd8
        read_ext(16_u32)
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
        f = r.as(File | MemoryIO)
        f.tell == f.size
      else
        false
      end
    end

    private def read_string(n : UInt32) : String
      String.new(read(n))
    end

    private def read_bin(n : UInt32) : Bytes
      read(n)
    end

    private def read_ext(n : UInt32) : Msgpack::Extension
      type = read_i8
      data = read(n)
      Msgpack::Extension.new(type, data)
    end

    private def read_map(n : UInt32) : Hash(Encodable, Encodable)
      res = Hash(Encodable, Encodable).new
      n.times do
        k = decode!
        v = decode!
        res[k] = v
      end
      res
    end

    private def read_array(n : UInt32) : Array(Encodable)
      res = Array(Encodable).new
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

    private def read(n : UInt32) : Bytes
      buf = Bytes.new(n)
      actual = r.read(buf)
      raise "Truncated input" unless actual == n
      buf
    end
  end
end
