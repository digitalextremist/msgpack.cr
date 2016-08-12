require "./spec_helper"

describe Msgpack do
  context "should codec" do
    it "nil" { (nil.to_msgpack.from_msgpack).should eq(nil) }
    it "1" { (1.to_msgpack.from_msgpack).should eq(1) }
    it "5" { (5.to_msgpack.from_msgpack).should eq(5) }
    it "-5" { (-5.to_msgpack.from_msgpack).should eq(-5) }
    it "should codec array" do
      a = [1,2,3,4]
      actual_encoded = a.to_msgpack
      ea = [
        0x94_u8,
          0xd2_u8, 0x0_u8, 0x0_u8, 0x0_u8, 0x1_u8,
          0xd2_u8, 0x0_u8, 0x0_u8, 0x0_u8, 0x2_u8,
          0xd2_u8, 0x0_u8, 0x0_u8, 0x0_u8, 0x3_u8,
          0xd2_u8, 0x0_u8, 0x0_u8, 0x0_u8, 0x4_u8
      ]
      expected_encoded = Bytes.new(ea.to_unsafe, ea.size)
      actual_encoded.should eq(expected_encoded)
      (actual_encoded.from_msgpack).should eq(a)
    end
  end
end
