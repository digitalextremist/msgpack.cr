require "../spec_helper"

describe Msgpack do
  context "uint8" do
    it "Decodes 0" do
      ([0xcc_u8, 0_u8].from_msgpack).should eq(0)
    end

    it "Decodes 1" do
      ([0xcc_u8, 1_u8].from_msgpack).should eq(1)
    end

    it "Decodes 254" do
      ([0xcc_u8, 254_u8].from_msgpack).should eq(254)
    end

    it "Decodes 255" do
      ([0xcc_u8, 255_u8].from_msgpack).should eq(255)
    end
  end
end
