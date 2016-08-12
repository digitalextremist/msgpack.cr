require "./spec_helper"

class Foo
  include Msgpack::Encodable
  extend Msgpack::Decodable

  EXT_TYPE = 1_i8 # this should be unique per class

  alias X = Int32

  getter x : X

  def initialize(@x : X)
  end

  def to_msgpack(io : IO)
    buf = MemoryIO.new
    buf.write_bytes(@x, IO::ByteFormat::BigEndian)
    Msgpack::Extension.new(EXT_TYPE, buf.to_slice).to_msgpack(io)
  end

  def self.decode?(e : Msgpack::Extension)
    e.type == EXT_TYPE
  end

  def self.decode(e : Msgpack::Extension)
    return unless decode? e
    buf = MemoryIO.new(e.data)
    x = buf.read_bytes(X, IO::ByteFormat::BigEndian)
    new(x)
  end

  def self.filter(v : Msgpack::Encodable) : Msgpack::Encodable
    if e = v.as?(Msgpack::Extension)
      return decode(e) if decode?(e)
    end
    v
  end

  # for specs
  def ==(other : Foo)
    x == other.x
  end
end


describe Foo do
  context ".to_msgpack" do
    it "works" do
      Foo.with_filter do
        enc = [214_u8, 1_u8, 0_u8, 0_u8, 4_u8, 210_u8].to_slice
        dec = Foo.new(1234)
        dec.to_msgpack.should eq(enc)
      end
    end
  end

  context "#from_msgpack" do
    it "works" do
      Foo.with_filter do
        enc = [214_u8, 1_u8, 0_u8, 0_u8, 4_u8, 210_u8].to_slice
        dec = Foo.new(1234)
        enc.from_msgpack.should eq(dec)
      end
    end
  end
end
