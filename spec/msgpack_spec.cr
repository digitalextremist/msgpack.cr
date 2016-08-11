require "./spec_helper"

describe Msgpack do
  context "should codec" do
    it "nil" { Msgpack.decode(Msgpack.encode_bytes(nil)).should eq(nil) }
    it "1" { Msgpack.decode(Msgpack.encode_bytes(1)).should eq(1) }
    it "5" { Msgpack.decode(Msgpack.encode_bytes(5)).should eq(5) }
    it "-5" { Msgpack.decode(Msgpack.encode_bytes(-5)).should eq(-5) }
    it "should codec array" do
      a = [1,2,3,4] of Msgpack::Type
      actual_encoded = Msgpack.encode_bytes(a)
      ea = [
        0x94_u8,
          0xd2_u8, 0x0_u8, 0x0_u8, 0x0_u8, 0x1_u8,
          0xd2_u8, 0x0_u8, 0x0_u8, 0x0_u8, 0x2_u8,
          0xd2_u8, 0x0_u8, 0x0_u8, 0x0_u8, 0x3_u8,
          0xd2_u8, 0x0_u8, 0x0_u8, 0x0_u8, 0x4_u8
      ]
      expected_encoded = Bytes.new(ea.to_unsafe, ea.size)
      actual_encoded.should eq(expected_encoded)
      Msgpack.decode(actual_encoded).should eq(a)
    end
  end
end
