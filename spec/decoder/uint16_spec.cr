require "../spec_helper"

describe Msgpack do
  context "uint16" do
    it "Decodes 0" do
      ([0xcd_u8, 0_u8, 0_u8].from_msgpack).should eq(0)
    end

    it "Decodes 1" do
      ([0xcd_u8, 0_u8, 1_u8].from_msgpack).should eq(1)
    end

    it "Decodes 254" do
      ([0xcd_u8, 0_u8, 254_u8].from_msgpack).should eq(254)
    end

    it "Decodes 255" do
      ([0xcd_u8, 0_u8, 255_u8].from_msgpack).should eq(255)
    end

    it "Decodes 256" do
      ([0xcd_u8, 1_u8, 0_u8].from_msgpack).should eq(256)
    end

    it "Decodes 65535" do
      ([0xcd_u8, 255_u8, 255_u8].from_msgpack).should eq(65535)
    end
  end
end
