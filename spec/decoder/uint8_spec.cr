require "../spec_helper"

describe Msgpack do
  context "uint8" do
    it "Decodes 0" do
      Msgpack.decode([0xcc_u8, 0_u8]).should eq(0)
    end

    it "Decodes 1" do
      Msgpack.decode([0xcc_u8, 1_u8]).should eq(1)
    end

    it "Decodes 254" do
      Msgpack.decode([0xcc_u8, 254_u8]).should eq(254)
    end

    it "Decodes 255" do
      Msgpack.decode([0xcc_u8, 255_u8]).should eq(255)
    end
  end
end
